import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ismatov/api/api_service.dart';
import 'package:ismatov/api/user_service.dart';
import 'package:ismatov/api/post_service.dart';
import 'package:ismatov/models/post.dart';
import 'package:ismatov/widgets/profile.dart';
import 'package:http/http.dart' as http;



class CreatePostPage extends StatelessWidget {
  final TextEditingController contentController = TextEditingController();
  final ValueNotifier<String?> postImagePathNotifier = ValueNotifier(null);




  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null){
      File imageFile = File(pickedFile.path);
      // await PostService().createPost('New Post', imageFile);
    } else {
      print('No image selected.');
    }
  }
  @override
  Widget build(BuildContext context) {
    String? postImagePath;
    return Scaffold(
      appBar: AppBar(
        title: Text("Create Post"),
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
                labelText: 'Post content',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ValueListenableBuilder<String?>(
                valueListenable: postImagePathNotifier,
                builder: (context, postImagePath, child) {
                  return Column(
                    children: [
                      ElevatedButton.icon(
                          onPressed: () async {
                            final pickedFile = await ImagePicker().pickImage(
                                source: ImageSource.gallery,
                            );
                            if (pickedFile != null){
                              postImagePathNotifier.value = pickedFile.path;
                              print('Tanlangan file: ${pickedFile.path}');
                            } else {
                              print('File tanlanmadi');
                            }
                      },
                        icon: Icon(Icons.add_photo_alternate),
                        label: Text('Add Image/Video'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[800]
                        ),
                      ),
                      if (postImagePath != null)...[
                        SizedBox( height: 8,  ),
                        Text('Tanlangan fayl: $postImagePath')

                      ]
                    ],
                  );
                }
            ),

            SizedBox(height: 16),
            ElevatedButton(
                onPressed: () async {
                  String content = contentController.text;
                  String? token = await ApiService().getUserToken();
                  File? imageFile = postImagePathNotifier.value != null
                  ? File(postImagePathNotifier.value!)
                  : null;
                  try {
                    final newPost = await PostService().createPost(
                  content: content,
                  token: token!,
                  postImage: imageFile,
                  );
                  print('Post movfaqiyatli nashr qilindi:${newPost.id}');
                  Navigator.pop(context,newPost);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Post movfaqiyatli yaratildi')),
                  );
                  } catch(e) {
                    print("Post yaratishda xatolik $e");
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Post yaratishda xatolik')),
                    );
                  }
                },
              child: Text('Create'),


                  // if (content.isNotEmpty) {
                  //   print('Post nashr qilinmoqda...');
                  //   try {
                  //     final token = await ApiService().getUserToken();
                  //     final postImagePath = postImagePathNotifier.value;
                  //     // final post = await PostService().createPost(content, imageFile);
                  //     final newPost = await PostService().createPost(
                  //         content: content,
                  //         postImage: postImage,
                  //         token: token!
                  //     );
                  //     print('Post movfaqiyatli nashr qilindi');
                  //     Navigator.pop(context,newPost);
                  //     if (context.findAncestorStateOfType<ProfilePageState>() != null){
                  //       context.findAncestorStateOfType<ProfilePageState>()?.refreshPosts();
                  //     }
                  //     ScaffoldMessenger.of(context).showSnackBar(
                  //       SnackBar(content: Text('Post movfaqiyatli nashr qilindi!')),
                  //     );
                  //     // Navigator.pop(context,post);
                  //     // contentController.clear();
                  //     // postImagePathNotifier.value = null;
                  //   } catch (e){
                  //     print('Xatolik $e');
                  //     ScaffoldMessenger.of(context).showSnackBar(
                  //       SnackBar(content: Text('Post nashr qilishda xatolik!')),
                  //     );
                  //   }
                  // } else {
                  //   print('Malumotni toldiring');
                  //   ScaffoldMessenger.of(context).showSnackBar(
                  //     SnackBar(content: Text('Post Mazmunini kiriting')),
                  //   );
                  // }
                ),


          ],
        ),
      ),
    );
  }
}