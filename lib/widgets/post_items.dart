import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:ismatov/main.dart';
import 'package:ismatov/models/post.dart';
import 'package:ismatov/models/userProfile.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PostPage extends StatefulWidget {
  // final Post post;
  final UserProfile userProfile;

  const PostPage({required this.userProfile, Key?key}) :super(key: key);
  
  @override
  _ItemPostState createState() => _ItemPostState();
}
class _ItemPostState extends State<PostPage>{
  void initState(){
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Posts"),
        actions: [

        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
      child: Column(
        children: [
      Container(
        height: 50.h,
        width: 50.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          borderRadius: BorderRadius.circular(80),
          image: DecorationImage(
              image: widget.userProfile.profileImage != null && widget.userProfile.profileImage!.isNotEmpty
                  ? NetworkImage(widget.userProfile.profileImage!)
                  : AssetImage('assets/images/nouser.png') as ImageProvider,
            fit: BoxFit.cover,
          )
        ),
      ),
      Text(widget.userProfile.userName),
        ]
      ),
      )
    );
    // return CustomScrollView(
    //     slivers: [
    //       SliverList(
    //           delegate: SliverChildBuilderDelegate(
    //                   (context,index) {
    //                 final post = widget.userProfile.posts[index];
    //                 return Card(
    //                     child: GridView.builder(
    //                      
    //                       physics: NeverScrollableScrollPhysics(),
    //                       shrinkWrap: true,
    //                       itemCount: widget.userProfile.posts.length,
    //                       itemBuilder: (context, index) {
    //                         final post = [index];
    //                         // return Card(
    //                             margin: EdgeInsets.all(2)
    //                             child: Padding(
    //                                 padding: EdgeInsets.all(10),
    //                                 child: Column(
    //                                     crossAxisAlignment: CrossAxisAlignment
    //                                         .start,
    //                                     children: [
    //                                       // Text(widget.userProfile.posts.owner),
    //                                       if (widget.userProfile.posts.postImage!= null &&
    //                                           widget.userProfile.posts.postImage!.isNotEmpty)
    //                                         Container(
    //                                           height: 200,
    //                                           width: double.infinity,
    //                                           decoration: BoxDecoration(
    //                                             borderRadius: BorderRadius
    //                                                 .circular(25),
    //                                             image: DecorationImage(
    //                                               image: widget.userProfile.post.postImage !=
    //                                                   null &&
    //                                                   widget.userProfile.post.postImage!.isNotEmpty
    //                                                   ? NetworkImage(
    //                                                   widget.userProfile.post.postImage!)
    //                                                   : AssetImage(
    //                                                   'assets/images/nouser.png') as ImageProvider,
    //                                               fit: BoxFit.cover,
    //                                             ),
    //                                           ),
    //                                         ),
    //                                     ]
    //                                 )
    //                             )
    //                         // );
    //                       },
    //                     )
    //                 );
    //               }
    //           )
    //       )
    //     ]
    // );

  }
}




    
   



// ListView.builder(
// physics: NeverScrollableScrollPhysics(),
// shrinkWrap: true,
// itemCount: widget.userProfile.posts.length,
// itemBuilder: (context,index){
// final post = widget.userProfile.posts[index];
// return Card(
// margin: EdgeInsets.all(2),
// child: Padding(
// padding: EdgeInsets.all(10),
// child: Column(
// crossAxisAlignment: CrossAxisAlignment.start,
// children:[
// Text(post.owner),
// // ListTile(
// if (post.postImage != null && post.postImage!.isNotEmpty)
// Container(
// height: 200,
// width: double.infinity,
// decoration: BoxDecoration(
// borderRadius: BorderRadius.circular(25),
// image: DecorationImage(
// image: post.postImage  != null && post.postImage!.isNotEmpty
// ? NetworkImage(post.postImage!)
//     : AssetImage('assets/images/nouser.png') as ImageProvider,
// fit: BoxFit.cover,
// ),
// ),
// ),
// Text(
// post.content,
// style:TextStyle(
// fontSize: 18,
// fontWeight: FontWeight.bold,
// )
// )
// // title: Text(post.content),
// // subtitle: Text(post.postDate.toString()),
// // )
// ],
// ),
// )
//
// );
// }
// )
