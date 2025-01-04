import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart';
import 'package:ismatov/main.dart';
import 'package:ismatov/widgets/comments_widget.dart';
import 'package:ismatov/widgets/profile.dart';
import 'package:ismatov/models/userProfile.dart';
import 'package:ismatov/models/likes.dart';
import 'package:ismatov/widgets/home.dart';
import 'package:hive/hive.dart';
import 'package:ismatov/models/post.dart';
import 'package:ismatov/api/api_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class PostPage extends StatefulWidget {
  final UserProfile  userProfile;
  final Post post;
  // final List<Post> posts;
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

  @override
  void initState(){
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
    ApiService().getUserToken().then((value){
      setState(() {
        token = value;
      });

    });
  }


  void handleLike(Post post, String token) async {
    final bool previousLiked = post.liked;
    final int? previousLikeId = post.likeId;

    setState(() {
      post.liked = !post.liked;
      post.likeCount += post.liked ? 1  : -1;
    }
    );
    try{
     final response = await ApiService().toggleLike(
        postId: post.id,
        isLiked: post.liked,
        token: token,
      );
     setState(() {
       post.likeId = response.likeId;
     });
      // post.likeId = response.likeId;
    } catch(e) {
      print('Error toggling like :$e');
     setState(() {
       post.liked  = previousLiked;
      post.likeCount += post.liked ? 1: -1;
      post.likeId  = previousLikeId;
     });
      if (e.toString().contains('No Like matches the given query')){
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text("No Like found for this post.")
            ),
        );
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    if (token == null ){
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

        body:PageView.builder(
          controller: PageController(initialPage: widget.initialIndex),
            physics: BouncingScrollPhysics(),
            scrollDirection: Axis.vertical,
            itemCount: widget.userProfile.posts.length,
            itemBuilder:(context,index) {
              Post post = widget.userProfile.posts[index];
              return SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                    children: [
                      Column(
                        children: [
                          Container(
                    height: 410.h,
                    width: 400.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.red),
                    image: DecorationImage(
                        image: post.postImage != null &&
                        post.postImage!.isNotEmpty
                            ? NetworkImage(post.postImage!)
                            : AssetImage('assets/images/nouser.png')as ImageProvider,
                      fit: BoxFit.cover
                    ),
                    ),


                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                            Container(
                              height: 50.h,
                              width: 50.w,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  // borderRadius: BorderRadius.circular(80),
                                  image: DecorationImage(
                                    image: widget.userProfile.profileImage != null && widget.userProfile.profileImage!.isNotEmpty
                                        ? NetworkImage(widget.userProfile.profileImage!)
                                        : AssetImage('assets/images/nouser.png') as ImageProvider,
                                    fit: BoxFit.cover,
                                  )
                              ),

                            ),

                            Transform.translate(
                                offset: Offset(60.w,-50.h),
                            child: Text(widget.userProfile.userName),
                            ),

                  ]
                          ),
                          ),

                          Padding(
                            padding: const EdgeInsets.only(
                              right: 180,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: Icon(
                                post.liked ? Icons.favorite : Icons.favorite_border,
                              color: post.liked ? Colors.red : Colors.grey,
                            ),
                                  onPressed: ()  => handleLike(widget.post,widget.token!),
                                ),
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
                                            // builder: (context) => CommentsPage(postId: post.id,token: token!
                                            builder: (context) => CommentsPage(postId: post.id, token: token!,)
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
                          // Transform.translate(
                          //   offset: Offset(160, -50),
                          //   child: IconButton(
                          //     icon: Icon(
                          //       post.save
                          //           ? Icons.bookmarks_rounded
                          //           : Icons.bookmarks_outlined,
                          //       size: 35,
                          //     ),
                          //     onPressed: () {
                          //       _toggleSave(post.id);
                          //     },
                          //   ),
                          // ),
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
                                              style: TextStyle(color: Colors.blue))),
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