// class FriendListItem extends StatelessWidget {
//   final Friend friend;
//   final VoidCallback? onTap;
//
//   const FriendListItem({
//     Key? key,
//     required this.friend,
//     this.onTap,
//   }) : super(key: key);
//
//   void _navigateToProfile(BuildContext context) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => ProfilePage(
//           userProfile: UserProfile(
//             id: friend.id,
//             userName: friend.userName,
//           ),
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return ListTile(
//       onTap: () => _navigateToProfile(context),
//       leading: _buildUserAvatar(context),
//       title: Text(
//         friend.userName,
//         style: const TextStyle(fontWeight: FontWeight.w500),
//       ),
//       subtitle: buildStatus(friend),
//       trailing: _buildMessageButton(),
//     );
//   }
//
//   Widget _buildUserAvatar(BuildContext context) {
//     return Stack(
//       alignment: Alignment.bottomRight,
//       children: [
//         CircleAvatar(
//           backgroundImage: _getProfileImage(),
//           child: _getProfileImage() == null
//               ? const Icon(Icons.person, size: 24)
//               : null,
//         ),
//         // if(friend.isOnline) _buildOnlineIndicator(context),
//       ],
//     );
//   }
//
//   ImageProvider? _getProfileImage() {
//     if (friend.profileImage == null || friend.profileImage!.isEmpty) {
//       return const AssetImage('assets/images/nouser.png');
//     }
//     try {
//       return NetworkImage(friend.profileImage!);
//     } catch (e) {
//       return const AssetImage('assets/nouser.png');
//     }
//   }
//
//   String timeAgo(DateTime dateTime) {
//     final diff = DateTime.now().difference(friend.lastActive!.toLocal());
//     // final diff = DateTime.now().toUtc().difference(friend.lastActive!.toUtc());
//     if (diff.inMinutes < 60) return '${diff.inMinutes} minutes ago';
//     if (diff.inHours < 24) return '${diff.inHours} Hours ago';
//     return '${diff.inDays} days ago';
//   }
//
//   Widget buildStatus(Friend friend) {
//     if (friend.isOnline) {
//       return const Text("🟢 Online", style: TextStyle(color: Colors.green));
//     } else {
//       return const Text("🔴 Offline", style: TextStyle(color: Colors.red));
//     }
//   }
//
//   Widget _buildMessageButton() {
//     return IconButton(
//       icon: const Icon(Icons.message_outlined),
//       onPressed: onTap,
//       tooltip: "Send Message",
//     );
//   }
// }
