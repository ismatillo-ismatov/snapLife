import 'package:flutter/material.dart';
import 'package:ismatov/api/api_service.dart';
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

  const ProfilePage({required this.userProfile, Key?key}) :super(key:key);


  @override
  _ProfilePageState createState() => _ProfilePageState();
}
class _ProfilePageState extends State<ProfilePage> {
  String? token;
  void initState() {
    super.initState();
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
                 onTap: () {
                   Navigator.push(
                     context,
                     MaterialPageRoute(
                       builder: (context) => PostPage(
                         post: post,
                         userProfile: widget.userProfile,
                         initialIndex: index,
                         token:token!

                       )
                     ),
                   );
                 },

             child: Card(
               margin: EdgeInsets.all(1),
                     child: Container(
                       decoration: BoxDecoration(
                         // border: Border.all(width: .0,color: Colors.black),
                         image: DecorationImage(
                             image: post.postImage != null &&
                             post.postImage!.isNotEmpty
                                 ? NetworkImage(post.postImage!)
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

// @override
// Widget build(BuildContext context) {
//   return SingleChildScrollView(
//     scrollDirection: Axis.vertical,
//     child: Column(
//       children: [
//         Padding(
//           padding:
//           const EdgeInsets.symmetric(horizontal: 10.0, vertical: 30.0),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 widget.userProfile.userName,
//                 style: TextStyle(fontSize: 20),
//               ),
//               SizedBox(
//                 width: 20,
//               ),
//               IconButton(
//                 icon: const Icon(FontAwesomeIcons.threads),
//                 onPressed: () {},
//               ),
//               IconButton(
//                 icon: const Icon(Icons.add_circle_outline_outlined),
//                 onPressed: () {},
//               ),
//               IconButton(
//                 icon: Icon(Icons.clear_all),
//                 onPressed: () {},
//               ),
//             ],
//           ),
//         ),
//         SizedBox(
//           height: 1,
//         ),
//         Padding(
//           padding: EdgeInsets.symmetric(vertical: 10),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               Padding(
//                 padding: const EdgeInsets.only(right: 20),
//               ),
//               Transform.translate(
//
//                 offset: Offset(-30, 0),
//                 child: Container(
//                   height: 80,
//                   width: 80,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     border: Border.all(color: Colors.white),
//                     image: DecorationImage(
//                       image: AssetImage(
//                           widget.userProfile.profileImage ?? 'assets/images/nouser.png'),
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                 ),
//               ),
//               Text('${widget.userProfile.posts.length}\nPost'),
//               Text("222\nFallowers"),
//               Text("222\nFallowing"),
//             ],
//           ),
//         ),
//         Padding(
//           padding: const EdgeInsets.only(right: 220),
//           child: Text(widget.userProfile.userName),
//         ),
//         Stack(
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 Container(
//                   height: 25,
//                   width: 130,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.only(
//                       topLeft: Radius.circular(10),
//                       topRight: Radius.circular(10),
//                       bottomLeft: Radius.circular(10),
//                       bottomRight: Radius.circular(10),
//                     ),
//                     border: Border.all(color: Colors.black),
//                   ),
//                   child: const Center(
//                     child: Text('Edit Profile'),
//                   ),
//                 ),
//                 // ),
//                 Container(
//                   height: 25,
//                   width: 130,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.only(
//                       topLeft: Radius.circular(10),
//                       topRight: Radius.circular(10),
//                       bottomRight: Radius.circular(10),
//                       bottomLeft: Radius.circular(10),
//                     ),
//                     border: Border.all(color: Colors.black),
//                   ),
//                   child: const Center(
//                     child: Text("Share profile"),
//                   ),
//                 ),
//                 IconButton(
//                   icon: Icon(MdiIcons.accountPlusOutline),
//                   onPressed: () {},
//                 )
//               ],
//             ),
//           ],
//         ),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             IconButton(
//               icon: const Icon(Icons.calendar_month_outlined),
//               onPressed: () {},
//               iconSize: 40,
//             ),
//             IconButton(
//               icon: Icon(Icons.add_to_queue_sharp),
//               onPressed: () {},
//               iconSize: 40,
//             ),
//             IconButton(
//               icon: Icon(Icons.perm_contact_cal_outlined),
//               onPressed: () {},
//               iconSize: 40,
//             ),
//           ],
//         ),
//         Container(
//           height: 2,
//           width: 400,
//           color: Colors.grey,
//         ),
//         GridView.builder(
//             shrinkWrap: true,
//             physics: NeverScrollableScrollPhysics(),
//             itemCount: widget.userProfile.posts.length,
//             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 3,
//               crossAxisSpacing: 1.0,
//               mainAxisSpacing: 1.0,
//               childAspectRatio: 1,
//             ),
//             itemBuilder: (context, index) {
//               return GestureDetector(
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) =>
//                           PostPage(userProfile: widget.userProfile,
//                             initialIndex: index,
//                           ),
//                     ),
//                   );
//                 },
//                 child: Container(
//                   width: 120,
//                   height: 120,
//                   decoration: BoxDecoration(
//                     border: Border.all(color: Colors.black),
//                     image: widget.userProfile.posts[index].postImage != null
//                         ? DecorationImage(
//                       image: AssetImage(widget.userProfile.posts[index].postImage!),
//                       fit: BoxFit.cover,
//                     )
//                         : null,
//                   ),
//                   // child: widget.userProfile.posts[index].videoPath !=null
//                   //     ? VideoPlayerWidget(videoPath: widget.userProfile.posts[index].videoPath!)
//                   //     :null,
//                 ),
//               );
//             })
//       ],
//     ),
//   );
// }
}