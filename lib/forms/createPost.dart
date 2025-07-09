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




class CreatePostPage extends StatelessWidget {
  final TextEditingController contentController = TextEditingController();
  final ValueNotifier<String?> selectedFileNotifier = ValueNotifier(null);
  final ValueNotifier<bool>isImageNotifier = ValueNotifier(true);




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            "Create Post",
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
      child: Text("Yaratish"),
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
        SnackBar(content: Text("Post  movfaqiyatli yaratish "))
      );
    } catch (e){
      print("Post yaratishda xatolik");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Post yaratishda xatolik"))
      );
    }
    print("Post content: $content");
    print("tanlangan File: $filePath");
}
}