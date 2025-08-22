import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ismatov/api/api_service.dart';
import 'package:ismatov/api/user_service.dart';
import 'package:ismatov/api/post_service.dart';
import 'package:mime/mime.dart';
import 'package:ismatov/models/post.dart';
import 'package:ismatov/widgets/profile.dart';
import 'package:http/http.dart' as http;
import 'package:visibility_detector/visibility_detector.dart';




class EditPostPage extends StatelessWidget {
  final TextEditingController contentController = TextEditingController();
  final ValueNotifier<String?> selectedFileNotifier = ValueNotifier(null);
  final ValueNotifier<bool>isImageNotifier = ValueNotifier(true);




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "update Post",
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
            child: Column(
              children: [
                _buildUserInfo(),
                const SizedBox(height: 10),
                _buildTextInput(),
                const SizedBox(height: 16),
                _buildAddMediaButton(),

                _buildMediaPreview(),
                const SizedBox(height: 20),
                _buildCreateButton(context),


              ],
            )
        ),



      ),
    );
  }
  Widget _buildUserInfo() {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundImage: AssetImage('assets/images/nouser.png'),
        ),
        const SizedBox(width: 12,),
        Text(
          'ismatillo',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        )
      ],
    );
  }


  Widget _buildTextInput() {
    return TextField(
      controller: contentController,
      maxLines: 5,
      decoration: InputDecoration(
        hintText: "Nima yangilik",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        fillColor: Colors.grey[100],
        filled: true,
      ),
    );
  }


  Widget _buildMediaPreview() {
    return ValueListenableBuilder<String?>(
        valueListenable: selectedFileNotifier,
        builder: (context,path, _) {
          if(path == null) return SizedBox.shrink();
          final isVideo = lookupMimeType(path)?.startsWith('video/') ?? false;

          return Container(
              margin: const EdgeInsets.only(top: 8),
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: isVideo
                  ? Center(child: Icon(Icons.videocam,size: 50,),)
                  : ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(File(path), fit:BoxFit.cover,
                  )
              )
          );
        }
    );
  }


  Widget _buildAddMediaButton() {
    return ElevatedButton.icon(
      onPressed: () async {
        final picked = await ImagePicker().pickMedia();
        if (picked != null ) {
          selectedFileNotifier.value = picked.path;
        }
      },
      icon: Icon(Icons.add_photo_alternate_outlined),
      label: Text("Rasm yoki video tanlash"),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey[200],
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
    );
  }

  Widget _buildCreateButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _handleCreate(context),
      child: Text("yangilash"),
      style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          minimumSize: Size(double.infinity,48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          )
      ),
    );
  }

  void _handleCreate(BuildContext context) async {
    final content = contentController.text.trim();
    final filePath = selectedFileNotifier.value;

    if (content.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Iltimos, mant kiriting")),
      );
      return;
    }
    try {
      final token = await ApiService().getUserToken();
      File? file = filePath != null ? File(filePath): null;

      final mimeType = lookupMimeType(filePath ?? '');
      final isVideo = mimeType?.startsWith('video/') ?? false;

      final newPost = await PostService().createPost(
          content: content,
          token: token!,
          postImage: isVideo? null :file,
          postVideo: isVideo? file :null
      );
      Navigator.pop(context, newPost);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Post  movfaqiyatli yangilandai "))
      );
    } catch (e){
      print("Post yangilashda xatolik");
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Post yangilashda xatolik"))
      );
    }
    print("Post content: $content");
    print("tanlangan File: $filePath");
  }
}





// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:hive/hive.dart';
// import 'package:http/http.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:ismatov/api/api_service.dart';
// import 'package:ismatov/api/post_service.dart';
// import 'package:ismatov/models/post.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
//
//
// class EditPostPage extends StatefulWidget {
//   final Post post;
//
//   EditPostPage({required this.post});
//
//   @override
//   _EditPostPageState createState() => _EditPostPageState();
// }
//
// class _EditPostPageState extends State<EditPostPage> {
//   final TextEditingController contentController = TextEditingController();
//   String? postImagePath;
//
//   @override
//   void initState() {
//     super.initState();
//     contentController.text = widget.post.content;
//   }
//
//   Future<void> pickImage() async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null){
//
//       setState(() {
//
//         postImagePath = pickedFile.path;
//       });
//     } else {
//       print('No image selected.');
//     }
//   }
//
//   Future<void> updatePostHandler() async {
//     try{
//       String? token = await ApiService().getUserToken();
//       final updatedPost = await PostService().updatePost(
//         postId: widget.post.id,
//         content: contentController.text,
//         postImagePath: postImagePath,
//         token: token!,
//       );
//       Navigator.pop(context,updatedPost);
//       print('Post movfaqiyatli yangilandi:${updatedPost.id}');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Post movfaqiyatli yangilandi')),
//       );
//
//     } catch (e) {
//       print("Post yangilashda xatolik: ${e}");
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Post yangilashda  xatolik')),
//       );
//
//     }
//   }
//
// @override
// Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Edit Post'),
//         backgroundColor: Colors.black,
//       ),
//       body: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               TextField(
//                 controller: contentController,
//                 maxLines: 5,
//                 decoration: InputDecoration(
//                   labelText: 'Post conent',
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//               SizedBox(height: 16),
//               if (postImagePath != null) ...[
//                 SizedBox(
//                   width: double.infinity.w,
//                   height: 300.h,
//                   child: Image.file(
//                     File(postImagePath!),
//                     fit: BoxFit.cover,
//                   ),
//                 )
//
//               ],
//               ElevatedButton.icon(
//                   onPressed: pickImage,
//                   icon: Icon(Icons.add_photo_alternate),
//                   label: Text('Change Image/video'),
//               ),
//               // SizedBox(height: 16),
//               ElevatedButton(
//                 onPressed: updatePostHandler,
//                 child: Text('Update Post'),
//               ),
//             ],
//       ),
//       ),
//     );
// }
//
// }