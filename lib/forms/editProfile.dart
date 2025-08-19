import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ismatov/api/user_service.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  String _gender = 'male';
  File? _imageFile;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    try {
      await UserService().updateUserProfile(
        userName: _usernameController.text,
        bio: _bioController.text,
        gender: _gender,
        imageFile: _imageFile,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Profil muvaffaqiyatli yangilandi')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Xatolik: ${e.toString()}")),
      );
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'Profilni tahrirlash',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Profile image
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircleAvatar(
                    radius: 55,
                    backgroundImage:
                    _imageFile != null ? FileImage(_imageFile!) : null,
                    child: _imageFile == null
                        ? const Icon(Icons.person, size: 50, color: Colors.grey)
                        : null,
                  ),
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black26,
                    ),
                    child: const Icon(Icons.camera_alt,
                        color: Colors.white, size: 30),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Username
            _buildInputCard(
              child: TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  hintText: 'Username',
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Bio
            _buildInputCard(
              child: TextField(
                controller: _bioController,
                decoration: const InputDecoration(
                  hintText: 'Bio',
                  border: InputBorder.none,
                ),
                maxLines: 3,
              ),
            ),
            const SizedBox(height: 12),

            // Gender
            _buildInputCard(
              child: DropdownButtonFormField<String>(
                value: _gender,
                items: ['male', 'female']
                    .map((gender) => DropdownMenuItem(
                  value: gender,
                  child: Text(gender),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _gender = value!;
                  });
                },
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "Gender",
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Save button
            _isLoading
                ? const CircularProgressIndicator()
                : FilledButton(
              onPressed: _saveProfile,
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                "Saqlash",
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputCard({required Widget child}) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: child,
      ),
    );
  }
}



// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:ismatov/api/api_service.dart';
// import 'package:ismatov/api/user_service.dart';
//
//
// class EditProfilePage extends StatefulWidget {
//
//   const EditProfilePage({super.key});
//
//   @override
//   State<EditProfilePage> createState() => _EditProfilePageState();
// }
//
// class _EditProfilePageState extends State<EditProfilePage> {
//   final TextEditingController _usernameController = TextEditingController();
//   final TextEditingController _bioController = TextEditingController();
//   final _username = '';
//   String _gender = 'male';
//   File? _imageFile;
//   bool _isLoading = false;
//   final ImagePicker _picker = ImagePicker();
//   Future<void> _pickImage() async {
//     final picked = await _picker.pickImage(source: ImageSource.gallery);
//     if (picked != null) {
//       setState(() {
//         _imageFile = File(picked.path);
//       });
//     }
//   }
//
//   Future<void> _saveProfile() async {
//     setState(() => _isLoading = true);
//     try {
//       await UserService().updateUserProfile(
//           userName: _usernameController.text,
//           bio: _bioController.text,
//           gender: _gender,
//         imageFile: _imageFile,
//       );
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('✅ Profil muvaffaqiyatli yangilandi')),
//
//
//       );
//       Navigator.pop(
//           context,
//         true
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("❌ Xatolik: ${e.toString()}")),
//       );
//     }
//     setState(() => _isLoading = false);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Edit Profile'),
//       ),
//       body: Padding(
//           padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             GestureDetector(
//               onTap: _pickImage,
//               child: CircleAvatar(
//                 radius: 50,
//                 backgroundImage:  _imageFile != null ? FileImage(_imageFile!) : null,
//                 child: _imageFile == null
//                 ? const Icon(Icons.camera_alt,size: 40)
//                 : null,
//               ),
//             ),
//             const SizedBox(height: 16),
//             TextField(
//               controller: _usernameController,
//               decoration: const InputDecoration(
//                 labelText: 'Username',
//                 border: OutlineInputBorder()
//               ),
//             ),
//             TextField(
//               controller: _bioController,
//               decoration: const InputDecoration(
//                 labelText: "bio",
//                 border: OutlineInputBorder(),
//               ),
//               maxLines: 3,
//             ),
//             const SizedBox(height: 16),
//             DropdownButtonFormField<String>(
//               value: _gender,
//               items: ['male','female']
//                 .map((gender) => DropdownMenuItem(
//                 value: gender,
//                 child: Text(gender),
//               ))
//                 .toList(),
//               onChanged: (value) {
//                 setState(() {
//                   _gender = value!;
//                 });
//               },
//               decoration: const InputDecoration(
//                 labelText: "Gender",
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 24),
//             _isLoading
//             ? const CircularProgressIndicator()
//                 : ElevatedButton(
//                 onPressed: _saveProfile,
//                 child: const Text("Saqlash"),
//             )
//           ],
//         ),
//       ),
//     );
//   }
//
// }