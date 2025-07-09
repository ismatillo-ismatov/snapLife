import 'package:flutter/material.dart';
import 'package:ismatov/api/friends_service.dart';
import 'package:ismatov/api/post_service.dart';
import 'package:ismatov/models/post.dart';
import 'package:ismatov/models/userProfile.dart';
import 'package:ismatov/widgets/post_item.dart';
import 'package:ismatov/widgets/posts.dart';
import 'package:ismatov/widgets/post_item.dart';

class HomePage extends StatefulWidget {
  final String token;
  const HomePage({super.key, required this.token});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // late Future<List<dynamic>> friendPosts;
  List<Post> friendPosts = [];
  bool isLoading = true;

  @override
  void initState(){
    super.initState();
    loadingFriendPosts();
  }

  Future<void> loadingFriendPosts() async {
    try {
      final data = await PostService().fetchFriendPosts(widget.token);
      final posts = data.map((e) => Post.fromJson(e)).toList();
      posts.shuffle();
      setState(() {
        friendPosts = posts;
        isLoading = false;
      });
    } catch(e) {
      print("Error loading posts: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  // Future<void> loadingFriendPosts() async {
  //   try {
  //     final data = await PostService().fetchFriendPosts(widget.token);
  //     setState(() {
  //     friendPosts = data.map((e) => Post.fromJson(e)).toList();
  //     isLoading = false;
  //     });
  //   } catch(e) {
  //     print("Error loading posts: $e");
  //     setState(() {
  //       isLoading = false;
  //     });
  //   }
  // }



  void handleLike(Post updatePost) {
    final index = friendPosts.indexWhere((p) => p.id == updatePost.id);
    if (index != -1 ) {
      setState(() {
        friendPosts[index] = updatePost;
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar:  AppBar(title: Text("Home")),
        body: isLoading
      ? Center(child: CircularProgressIndicator(),)
            : ListView.builder(
          scrollDirection: Axis.vertical,
          itemCount: friendPosts.length,
          itemBuilder: (context,index) {
            final post = friendPosts[index];
            return PostItem(
              post: post,

              token: widget.token,
              onLikeToggle: handleLike,
            );



          },
        )
     
                );
              }

            }