import 'package:flutter/material.dart';
import 'package:ismatov/api/api_service.dart';
// import 'package:ismatov/widgets/video_player_widget.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ismatov/widgets/home.dart';
import 'package:ismatov/models/userProfile.dart';
import 'package:ismatov/widgets/posts.dart';
import 'package:ismatov/models/post.dart';
import 'dart:convert';


// class UserProfile {
//   final int userId;
//   final String userName;
//   final String userImage;
//   final List<Post> posts;
//
//   UserProfile({
//     required this.userId,
//     required this.userName,
//     required this.userImage,
//     required this.posts,
//   });
// }

class ProfilePage extends StatefulWidget {
  final UserProfile userProfile;

  const ProfilePage({required this.userProfile});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}
class _ProfilePageState extends State<ProfilePage> {
  // late Future<UserProfile> userProfileFuture;
  void initState() {
    super.initState();


  }

  // void _toggleLike(int id) {
  //   setState(() {
  //     Post post = widget.userProfile.posts.firstWhere((post) => post.id == id);
  //     post.isLiked = !post.isLiked;
  //   });
  //
  //   void _toggleSave(int id) {
  //     setState(() {
  //       Post post =
  //       widget.userProfile.posts.firstWhere((post) => post.id == id);
  //       post.save = !post.save;
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        children: [
          Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 10.0, vertical: 30.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.userProfile.userName,
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(
                  width: 20,
                ),
                IconButton(
                  icon: const Icon(FontAwesomeIcons.threads),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline_outlined),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(Icons.clear_all),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          SizedBox(
            height: 1,
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 20),
                ),
                Transform.translate(

                  offset: Offset(-30, 0),
                  child: Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white),
                      image: DecorationImage(
                        image: AssetImage(
                            widget.userProfile.profileImage ?? 'assets/nouser.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Text('${widget.userProfile.posts.length}\nPost'),
                Text("222\nFallowers"),
                Text("222\nFallowing"),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 220),
            child: Text(widget.userProfile.userName),
          ),
          Stack(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    height: 25,
                    width: 130,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                      border: Border.all(color: Colors.black),
                    ),
                    child: const Center(
                      child: Text('Edit Profile'),
                    ),
                  ),
                  // ),
                  Container(
                    height: 25,
                    width: 130,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                        bottomLeft: Radius.circular(10),
                      ),
                      border: Border.all(color: Colors.black),
                    ),
                    child: const Center(
                      child: Text("Share profile"),
                    ),
                  ),
                  IconButton(
                    icon: Icon(MdiIcons.accountPlusOutline),
                    onPressed: () {},
                  )
                ],
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.calendar_month_outlined),
                onPressed: () {},
                iconSize: 40,
              ),
              IconButton(
                icon: Icon(Icons.add_to_queue_sharp),
                onPressed: () {},
                iconSize: 40,
              ),
              IconButton(
                icon: Icon(Icons.perm_contact_cal_outlined),
                onPressed: () {},
                iconSize: 40,
              ),
            ],
          ),
          Container(
            height: 2,
            width: 400,
            color: Colors.grey,
          ),
          GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: widget.userProfile.posts.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 1.0,
                mainAxisSpacing: 1.0,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PostPage(userProfile: widget.userProfile,
                              initialIndex: index,
                            ),
                      ),
                    );
                  },
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      image: widget.userProfile.posts[index].postImage != null
                          ? DecorationImage(
                        image: AssetImage(widget.userProfile.posts[index].postImage!),
                        fit: BoxFit.cover,
                      )
                          : null,
                    ),
                    // child: widget.userProfile.posts[index].videoPath !=null
                    //     ? VideoPlayerWidget(videoPath: widget.userProfile.posts[index].videoPath!)
                    //     :null,
                  ),
                );
              })
        ],
      ),
    );
  }

}