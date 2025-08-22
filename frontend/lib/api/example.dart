// leading: CircleAvatar(
// radius: 24,
// child: (notification.sender.profileImage != null && notification.sender.profileImage!.isNotEmpty)
// ? ClipOval(
// child: Image.network(
// ApiService().formatImageUrl(notification.sender.profileImage!),
// fit: BoxFit.cover,
// width: 48,
// height: 48,
// errorBuilder: (context, error, stackTrace) {
// print('Image load error: $error'); // Xato logini chop etish
// return Icon(Icons.person, size: 28, color: Colors.grey);
// },
// ),
// )
//     : Icon(Icons.person, size: 28, color: Colors.grey),
// backgroundColor: Colors.grey.shade200,
// ),