class ShortUserProfile {
  final int id;
  final String userName;
  final String? profileImage;

  ShortUserProfile({
    required this.id,
    required this.userName,
    this.profileImage,
  });
  factory ShortUserProfile.fromJson(Map<String,dynamic> json) {
    return ShortUserProfile(
      id: json['id'],
      userName: json['userName'],
      profileImage: json['profileImage'],
    );
  }
  @override
  String toString() {
    return 'ShortUserProfile(id:$id, userName: $userName,profileImage: $profileImage)';

  }

}



