import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ismatov/api/api_service.dart';
import 'package:ismatov/api/user_service.dart';
import 'package:ismatov/api/post_service.dart';
import 'package:ismatov/models/userProfile.dart';
import 'package:mime/mime.dart';

class CreatePostPage extends StatelessWidget {
  final TextEditingController contentController = TextEditingController();
  final ValueNotifier<String?> selectedFileNotifier = ValueNotifier(null);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Create Post",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserInfo(),
            const SizedBox(height: 16),
            _buildTextInput(),
            const SizedBox(height: 16),
            _buildAddMediaButton(),
            const SizedBox(height: 12),
            _buildMediaPreview(),
            const SizedBox(height: 24),
            _buildCreateButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfo() {
    return FutureBuilder<String?>(
      future: ApiService().getUserToken(),
      builder: (context, tokenSnapshot) {
        if (!tokenSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final token = tokenSnapshot.data!;
        return FutureBuilder<UserProfile>(
          future: UserService().fetchUserProfile(token),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final user = snapshot.data!;
            return Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage: user.profileImage != null
                      ? NetworkImage(user.profileImage!)
                      : const AssetImage('assets/images/nouser.png')
                  as ImageProvider,
                ),
                const SizedBox(width: 12),
                Text(
                  user.userName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                )
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildTextInput() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: TextField(
          controller: contentController,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: "Nima yangilik?",
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget _buildMediaPreview() {
    return ValueListenableBuilder<String?>(
      valueListenable: selectedFileNotifier,
      builder: (context, path, _) {
        if (path == null) return const SizedBox.shrink();
        final isVideo = lookupMimeType(path)?.startsWith('video/') ?? false;

        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            height: 220,
            width: double.infinity,
            child: isVideo
                ? const Center(child: Icon(Icons.videocam, size: 50))
                : Image.file(File(path), fit: BoxFit.cover),
          ),
        );
      },
    );
  }

  Widget _buildAddMediaButton() {
    return OutlinedButton.icon(
      onPressed: () async {
        final picked = await ImagePicker().pickMedia();
        if (picked != null) {
          selectedFileNotifier.value = picked.path;
        }
      },
      icon: const Icon(Icons.add_photo_alternate_outlined),
      label: const Text("Rasm yoki video tanlash"),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.black87,
        side: BorderSide(color: Colors.grey.shade400),
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildCreateButton(BuildContext context) {
    return FilledButton(
      onPressed: () => _handleCreate(context),
      style: FilledButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: const Text(
        "Post yaratish",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  void _handleCreate(BuildContext context) async {
    final content = contentController.text.trim();
    final filePath = selectedFileNotifier.value;

    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Iltimos, matn kiriting")),
      );
      return;
    }
    try {
      final token = await ApiService().getUserToken();
      File? file = filePath != null ? File(filePath) : null;

      final mimeType = lookupMimeType(filePath ?? '');
      final isVideo = mimeType?.startsWith('video/') ?? false;

      final newPost = await PostService().createPost(
        content: content,
        token: token!,
        postImage: isVideo ? null : file,
        postVideo: isVideo ? file : null,
      );
      Navigator.pop(context, newPost);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Post muvaffaqiyatli yaratildi ✅")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Xatolik yuz berdi ❌")),
      );
    }
  }
}


