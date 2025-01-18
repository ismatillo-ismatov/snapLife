import 'package:flutter/material.dart';
import 'package:ismatov/api/api_service.dart';
import 'package:ismatov/api/post_service.dart';
import 'package:ismatov/forms/loginPage.dart';
// import 'package:ismatov/widgets/video_player_widget.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ismatov/widgets/home.dart';
import 'package:ismatov/models/userProfile.dart';
import 'package:ismatov/widgets/posts.dart';
import 'package:ismatov/models/post.dart';
import 'package:ismatov/widgets/post_items.dart' as items;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive/hive.dart';
import 'dart:convert';




class ProfilePage extends StatefulWidget {
  final UserProfile userProfile;
  const ProfilePage({
    required this.userProfile,
     Key?key}) :super(key:key);


  @override
  ProfilePageState createState() => ProfilePageState();
}
class ProfilePageState extends State<ProfilePage> {
  List<Post> userPosts = [];
  String? token;
  void initState() {
    super.initState();
    _checkForUpdates();
    fetchToken();
  }



void fetchToken() async {
    try {
      String? fetchedToken = await ApiService().getUserToken();
      setState(() {
        token = fetchedToken;
      });
    }catch(error){
      print("Error fetching token: $error");
    }
}

void refreshPosts() async {
    final updatedPosts = await PostService().fetchPosts(token!);
    setState(() {
      userPosts = updatedPosts;
    });
}
// void didChangeDependencies() {
//     super.didChangeDependencies();
//     WidgetsBinding.instance.addPersistentFrameCallback((_){
//       _checkForUpdates();
//     });
// }
void _checkForUpdates() async {
    if (widget.userProfile.posts.isEmpty){
      debugPrint("this user has no posts");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("no posts available to view.")),
      );
      return;
    }
    // int initialIndex = 0;
    // final deletedPostId = await Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //       builder: (context) => PostPage(
    //           userProfile: widget.userProfile,
    //           post: widget.userProfile.posts[initialIndex],
    //           initialIndex: initialIndex,
    //           token: token!
    //       )
    //   ),
    // );

    // if (deletedPostId != null){
    //   setState(() {
    //   widget.userProfile.posts.removeWhere((post) => post.id == deletedPostId);
    //   });
    // }
}

Future<List<Post>> fetchUpdatedPosts() async {
    String? token = await ApiService().getUserToken();
    return await PostService().fetchPosts(token!);
}

  @override
  Widget build(BuildContext context) {
    print("userName: ${widget.userProfile.userName}");
    print(widget.userProfile.profileImage);
    print(widget.userProfile.posts);
  if (token == null ){
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: Center(child: CircularProgressIndicator(),)
    );
  }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.userProfile.userName),
        actions: [
          IconButton(
              icon: Icon(Icons.logout),
            onPressed: () async {
                await ApiService().logout();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
            },
          )
        ],
      ),

    body: SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        children: [

          Padding(padding: EdgeInsets.symmetric(horizontal: 110.w),
             child: Container(
              height: 200.h,
              width: 200.w,

              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    ),
                // borderRadius: BorderRadius.circular(80),
                image: DecorationImage(
                  image: widget.userProfile.profileImage != null && widget.userProfile.profileImage!.isNotEmpty
                      ? NetworkImage(widget.userProfile.profileImage!)
                      : AssetImage('assets/images/nouser.png') as ImageProvider,
                  scale: 1.0,
                  fit: BoxFit.cover,

                ),

              ),
              child: Transform.translate(
                offset: Offset(60.w, 200.h),
                child: Text(widget.userProfile.userName,
                  style: TextStyle(fontSize: 18),
                ),
              ),

            ),

          ),
      Padding(padding: EdgeInsets.symmetric(horizontal: 50.w, vertical: 90.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
              Text("${widget.userProfile.posts.length}\nPosts"),
              Text("0\nfollowers"),
              Text("0\nfollowing"),
          ],

    ),
      ),



           GridView.builder(
             shrinkWrap: true,
             physics: NeverScrollableScrollPhysics(),
           gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
             crossAxisCount: 3,
             childAspectRatio: 1.0,
           ),
             itemCount: widget.userProfile.posts.length,
             itemBuilder: (context, index){
             final post = widget.userProfile.posts[index];
             return GestureDetector(
                 onTap: () async {
                   final deletedPostId = await Navigator.push(
                       context,
                       MaterialPageRoute(
                           builder: (context) => PostPage(
                               userProfile: widget.userProfile,
                               post: post,
                               initialIndex: index,
                               token: token!
                           )
                       ),
                   );
                   if (deletedPostId != null) {
                     setState(() {
                       widget.userProfile.posts.removeWhere((post) => post.id ==  deletedPostId);
                     });
                   }
                   // Navigator.push(
                   //   context,
                   //   MaterialPageRoute(
                   //     builder: (context) => PostPage(
                   //       post: post,
                   //       userProfile: widget.userProfile,
                   //       initialIndex: index,
                   //       token:token!                   //
                   //     )
                   //   ),
                   // );
                 },

             child: Card(
               margin: EdgeInsets.all(1),
                     child: Container(
                       decoration: BoxDecoration(
                         // border: Border.all(width: .0,color: Colors.black),
                         image: DecorationImage(
                             image: post.postImage != null &&
                             post.postImage!.isNotEmpty
                                 ? NetworkImage(ApiService().formatImageUrl(post.postImage!))
                                 :AssetImage('assets/images/nouser.png')
                                 as ImageProvider,
                           fit: BoxFit.cover,
                         )
                       ),
                     ),
             ),
                   );






             },
       ),



    ]
      )

    )
      );


  }

}