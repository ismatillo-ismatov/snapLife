import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ismatov/widgets/profile.dart';
import 'package:ismatov/models/userProfile.dart';
import 'package:ismatov/widgets/home.dart';
import 'package:ismatov/models/post.dart';

class PostPage extends StatefulWidget {
  final UserProfile  userProfile;
  final int initialIndex;
  const PostPage({
    Key? key,
    required this.userProfile,
    required this.initialIndex,
  }) : super(key: key);

  @override
  _PostPageState createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  bool isExpanded = false;

  void _toggleLike(int id) {
    setState(() {
      var post = widget.userProfile.posts.firstWhere((p) => p.id == id);
      post.isLiked = !post.isLiked;
    });
  }

  void _toggleSave(int id) {
    setState(() {
      var post = widget.userProfile.posts.firstWhere((p) => p.id == id);
      post.save = !post.save;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                            height: 510,
                            width: 400,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.greenAccent),
                              image: post.imagePath != null
                                  ?DecorationImage(
                                image: AssetImage(post.imagePath!),
                                fit: BoxFit.cover,
                              ) :null,
                            ),

                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 80,
                                      top: 20,
                                    ),
                                    child: Text(
                                      post.userName,
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.all(20),
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 2),
                                      image: DecorationImage(
                                        image: AssetImage(post.profileImage),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ],
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
                                IconButton(
                                  icon: Icon(
                                    post.isLiked
                                        ? Icons.favorite
                                        : Icons.favorite_outline_sharp,
                                    size: 35,
                                    color: post.isLiked ? Colors.red : Colors
                                        .black,
                                  ),
                                  onPressed: () {
                                    _toggleLike(post.id);
                                  },
                                ),
                                IconButton(
                                  icon: SvgPicture.asset(
                                    'assets/svgs/comment.svg',
                                    height: 35,
                                    width: 35,
                                  ),
                                  onPressed: () {},
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
                          Transform.translate(
                            offset: Offset(160, -50),
                            child: IconButton(
                              icon: Icon(
                                post.save
                                    ? Icons.bookmarks_rounded
                                    : Icons.bookmarks_outlined,
                                size: 35,
                              ),
                              onPressed: () {
                                _toggleSave(post.id);
                              },
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
                                  offset: Offset(0, -40),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(post.userName),
                                      Text(
                                        post.postText,
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