import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ismatov/models/friendsList.dart';
import 'package:intl/intl.dart';
import 'package:ismatov/models/userProfile.dart';
import 'package:ismatov/widgets/friendsListScreen.dart';
import 'package:ismatov/widgets/profile.dart';

class FriendListItem extends StatelessWidget{
  final Friend friend;
  final VoidCallback? onTap;

  const FriendListItem({
    Key? key,
    required this.friend,
    this.onTap,
  }) : super (key: key);

  void _navigateToProfile(BuildContext context) {
    Navigator.push(
        context,
      MaterialPageRoute(
          builder: (context) => ProfilePage(
              userProfile: UserProfile(
                  id: friend.id,
                  userName: friend.userName,
                profileImage: friend.profileImage,
                posts: friend.posts
              ),
          ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => _navigateToProfile(context),
      leading: _buildUserAvatar(context),
        title: Text(
          friend.userName,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),

        // trailing: _buildMessageButton(),
        // onTap: onTap,
    );
  }

    Widget _buildUserAvatar(BuildContext context) {
      return Stack(
        alignment: Alignment.bottomRight,
        children: [
          CircleAvatar(
            backgroundImage: _getProfileImage(),
            child: _getProfileImage() == null
              ? const Icon(Icons.person,size:24)
                : null,
          ),
          // if(friend.isOnline) _buildOnlineIndicator(context),
        ],
      );
    }

  ImageProvider? _getProfileImage() {
    print("Profile image URL: ${friend.profileImage}");
    if (friend.profileImage == null || friend.profileImage!.isEmpty) {
      return const AssetImage('assets/images/nouser.png');
    }
    try {
      Uri uri = Uri.parse(friend.profileImage!);
      if (!uri.isAbsolute || uri.scheme.isEmpty || uri.host.isEmpty) {
        return const AssetImage('assets/images/nouser.png');
      }
      // Noto‘g‘ri prefiksni olib tashlash
      String cleanedUrl = friend.profileImage!.replaceFirst(RegExp(r'^http://192\.168\.\d+\.\d+:\d+'), '');
      print("Cleaned profile image URL: $cleanedUrl");
      return NetworkImage(cleanedUrl);
    } catch (e) {
      print("Error parsing profile image URL: $e");
      return const AssetImage('assets/images/nouser.png');
    }
  }
    // ImageProvider? _getProfileImage() {
    //   print("Profile image URL: ${friend.profileImage}");
    // if (friend.profileImage == null || friend.profileImage!.isEmpty){
    //   return const AssetImage('assets/images/nouser.png');
    // }
    // Uri? uri = Uri.tryParse(friend.profileImage!);
    // if (uri == null || !uri.hasAbsolutePath || uri.host.isNotEmpty){
    //   return const AssetImage('assets/images/nouser.png');
    // }
    // return NetworkImage(friend.profileImage!);
    //
    // }

    Widget _buildOnlineIndicator(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: Colors.green,
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).scaffoldBackgroundColor,
          width: 2,
      ),
      ),
    );
    }

    String timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(friend.lastActive!.toLocal());
    // final diff = DateTime.now().toUtc().difference(friend.lastActive!.toUtc());
    if (diff.inMinutes < 60 ) return '${diff.inMinutes} minutes ego';
    if (diff.inHours < 24 ) return '${diff.inHours} Hours ego';
    return '${diff.inDays} days ago';
    }

    Widget buildStatus(Friend friend){
    if (friend.isOnline != null && friend.isOnline == true){
      return const Text("🟢 Online",style: TextStyle(color: Colors.green));
    } else {
      return const Text("🔴 Offline",style: TextStyle(color:Colors.red));
    }
    }


    // Widget _buildMessageButton() {
    // return IconButton(
    //     icon: const Icon(Icons.message_outlined),
    //   onPressed: onTap,
    //   tooltip: "sendMessage",
    // );
    // }

}











