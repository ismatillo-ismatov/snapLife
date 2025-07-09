import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart';
import 'package:ismatov/forms/createPost.dart';
import 'package:ismatov/main.dart';
import 'package:ismatov/widgets/comments_widget.dart';
import 'package:ismatov/widgets/profile.dart';
import 'package:ismatov/forms/updatePost.dart';
import 'package:ismatov/models/userProfile.dart';
import 'package:ismatov/models/likes.dart';
import 'package:ismatov/models/post.dart';
import 'package:ismatov/api/api_service.dart';
import 'package:ismatov/api/post_service.dart';
import 'package:ismatov/api/user_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';
import 'package:ismatov/widgets/video_player_widget.dart';
import 'package:hive/hive.dart';

class PostPage extends StatefulWidget {
  final UserProfile userProfile;
  final Post post;
  final int? scrollToCommentId;
  final int initialIndex;
  final String token;

  const PostPage({
    Key? key,
    required this.userProfile,
    required this.post,
    this.scrollToCommentId,
    required this.initialIndex,
    required this.token,
  }) : super(key: key);

  @override
  _PostPageState createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  final ApiService _apiService = ApiService();
  late PageController _pageController;
  Map<int, bool> expandedMap = {};
  String? token;
  VideoPlayerController? _controller;
  Future<void>? _initializeVideoPlayerFuture;

  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.post.postVideo != null && widget.post.postVideo!.isNotEmpty) {
      _controller = VideoPlayerController.network(widget.post.postVideo!);
      _initializeVideoPlayerFuture = _controller!.initialize().then((_) {
        _controller!.setLooping(true);
        _controller!.play();
        setState(() {});
      });
    }
    _currentPageIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    UserService().getUserToken().then((value) {
      setState(() {
        token = value;
      });
      if (token != null) {
        PostService().fetchPosts(token!);
      }
    });
  }

  bool get _isCurrentuser {
    final box = Hive.box('authBox');
    final currentUserId = box.get('user_id');
    return currentUserId == widget.userProfile.id;
  }

  @override
  void dispose() {
    _pageController.dispose();
    _controller?.dispose();
    super.dispose();
  }

  void _onPageChanged(int newIndex) {
    setState(() {
      _currentPageIndex = newIndex;
    });
  }

  Future<void> deletePostHandler(int postId) async {
    try {
      String? token = await ApiService().getUserToken();
      await PostService().deletePost(postId: postId, token: token!);
      setState(() {
        widget.userProfile.posts.removeWhere((post) => post.id == postId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Post movfaqiyatli ochirildi')),
      );
      Navigator.pop(context, postId);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Postni o`chirishda xatolik')),
      );
    }
  }

  void deletePostLocally(int postId) {
    setState(() {
      widget.userProfile.posts.removeWhere((post) => post.id == postId);
    });
  }

  void handleLike(Post post) async {
    if (token == null) return;
    try {
      final response = await PostService()
          .toggleLike(postId: post.id, isLiked: post.liked, token: token!);
      setState(() {
        post.liked = response.liked;
        post.likeId = response.likeId;
        post.likeCount += response.liked ? 1 : -1;
      });
    } catch (e) {
      print('Like toggle xatolik $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (token == null) {
      return Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          Text("Posts",
              style: TextStyle(
                fontSize: 18,
              )),
        ]),
      ),
      body: NotificationListener<ScrollNotification>(
          onNotification: (scrollNotification) {
            if (scrollNotification is ScrollNotification) {
              print('Scrolling offset:${scrollNotification.metrics.pixels}');
            }
            return false;
          },
          child: PageView.builder(
              controller: _pageController,
              physics: BouncingScrollPhysics(),
              scrollDirection: Axis.vertical,
              itemCount: widget.userProfile.posts.length,
              onPageChanged: _onPageChanged,
              itemBuilder: (context, index) {
                Post post = widget.userProfile.posts[index];
                bool isExpanded = expandedMap[post.id] ?? false;

                return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 25.r,
                                  backgroundImage: widget.userProfile.profileImage !=
                                              null &&
                                          widget.userProfile.profileImage!
                                              .isNotEmpty
                                      ? NetworkImage(
                                          widget.userProfile.profileImage!)
                                      : AssetImage('assets/images/nouser.png')
                                          as ImageProvider,
                                ),
                                const SizedBox(width: 10),
                                Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.userProfile.userName,
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _formatTime(
                                          widget.post.postDate.toString(),
                                        ),
                                        style: TextStyle(
                                            color: Colors.green,
                                            fontSize: 12.h),
                                      ),
                                    ])
                              ],
                            ),
                                      if(_isCurrentuser)

                            IconButton(
                              icon: const Icon(Icons.more_vert),
                              onPressed: () async {
                                final selectedPost =
                                    widget.userProfile.posts[index];
                                final action = await showMenu<String>(
                                    context: context,
                                    position: RelativeRect.fromLTRB(
                                        100, 100, 100, 100
                                        ),
                                    items: [
                                      const PopupMenuItem<String>(
                                          value: 'edit',
                                          child: Row(
                                            children: [
                                              Icon(Icons.edit),
                                              SizedBox(width: 8),
                                              Text('Edit'),
                                            ],
                                          )),
                                      const PopupMenuItem(
                                          value: 'delete',
                                          child: Row(
                                            children: [
                                              Icon(Icons.delete),
                                              SizedBox(width: 8),
                                              Text("Delete"),
                                            ],
                                          ))
                                    ]);
                                if (action == 'edit') {
                                  final updatedPost = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditPostPage(),
                                    ),
                                  );
                                  if (updatedPost != null) {
                                    setState(() {
                                      widget.userProfile.posts[index] =
                                          updatedPost;
                                    });
                                  }
                                } else if (action == 'delete') {
                                  deletePostHandler(selectedPost.id);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                          // fit: FlexFit.loose,
                          child: post.postVideo != null &&
                                  post.postVideo!.isNotEmpty
                              ? buildVideoSection(post)
                              : buildImageSection(post)),
                      Padding(
                        padding: const EdgeInsets.only(
                          right: 180,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: Icon(
                                post.liked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: post.liked ? Colors.red : Colors.grey,
                              ),
                              onPressed: () => handleLike(post),
                            ),
                            Text("${post.likeCount}"),
                            IconButton(
                              icon: SvgPicture.asset(
                                'assets/svgs/comment.svg',
                                height: 35,
                                width: 35,
                              ),
                              
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => CommentsPage(
                                              postId: post.id,
                                              token: token!,
                                              scrollCommentId:
                                                  widget.scrollToCommentId,
                                            )));
                              },
                            ),
                            Text(
                              "${post.comments.length}",
                              style: TextStyle(fontSize: 12),
                              ),
                            IconButton(
                              icon: SvgPicture.asset(
                                'assets/svgs/share.svg',
                                height: 25,
                                width: 28,
                              ),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 20,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Transform.translate(
                              offset: Offset(0.h, -10.w),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    post.content,
                                    maxLines: isExpanded ? null : 2,
                                    overflow: isExpanded
                                        ? TextOverflow.visible
                                        : TextOverflow.ellipsis,
                                  ),
                                  GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          expandedMap[post.id] = !isExpanded;
                                        });
                                      },
                                      child: Text(
                                          isExpanded
                                              ? 'Show less'
                                              : 'Continue reading',
                                          style:
                                              TextStyle(color: Colors.blue))),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ]);
              })),
    );
  }

  Widget buildVideoSection(Post post) {
    final String videoUrl = ApiService().formatVideoUrl(post.postVideo!);
    return VideoPost(
      key: ValueKey(post.id),
      url: videoUrl,
      id: post.id.toString(),
      // controller: _VideoController[post.id]
    );
  }

  Widget buildImageSection(Post post) {
    return Container(
      height: 410.h,
      width: double.infinity.w,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.white70),
        image: DecorationImage(
            image: post.postImage != null && post.postImage!.isNotEmpty
                ? NetworkImage(
                    _apiService.formatImageUrl(post.postImage!))
                : AssetImage('assets/images/nouser.png') as ImageProvider,
            fit: BoxFit.cover),
      ),
    );
  }

  String _formatTime(String timestamp) {
    try {
      final time = DateTime.parse(timestamp).toLocal();
      return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return "Unknown time";
    }
  }
}
