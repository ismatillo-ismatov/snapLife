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



class PostPage extends StatefulWidget {
  final UserProfile  userProfile;
  final Post post;
  final int initialIndex;
  final String token;

  const PostPage({
    Key? key,
    required this.userProfile,
    required this.post,
    required this.initialIndex,
    required this.token,
  }) : super(key: key);

  @override
  _PostPageState createState() => _PostPageState();
}



class _PostPageState extends State<PostPage> {
  late PageController _pageController;
  bool isExpanded = false;
  String? token;
   VideoPlayerController? _videoPlayerController;
  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
    UserService().getUserToken().then((value) {
      setState(() {
        token = value;
      });
      if (token != null) {
        PostService().fetchPosts(token!);
      }
    });
    if (widget.post.postVideo != null && widget.post.postVideo!.isNotEmpty){
      _videoPlayerController = VideoPlayerController.network(widget.post.postVideo!)
      ..initialize().then((_){
        setState(() {});

    }
      ).catchError((error){
        print('Video yuklashda xatolik $error');
        setState(() {
        _videoPlayerController = null;
        });
      })
    ..setLooping(true);

    }

  }

    @override
    void dispose() {
      _pageController.dispose();
      _videoPlayerController?.dispose();
      super.dispose();
    }


    Future<void> deletePostHandler(int postId) async {
      try {
        String? token = await ApiService().getUserToken();
        await PostService().deletePost(postId: postId, token: token!);
        setState(() {
          widget.userProfile.posts.removeWhere((post) => post.id == postId);
        });
        // deletePostLocally(postId);
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


    // void handleLike(Post post, String token) async {
    //   final bool previousLiked = post.liked;
    //   final int? previousLikeId = post.likeId;
    //
    //   setState(() {
    //     post.liked = !post.liked;
    //     post.likeCount += post.liked ? 1  : -1;
    //   }
    //   );
    //   try{
    //    final response = await PostService().toggleLike(
    //       postId: post.id,
    //       isLiked: post.liked,
    //       token: token,
    //     );
    //    setState(() {
    //      post.likeId = response.likeId;
    //    });
    //     // post.likeId = response.likeId;
    //   } catch(e) {
    //     print('Error toggling like :$e');
    //    setState(() {
    //      post.liked  = previousLiked;
    //     post.likeCount += post.liked ? 1: -1;
    //     post.likeId  = previousLikeId;
    //    });
    //     if (e.toString().contains('No Like matches the given query')){
    //       ScaffoldMessenger.of(context).showSnackBar(
    //           SnackBar(
    //               content: Text("No Like found for this post.")
    //           ),
    //       );
    //     }
    //   }
    // }


    @override
    Widget build(BuildContext context) {
      if (token == null) {
        return Center(child: CircularProgressIndicator());
      }
      return Scaffold(
          appBar: AppBar(
            title: Row(
                children: [
                  Text("Posts",
                      style: TextStyle(
                        fontSize: 18,
                        // color: Colors.white,
                      )),
                ]
            ),
          ),

          body: PageView.builder(
              controller: PageController(initialPage: widget.initialIndex),
              physics: BouncingScrollPhysics(),
              scrollDirection: Axis.vertical,
              itemCount: widget.userProfile.posts.length,
              itemBuilder: (context, index) {
                Post post = widget.userProfile.posts[index];
                return SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              // crossAxisAlignment: CrossAxisAlignment.,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  height: 40.h,
                                  width: 40.w,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                        image: widget.userProfile
                                            .profileImage != null &&
                                            widget.userProfile.profileImage!
                                                .isNotEmpty
                                            ? NetworkImage(
                                            widget.userProfile.profileImage!)
                                            : AssetImage(
                                            'assets/images/nouser.png') as ImageProvider,
                                        fit: BoxFit.cover,
                                      )

                                  ),
                                  child: Transform.translate(
                                    offset: Offset(60.w, 00.h),
                                    child: Text(widget.userProfile.userName),
                                  ),


                                ),


                                IconButton(
                                  icon: Icon(Icons.more_vert),
                                  onPressed: () async {
                                    final selectedPost = widget.userProfile
                                        .posts[index];
                                    final action = await showMenu<String>(
                                        context: context,
                                        position: RelativeRect.fromLTRB(
                                            100, 100, 100, 100),
                                        items: [
                                          PopupMenuItem<String>(
                                              value: 'edit',
                                              child: Row(
                                                children: [
                                                  Icon(Icons.edit),
                                                  SizedBox(width: 8),
                                                  Text('Edit')
                                                ],
                                              )
                                          ),
                                          PopupMenuItem(
                                              value: 'delete',
                                              child: Row(
                                                  children: [
                                                    Icon(Icons.delete),
                                                    SizedBox(width: 8),
                                                    Text('Delete')
                                                  ]
                                              )
                                          )
                                        ]
                                    );
                                    if (action == 'edit') {
                                      final updatedPost = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              EditPostPage(post: selectedPost),

                                        ),
                                      );
                                      if (updatedPost != null) {
                                        setState(() {
                                          widget.userProfile.posts[index] =
                                              updatedPost;
                                        });
                                      }
                                    } else if (action == "delete") {
                                      deletePostHandler(selectedPost.id);
                                    }
                                  },

                                ),


                              ],
                            ),
               if (_videoPlayerController != null && _videoPlayerController!.value.isInitialized)
                 AspectRatio(
                     aspectRatio: _videoPlayerController!.value.aspectRatio,
                   child: VideoPlayer(_videoPlayerController!)
                 )
                else if(post.postVideo != null && post.postVideo!.isNotEmpty)
                  Center(child: Text("video yuklanmadi yoki mavjud emas")
                  ),
                  // Center(child: CircularProgressIndicator(),),

               Container(
                height: 410.h,
                width: double.infinity.w,
                decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.red),
                image: DecorationImage(
                image: post.postImage != null &&
                post.postImage!.isNotEmpty
                ? NetworkImage(
                ApiService().formatImageUrl(
                post.postImage!))
                    : AssetImage(
                'assets/images/nouser.png') as ImageProvider,
                fit: BoxFit.cover
                ),
                ),


                ),


                            Padding(
                              padding: const EdgeInsets.only(
                                right: 180,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  //     IconButton(
                                  //       icon: Icon(
                                  //     post.liked ? Icons.favorite : Icons.favorite_border,
                                  //   color: post.liked ? Colors.red : Colors.grey,
                                  // ),
                                  //       onPressed: ()  => handleLike(widget.post,widget.token!),
                                  //     ),
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
                                              builder: (context) =>
                                                  CommentsPage(postId: post.id,
                                                    token: token!,)
                                          )
                                      );
                                    },
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
                                      crossAxisAlignment: CrossAxisAlignment
                                          .start,
                                      children: [
                                        // Text(post.owner.toString()),
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
                                                isExpanded = !isExpanded;
                                              });
                                            },
                                            child: Text(
                                                isExpanded
                                                    ? 'Show less'
                                                    : 'Continue reading',
                                                style: TextStyle(
                                                    color: Colors.blue)
                                            )

                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      ]
                  ),
                );
              }

          )

      );
    }
}