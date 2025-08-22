import 'package:flutter/material.dart';
import 'dart:io';
import 'package:ismatov/api/message_service.dart';
import 'package:ismatov/api/user_service.dart';
import 'package:ismatov/main.dart';
import 'package:ismatov/api/api_service.dart';
import 'package:ismatov/api/post_service.dart';
import 'package:ismatov/api/friends_service.dart';
import 'package:ismatov/forms/loginPage.dart';
import 'package:ismatov/models/friends.dart';
import 'package:ismatov/models/friendsList.dart';
import 'package:ismatov/widgets/friendsListScreen.dart';
import 'package:ismatov/widgets/message_widget.dart';
import 'package:ismatov/models/userProfile.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ismatov/widgets/posts.dart';
import 'package:ismatov/models/post.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:ismatov/widgets/video_player_widget.dart';
import 'package:ismatov/forms/editProfile.dart';

class ProfilePage extends StatefulWidget {
  final UserProfile userProfile;
  const ProfilePage({required this.userProfile, Key? key}) : super(key: key);

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  late Future<Map<String, dynamic>> _friendRequestFuture;
  final FriendsService _friendsService = FriendsService();
  final ApiService _apiService = ApiService();
  late UserProfile _userProfile;
  bool isPressing = false;
  List<Post> userPosts = [];
  List<FriendRequest> _friendRequests = [];
  int _friendsCount = 0;
  int _totalLikes = 0;

  String? _token;
  bool isLoadingRequests = true;
  String friendRequestStatus = 'send friend request';
  String direction = 'none';

  void _calculateTatolLikes() {
    int total = 0;
    for (var post in widget.userProfile.posts) {
      total += post.likeCount ?? 0;
    }
    setState(() {
      _totalLikes = total;
    });
  }

  void refreshPostLikes() async {
    final updatePosts = await PostService().fetchPosts(_token!);
    setState(() {
      userPosts = updatePosts;
      widget.userProfile.posts = updatePosts;
    });
    _calculateTatolLikes();
  }

  Future<void> loadFriendRequestStatus() async {
    try {
      var box = await Hive.openBox('friendRequests');
      await box.delete('friendRequestStatus_${widget.userProfile.userName}');
      await _fetchFriendRequestStatusFromBackend();
    } catch (error) {
      print("Error loading friend request status: $error");
    }
  }

  @override
  void initState() {
    super.initState();
    _loadToken();
    _loadFriendsCount();
    _calculateTatolLikes();
    refreshPostLikes();
  }

  bool get _isCurrentuser {
    final box = Hive.box('authBox');
    final currentUserId = box.get('user_id');
    return currentUserId == widget.userProfile.id;
  }

  Future<void> _loadFriendsCount() async {
    final token = await ApiService().getUserToken();
    if (token != null) {
      final friends = await FriendsService().getUserFriends(
        token,
        widget.userProfile.id!,
      );
      setState(() {
        _friendsCount = friends.length;
      });
    }
  }

  Future<void> _loadToken() async {
    final token = await ApiService().getUserToken();
    setState(() {
      _token = token;
      _friendRequestFuture = _loadFriendRequestStatus();
    });
  }

  Future<Map<String, dynamic>> _loadFriendRequestStatus() async {
    if (_token == null) return {'status': 'error'};
    return await _friendsService.fetchFriendRequestStatus(
        widget.userProfile.userName, _token!);
  }

  Future<void> _fetchFriendRequestStatusFromBackend() async {
    try {
      if (_token != null) {
        print("Fetching friend request status with token: $_token");
        Map<String, dynamic> response = await FriendsService()
            .fetchFriendRequestStatus(widget.userProfile.userName, _token!);
        print("Friend request status from backend: $response");
        var box = await Hive.openBox('friendRequests');
        await box.delete("friendRequestStatus_${widget.userProfile.userName}");
        await box.put(
            "friendRequestStatus_${widget.userProfile.userName}", response);
        setState(() {
          friendRequestStatus = response['status'];
        });
      } else {
        print("Token is null, cannot fetch friend request status");
      }
    } catch (error) {
      print("Error fetching friend request status: $error");
      setState(() {
        friendRequestStatus = 'send friend request';
      });
    }
  }

  Future<void> _initializeProfilePage() async {
    await fetchToken();
    if (_token != null) {
      await _fetchFriendRequestStatusFromBackend();
      await _loadFriendRequests();
    }
    _checkForUpdates();
  }

  Future<void> _loadFriendRequests() async {
    try {
      if (_token != null) {
        final requests =
            await FriendsService().fetchIncomingPendingRequests(_token!);
        setState(() {
          _friendRequests = requests;
          isLoadingRequests = false;
        });
      }
    } catch (error) {
      print('Error load friend  request ');
    }
  }

  Future<void> fetchToken() async {
    try {
      String? fetchedToken = await ApiService().getUserToken();

      if (fetchedToken != null) {
        setState(() {
          _token = fetchedToken;
        });
        await _fetchFriendRequestStatusFromBackend();
      }
    } catch (error) {
      print("Error fetching token: $error");
    }
  }

  void refreshPosts() async {
    final updatedPosts = await PostService().fetchPosts(_token!);
    setState(() {
      userPosts = updatedPosts;
    });
  }

  void _checkForUpdates() async {
    if (widget.userProfile.posts.isEmpty) {
      debugPrint("this user has no posts");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("no posts available to view.")),
      );
      return;
    }
  }

  Future<List<Post>> fetchUpdatedPosts() async {
    String? token = await ApiService().getUserToken();
    return await PostService().fetchPosts(token!);
  }
  @override
  Widget build(BuildContext context) {
    if (_token == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Profile'),
          centerTitle: true,
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          widget.userProfile.userName,
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        actions: [
          if (_isCurrentuser)
            IconButton(
              icon: Icon(Icons.edit, color: Colors.blueAccent),
              onPressed: () async {
                final updated = await Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => EditProfilePage()),
                                    );
                                    if (updated == true) {
                                      final token = await UserService().getUserToken();
                                      if (token != null) {
                                        final updatedProfile =
                                            await UserService().fetchUserProfile(token);
                                        setState(() {
                                          _userProfile = UserProfile(
                                            id: updatedProfile.id,
                                            userName: updatedProfile.userName,
                                            gender: updatedProfile.gender,
                                            profileImage: updatedProfile.profileImage,
                                            posts: updatedProfile.posts,
                                          );
                                        });
                                        _calculateTatolLikes();
                                      }
                                    }
                                  }

            ),
          if (_isCurrentuser)
            IconButton(
              icon: Icon(Icons.logout, color: Colors.redAccent),
              onPressed: () async {
                    await UserService().logout();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  }
            )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
            CircleAvatar(
              radius: 60,
              backgroundImage: widget.userProfile.profileImage != null &&
                  widget.userProfile.profileImage!.isNotEmpty
                  ? NetworkImage(
                  _apiService.formatImageUrl(widget.userProfile.profileImage!))
                  : AssetImage('assets/images/nouser.png') as ImageProvider,
            ),
            SizedBox(height: 10),
            Text(
              widget.userProfile.userName,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
                onPressed: () async {
                  print("Message button pressed");
                  try {
                    final apiService = ApiService();
                    String? token = await apiService.getUserToken();
                    if (token == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                "Token not found. plaease log in again")),
                      );
                      return;
                    }
                    var box = Hive.box('authBox');
                    int? senderId = box.get('user_id');
                    if (senderId == null) {
                      print("sender Id not found!");
                      return;
                    }
                    int? receiverId = widget.userProfile.id;
                    print("UserProfile ID: ${widget.userProfile.id}");
                    print("UserProfile ID: ${widget.userProfile.toString()}");
                    if (widget.userProfile.id == null ||
                        widget.userProfile.id == 0) {
                      print("Invalid receiver ID!");
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Invalid receiver ID!")),
                      );
                      return;
                    }
                    if (receiverId == null || receiverId == 0) {
                      print("Invalid receiver ID!");
                      return;
                    }
                    print(
                        "Navigating to ChatPage whit sender: $senderId,receiver: $receiverId");
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ChatPage(sender: senderId, receiver: receiverId),
                      ),
                    );
                  } catch (e) {
                    print('Error: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("An error occurred: $e")),
                    );
                  } finally {
                    setState(() {
                      isPressing = false;
                    });
                  }
                },
              icon: Icon(Icons.message, size: 18),
              label: Text("Message"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
            FutureBuilder<Map<String, dynamic>>(
                future: _friendRequestFuture,
                builder: (context, snapshot) {
                  if (_isCurrentuser) {
                    return SizedBox.shrink();
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }
                  if (snapshot.hasError) {
                    return Text("Error loading status");
                  }
                  final data = snapshot.data ?? {};
                  final status = data['status'] ?? 'none';
                  final direction = data['direction'] ?? 'none';
                  final requestId = data['request_id'];

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildFriendRequestAction(status, direction, requestId),
                    ],
                  );
                }),

            // Stats row
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatCard("${widget.userProfile.posts.length}", "Posts"),
                  _buildStatCard("$_totalLikes", "Likes"),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => FriendListScreen(
                                userId: widget.userProfile.id!
                            )
                        ),
                      );
                    },
                    child: _buildStatCard("$_friendsCount", "Friends"),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

                GridView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 5,
                    childAspectRatio: 1,
                  ),
                  itemCount: widget.userProfile.posts.length,
                  itemBuilder: (context, index) {
                    final post = widget.userProfile.posts[index];

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>  PostPage(
                                userProfile: widget.userProfile,
                                post: post,
                                initialIndex: index,
                                token: _token!),
                          ),
                        );
                      },
                   child:    post.postVideo != null && post.postVideo!.isNotEmpty
                          ? FutureBuilder<File?>(
                        future: generateVideoThumbnail(
                          ApiService().formatVideoUrl(post.postVideo!),
                        ),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(strokeWidth: 1.w),
                            );
                          } else if (snapshot.hasData && snapshot.data != null) {
                            return Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.file(snapshot.data!, fit: BoxFit.cover),
                                Positioned(
                                  bottom: 8,
                                  right: 8,
                                  child: Icon(
                                    Icons.play_circle_outline,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ],
                            );
                          } else {
                            return Image.asset('assets/images/nouser.png', fit: BoxFit.cover);
                          }
                        },
                      )
                          : post.postImage != null && post.postImage!.isNotEmpty
                          ? Image.network(
                        ApiService().formatImageUrl(post.postImage!),
                        fit: BoxFit.cover,
                      )
                          : Image.asset('assets/images/nouser.png', fit: BoxFit.cover),

                    );


                  },
                ),

          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }


  Widget _buildFriendRequestAction(
      String status, String direction, int? requestId) {
    if (_isCurrentuser) {
      return SizedBox.shrink();
    }
    print(
        'Current status: $status, direction: $direction, requestId: $requestId');
    if (status == 'Pending') {
      if (direction == 'incoming') {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
                icon: Icon(Icons.check, color: Colors.green),
                onPressed: () => _acceptRequest(widget.userProfile.id)),
            IconButton(
              icon: Icon(Icons.close, color: Colors.red),
              onPressed: () => _rejectRequest(widget.userProfile.id),
            ),
          ],
        );
      } else {
        return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          SizedBox(
            width: 8.w,
          ),
          TextButton(
            child:
                Text('cancel request', style: TextStyle(color: Colors.white)),
            style: TextButton.styleFrom(
                backgroundColor: Colors.red,
                side: BorderSide(color: Colors.red, width: 2),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20))),
            onPressed: isPressing
                ? null
                : () => _cancelFriendRequest(widget.userProfile.id!),
          )
        ]);
      }
    } else if (status == 'Rejected') {
      return ElevatedButton(
        onPressed: isPressing ? null : _sendFriendRequest,
        child: isPressing
            ? CircularProgressIndicator()
            : Text("Send Friend Request"),
      );
    } else if (status == 'Accepted') {
      return TextButton(
          child: Text("delete Friend"),
          onPressed: isPressing
              ? null
              : () {
                  if (widget.userProfile.id != null) {
                    _showDeleteFriendDialog(widget.userProfile.id!);
                  }
                },
          style: TextButton.styleFrom(
            backgroundColor: Colors.red,
            side: BorderSide(color: Colors.red, width: 2),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ));
    } else {
      return ElevatedButton(
        onPressed: isPressing ? null : _sendFriendRequest,
        child: isPressing
            ? CircularProgressIndicator()
            : Text("send Friend request"),
      );
    }
  }

  Future<void> _sendFriendRequest() async {
    if (_token == null) return;

    try {
      setState(() => isPressing = true);
      await _friendsService.sendFriendsRequest(
        widget.userProfile.userName,
        _token!,
        () async {
          try {
            final newStatus = await _friendsService.fetchFriendRequestStatus(
                widget.userProfile.userName, _token!);

            setState(() {
              isPressing = false;
              friendRequestStatus = newStatus['status'] ?? 'Pending';
              direction = newStatus['direction'] ?? 'outgoing';
              _friendRequestFuture = Future.value(newStatus);
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Friend request sent!")),
            );
          } catch (e) {
            setState(() => isPressing = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Error fetching new status: $e")),
            );
          }
        },
        context,
      );
    } catch (e) {
      setState(() {
        isPressing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send request: ${e.toString()}')));
    }
  }

  Future<void> _cancelFriendRequest(int profileId) async {
    if (_token == null || profileId == null) return;
    try {
      setState(() => isPressing = true);
      await _friendsService.deleteFriendRequest(_token!, profileId, () async {
        try {
          final newStatus = await _friendsService.fetchFriendRequestStatus(
              widget.userProfile.userName, _token!);
          setState(() {
            isPressing = false;
            friendRequestStatus = newStatus['status'] ?? 'none';
            direction = newStatus['direction'] ?? 'none';
            _friendRequestFuture = Future.value(newStatus);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Friend request cancelled successfully")),
          );
        } catch (e) {
          setState(() => isPressing = false);
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error fetching new status: $e')));
        }
      });
    } catch (e) {
      setState(() => isPressing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _acceptRequest(int? profileId) async {
    if (_token == null || profileId == null) return;

    try {
      await _friendsService.acceptFriendRequest(_token!, profileId, () {
        setState(() {
          _friendRequestFuture = _loadFriendRequestStatus();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Friend request accepted')),
        );
      });
    } catch (e) {
      print("Error accepting request: $e");
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error accepting request: ${e.toString()}")));
    }
  }

  Future<void> _rejectRequest(int? profileId) async {
    if (_token == null || profileId == null) return;
    try {
      setState(() => isPressing = true);
      await _friendsService.rejectFriendRequest(
        _token!,
        profileId,
        () async {
          try {
            final newStatus = await _friendsService.fetchFriendRequestStatus(
                widget.userProfile.userName, _token!);
            final status = newStatus['status'] == 'Rejected'
                ? 'none'
                : newStatus['status'];
            setState(() {
              isPressing = false;
              friendRequestStatus = status ?? 'none';
              direction = newStatus['direction'] ?? 'none';
              _friendRequestFuture = Future.value(newStatus);
            });
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Friend request rejected!')));
          } catch (e) {
            setState(() => isPressing = false);
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error fetching new status')));
          }
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error rejecting request: ${e.toString()}')));
    }
  }

  Future<void> _deleteFriend(int? profileId) async {
    if (_token == null || profileId == null) return;

    try {
      setState(() => isPressing = true);
      await _friendsService.deleteFriend(_token!, profileId, () async {
        try {
          final newStatus = await _friendsService.fetchFriendRequestStatus(
              widget.userProfile.userName, _token!);
          setState(() {
            isPressing = false;
            friendRequestStatus = newStatus['status'] ?? 'none';
            direction = newStatus['direction'] ?? 'none';
            _friendRequestFuture = Future.value(newStatus);
          });
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Friend removed successfully')));
        } catch (e) {
          setState(() => isPressing = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error fetching new status: $e')),
          );
        }
      });
    } catch (e) {
      setState(() => isPressing = false);
    }
  }

  void _showDeleteFriendDialog(int requestId) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Remove Friend"),
            content: Text("Are you sure you want remove this friend?"),
            actions: [
              TextButton(
                child: Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: Text(
                  "Remove",
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  _deleteFriend(requestId);
                },
              )
            ],
          );
        });
  }
}
