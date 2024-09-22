import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:instagram_clone/home.dart';

class Post {
  final int id;
  // final String userName;
  final String profileImage;
  final String postTitle;
  final String imagePath;
  final String postText;
  bool isLike;
  bool save;

  Post({
    required this.id,
    // required this.userName,
    required this.profileImage,
    required this.postTitle,
    required this.imagePath,
    required this.postText,
    this.isLike = false,
    this.save = false,
});
}

class UserProfile {
  final int userId;
  final String userName;
  final String userImage;
  List<Post> posts;

  UserProfile({
    required this.userId,
    required this.userName,
    required this.userImage,
    required this.posts,
  });
}

class ProfilePage extends StatefulWidget {
  final UserProfile userProfile;
  const ProfilePage({Key? key, required this.userProfile}):super(key: key);
  // UserProfile userProfile;
  // ProfilePage({required this.userProfile});
  @override
  _ProfilePageState createState() => _ProfilePageState();



  }

class _ProfilePageState extends State<ProfilePage>{
  bool isExpended = false;
  void initState() {
    super.initState();
    ProfilePage(
    userProfile: UserProfile(
        userId: 1,
        userName: "ismatov-ismatillo",
        userImage: "assets/images/ismatov.jpg",
        posts: [
          Post(
              id: 1,
              profileImage: 'assets/images/ismatov.jpg',
              imagePath: 'assets/images/3.jpg',
              postTitle: "hello everyone",
              postText: "Agar matn uzun bo‘lsa va faqat boshlang‘ich ikkita qatorni ko‘rsatib, qolgan qismini 'Continue reading' tugmasini bosganida"
          ),
          Post(
            id: 2,
            profileImage: "assets/images/ismatov.jpg",
            imagePath: 'assets/images/4.jpg',
            postTitle: "hello",
            postText: "asdadwdasdawdasdawdasdawd",
          )
        ]
    ),
    );
  }


  void _toggleLike(int id){
    setState(() {
      Post post = widget.userProfile.posts.firstWhere((post) => post.id == id);
      post.isLike = !post.isLike;
    });

  void _toggleSave(int id){
    setState(() {
      Post post = widget.userProfile.posts.firstWhere((post) => post.id == id);
      post.save = !post.save;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,

      child: Column(
        children:[
          Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 30.0
              ),
            child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.userProfile.userName,
              style: TextStyle(fontSize: 20),),
              SizedBox(
                width: 20,
              ),
              IconButton(
                icon: const Icon(FontAwesomeIcons.threads),
                onPressed: () {

                },
              ),

              IconButton(
                icon: const Icon(
                    Icons.add_circle_outline_outlined),
                onPressed: () {

                },
              ),
              IconButton(
                icon: Icon(Icons.clear_all),
                onPressed: () {},
              ),
              ],
            ),

          ),
          SizedBox(
            height: 10,
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
                    border: Border.all(color:Colors.white),
                    image: DecorationImage(
                        image:AssetImage(widget.userProfile.userImage),
                      fit: BoxFit.cover,
                    ),
                  ),



                ),
                ),


                Text('${widget.userProfile.posts.length}\nPosts'),
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
              // Transform.translate(offset: Offset(-120, 0),
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
                decoration:  BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                  ),
                  border: Border.all(color: Colors.black),
                ),
                child: const  Center(
                  child: Text("Share profile"),
                ),
              ),
              IconButton(
                  icon:Icon(MdiIcons.accountPlusOutline),
                onPressed: (){

                },
              )
            ],

          ),
    ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const  Icon(Icons.calendar_month_outlined),
                onPressed: (){


                },
                iconSize: 40,

              ),
              IconButton(
                  icon: Icon(Icons.add_to_queue_sharp),
                onPressed: (){

                },
                iconSize: 40,
              ),
              IconButton(
                  icon: Icon(Icons.assessment),
                onPressed: (){

                },

              ),

            ],

          ),

],
              ),


              );

  }
}