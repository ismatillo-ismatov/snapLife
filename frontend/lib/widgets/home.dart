import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ismatov/api/api_service.dart';
import 'package:ismatov/api/post_service.dart';
import 'package:ismatov/api/user_service.dart';
import 'package:ismatov/models/comments.dart';
import 'package:ismatov/models/post.dart';
import 'package:ismatov/models/userProfile.dart';
import 'package:ismatov/widgets/comments_widget.dart';
import 'package:ismatov/widgets/profile.dart';
import 'package:ismatov/widgets/video_player_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class HomePage extends StatefulWidget {
  final String token;
  const HomePage({super.key, required this.token});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Post> friendPosts = [];
  bool isLoading = true;
  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    loadingFriendPosts();
  }
  Future<void> loadingFriendPosts() async {
    try {
      final data = await PostService().fetchFriendPosts(widget.token);
      final posts = data.map((e) => Post.fromJson(e)).toList();
      if (posts.isEmpty) {
        final randomData = await PostService().fetchRandomPosts(widget.token);
        final randomPosts = randomData.map((e) => Post.fromJson(e)).toList();
        setState(() {
          friendPosts = randomPosts;
          isLoading = false;
        });
      } else {
        setState(() {
          friendPosts = posts;
          isLoading = false;
        });
      }
      _refreshController.refreshCompleted();
    } catch (e) {
      print("Postlarni yuklashda xato: $e");
      setState(() {
        isLoading = false;
      });
      _refreshController.refreshFailed();
    }
  }


  void handleLike(Post updatePost) {
    final index = friendPosts.indexWhere((p) => p.id == updatePost.id);
    if (index != -1) {
      setState(() {
        friendPosts[index] = updatePost;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: friendPosts.length,
              itemBuilder: (context, index) {
                final post = friendPosts[index];
                return _PostItem(
                  post: post,
                  token: widget.token,
                  onLikeToggle: handleLike,
                );
              },
            ),
    );
  }
}

class _PostItem extends StatefulWidget {
  final UserProfile? userProfile;
  final Post post;
  final String token;
  final void Function(Post)? onLikeToggle;
  const _PostItem({
    Key? key,
    required this.post,
    required this.token,
    this.userProfile,
    this.onLikeToggle,
  }) : super(key: key);

  @override
  State<_PostItem> createState() => _PostItemState();
}

class _PostItemState extends State<_PostItem> with SingleTickerProviderStateMixin {
  bool isLiked = false;
  bool isExpanded = false;
  bool showBigHeart = false;
  late AnimationController _likeController;
  late Animation<double> _scaleAnimation;
  @override
  void initState() {
    super.initState();
    isLiked = widget.post.liked;
    _likeController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 250),
       );
       _scaleAnimation = Tween<double>(begin: 1.0,end: 1.4)
       .chain(CurveTween(curve: Curves.easeOut))
       .animate(_likeController);
  }

  @override
  void dispose() {
    _likeController.dispose();
    super.dispose();
  }

  void handDoubleTap() {
    setState(() {
      isLiked = true;
      showBigHeart = true;
    });
    Future.delayed(const Duration(milliseconds: 700), () {
      setState(() {
        showBigHeart = false;
      });
    });
  }

  void handleLike() async {
    if (widget.token.isEmpty) return;
    try {
      bool wasLiked = widget.post.liked;

      _likeController.forward().then((_) => _likeController.reverse());

      final updatePost = await PostService().toggleLike(
          postId: widget.post.id,
          isLiked: widget.post.liked,
          token: widget.token);
      setState(() {
        widget.post.liked = updatePost.liked;
        widget.post.likeId = updatePost.likeId;
        if (!wasLiked && updatePost.liked) {
          widget.post.likeCount += 1;
        } else if (wasLiked && !updatePost.liked) {
          widget.post.likeCount -= 1;
        }
      });
      widget.onLikeToggle?.call(widget.post);
    } catch (e) {
      print("Error Like: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final hasVideo = post.postVideo != null;
    final hasImage = post.postImage != null;
    final userName = post.userName.isNotEmpty ? post.userName : 'default';
    final profileImage = post.ownerProfileImage?.isNotEmpty == true
        ? post.ownerProfileImage
        : null;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                 GestureDetector(
                  onTap: () async {
                    print("Profil sahifasiga o'tish");
                    final userId = post.profileId ?? 0;
                    if (userId == 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Foydalanuvchi ID si topilmadi")),
                      );
                      return;
                    }
                    try {
                      final userService = UserService();
                      print("Foydalanuvchi ID si: $userId");
                      print("Token: ${widget.token}");
                      final userProfile = await userService.fetchUserProfileById(userId, widget.token);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfilePage(userProfile: userProfile),
                        ),
                      );
                    } catch (e) {
                      print("Xato: $e");
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Profilni yuklashda xato: $e")),
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfilePage(
                            userProfile: UserProfile(
                              id: userId,
                              userName: userName,
                              profileImage: profileImage != null
                                  ? ApiService().formatImageUrl(profileImage)
                                  : null,
                              posts: [post],
                            ),
                          ),
                        ),
                      );
                    }
                  },
                  child: CircleAvatar(
                    radius: 25.r,
                    backgroundImage: profileImage != null
                        ? NetworkImage(ApiService().formatImageUrl(profileImage))
                        : const AssetImage('assets/images/nouser.png')
                            as ImageProvider,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  userName,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onDoubleTap: handDoubleTap,
            child: Stack(
              children: [          
          if (hasVideo)
            AspectRatio(
              aspectRatio: 9 / 16,
              child: VideoPost(url: post.postVideo!, id: post.id.toString()),
            )
          else if (hasImage)
            Image.network(
              post.postImage!,
              fit: BoxFit.cover,
              width: 1.sw,
              height: 0.6.sh,
            )
          else
            Container(
              width: double.infinity,
              height: 400.h,
              color: Colors.black12,
            ),
            AnimatedOpacity(
              duration: Duration(milliseconds: 300),
              opacity: showBigHeart ? 1 : 0,
              child: Icon(
                Icons.favorite,
                size: 120,
                color: Colors.white.withOpacity(0.9),
              ),
               )
              ]
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.content ?? "",
                  maxLines: isExpanded ? null : 3,
                  overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if ((post.content?.length ?? 0) > 100)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        isExpanded = !isExpanded;
                      });
                    },
                    child: Text(isExpanded ? "Show less" : "Continue reading"),
                  ),
                Row(
                  children: [
                    ScaleTransition(
                      scale: _scaleAnimation, 
                  child:   IconButton(
                      onPressed: handleLike,
                      icon: Icon(
                        widget.post.liked
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: widget.post.liked ? Colors.red : Colors.black54,
                        size: 35,
                      ),
                    ),
                ),
                    Text(
                      "${widget.post.likeCount}",
                      style: const TextStyle(color: Colors.black),
                    ),
                    IconButton(
                      icon: SvgPicture.asset(
                        'assets/svgs/comment.svg',
                        height: 35,
                        width: 35,
                      ),
                      onPressed: () => _showComments(context, post.id),
                    ),
                    Text(
                      "${widget.post.comments.length}",
                      style: const TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showComments(BuildContext context, int postId) async {
    final isCommentAdded = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.95,
              child: CommentsPage(
                token: widget.token,
                postId: postId,
                onCommentAdded: () {
                  Navigator.pop(context, true);
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
