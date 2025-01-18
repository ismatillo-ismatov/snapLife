import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ismatov/api/api_service.dart';
import 'package:ismatov/api/post_service.dart';
import 'package:ismatov/models/post.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class EditPostPage extends StatefulWidget {
  final Post post;

  EditPostPage({required this.post});

  @override
  _EditPostPageState createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> {
  final TextEditingController contentController = TextEditingController();
  String? postImagePath;

  @override
  void initState() {
    super.initState();
    contentController.text = widget.post.content;
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null){

      setState(() {

        postImagePath = pickedFile.path;
      });
    } else {
      print('No image selected.');
    }
  }

  Future<void> updatePostHandler() async {
    try{
      String? token = await ApiService().getUserToken();
      final updatedPost = await PostService().updatePost(
        postId: widget.post.id,
        content: contentController.text,
        postImagePath: postImagePath,
        token: token!,
      );
      Navigator.pop(context,updatedPost);
      print('Post movfaqiyatli yangilandi:${updatedPost.id}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Post movfaqiyatli yangilandi')),
      );

    } catch (e) {
      print("Post yangilashda xatolik: ${e}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Post yangilashda  xatolik')),
      );

    }
  }

@override
Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Post'),
        backgroundColor: Colors.black,
      ),
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: contentController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Post conent',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              if (postImagePath != null) ...[
                SizedBox(
                  width: double.infinity.w,
                  height: 300.h,
                  child: Image.file(
                    File(postImagePath!),
                    fit: BoxFit.cover,
                  ),
                )

              ],
              ElevatedButton.icon(
                  onPressed: pickImage,
                  icon: Icon(Icons.add_photo_alternate),
                  label: Text('Change Image/video'),
              ),
              // SizedBox(height: 16),
              ElevatedButton(
                onPressed: updatePostHandler,
                child: Text('Update Post'),
              ),
            ],
      ),
      ),
    );
}

}