import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:ismatov/api/api_service.dart';
import 'package:ismatov/api/friends_service.dart';
import 'package:ismatov/api/notification_service.dart';
import 'package:ismatov/api/user_service.dart';
import 'package:ismatov/models/notification_model.dart';
import 'package:ismatov/models/userProfile.dart';
import 'package:ismatov/models/comments.dart';
import 'package:hive/hive.dart';
import 'package:ismatov/models/friends.dart';
import 'package:ismatov/widgets/comments_widget.dart';
import 'package:ismatov/widgets/profile.dart';
import 'package:ismatov/models/post.dart';
import'package:ismatov/widgets/posts.dart';


class NotificationsScreen extends StatefulWidget {
  final String token;
  final UserProfile userProfile;
  NotificationsScreen({required this.token, required this.userProfile, Key? key}) : super(key: key);

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final FriendsService _friendsService = FriendsService();
  List<NotificationModel> _notificationList = [];
  final ApiService _apiService = ApiService();
  List<Comment> _comments = [];
  List<FriendRequest> _friendRequests = [];
  bool _isLoading = true;
  String _errorMessage = '';


  @override
  void initState() {
    super.initState();
    _fetchData();
  }
String _getSenderInitial(Map<String,dynamic>sender) {
    final senderName = sender['username'] ??
  sender['userName'] ??
  sender['user_name']??
  'U';
    return senderName.isNotEmpty ? senderName[0].toUpperCase(): 'U';
}
String _getSenderName(Map<String,dynamic>sender){
  return sender['username'] ??
  sender['userName'] ??
  sender['user_name']??
  'Someone';

}

  String getNotificationText(NotificationModel notification) {
    String senderName = notification.sender.username ?? 'Someone';

    switch (notification.notificationType) {
      case 'like':
        return '$senderName liked your post';
      case 'comment':
        final commentText = notification.comment?['comment'] ?? '';
        return '$senderName commented: ${commentText.isNotEmpty ? commentText: "view comment"}';
      case 'reply':
        final replyText = notification.comment?['comment'] ??  '';
        return '$senderName Replies: ${replyText.isNotEmpty ? replyText: "view reply"}';
      default:
        return 'New notification';
    }

  }

  Future<void> _fetchFriendRequests() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
      final requests = await _friendsService.fetchIncomingPendingRequests(
          widget.token);
      setState(() {
        _friendRequests = requests;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Could not load friend requests.";
        _isLoading = false;
      });
    }
  }


  Future<void> _fetchNotifications() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
      final notifications = await NotificationService().getNotifications(widget.token);
      print("Notification:$notifications");
      setState(() {
        _notificationList = notifications;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Failed to load data";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  void _fetchData() async {
    try {
      await _fetchNotifications();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load notifications';
      });
    }
    try {
      await _fetchFriendRequests();
    } catch (e) {
      setState(() {
        _errorMessage = 'failed to friend request';
      });
    }

  }

    void _acceptRequest(FriendRequest request) async {
      try {
        await _friendsService.acceptFriendRequest(
            widget.token,
            request.id,
                () {
              setState(() {
                _friendRequests.removeWhere((r) => r.id == request.id);
              });
            }
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Friend request accepted")),

        );
      } catch (e) {
        print("Error accepting request: $e");
      }
    }


    void _rejectRequest(FriendRequest request) async {
      try {
        await _friendsService.rejectFriendRequest(
            widget.token,
            request.id,
                () {
              setState(() {
                _friendRequests.removeWhere((r) => r.id == request.id);
              });
            });
      } catch (e) {
        print("Error rejecting request: $e");
      }
    }

    Widget _buildFriendRequestList() {
      if (_friendRequests.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text('No friend requests available'),
        );
      }
      return Column(
        children: _friendRequests.map((request) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ProfilePage(
                        userProfile: UserProfile(
                          id: request.requestFromId,
                          userName: request.userName,
                          profileImage: request.profileImage,
                        ),
                      ),
                ),
              );
            },
            child: Card(
                margin: EdgeInsets.all(8.0),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: request.profileImage != null
                        ? NetworkImage(request.profileImage!)
                        : null,
                    child: request.profileImage == null
                        ? Text(request.userName[0].toUpperCase())
                        : null,
                  ),
                  title: Text(request.userName ?? 'Nomalum'),
                  subtitle: Text("Friends request"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                          icon: Icon(Icons.check, color: Colors.green),
                          onPressed: () => _acceptRequest(request)
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.red),
                        onPressed: () => _rejectRequest(request),
                      ),
                    ],
                  ),
                )
            ),
          );
        }).toList(),
      );
    }

  Widget _buildNotificationList() {
    if (_notificationList.isEmpty) {
      return Center(child: Text("No notifications availble"),);
    }

    return ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: _notificationList.length,
        itemBuilder: (context, index) {
          final notification = _notificationList[index];
          if (!(notification.notificationType == 'like' ||
              notification.notificationType == 'comment' ||
              notification.notificationType == 'reply')) {
            return SizedBox.shrink();
          }
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ListTile(
               leading: CircleAvatar(
                 backgroundImage: notification.sender.profileImage != null
                     ? NetworkImage(ApiService().formatImageUrl(notification.sender.profileImage))
                     : null,
                 child: notification.sender.profileImage == null
                   ? Text(
                   (notification.sender.username != null && notification.sender.username!.isNotEmpty)
                 ? notification.sender.username![0].toUpperCase()
                       : "U",
               )
                     : null
               ),
                title: Text(getNotificationText(notification)),
              subtitle: Text(notification.createdAt),
              trailing: !notification.isRead
                ? Icon(Icons.circle,color:Colors.blue,size: 10)
                  : null,

              onTap: () async {
                if(!notification.isRead) {
                  await NotificationService().markAsRead(notification.id, widget.token);
                  setState(() {
                    notification.isRead = true;
                  });
                }
                if (notification.notificationType == 'like') {
                  final fullProfile = await UserService().fetchUserProfileById(
                      notification.sender.id,
                      widget.token,
                  );
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ProfilePage(
                            userProfile: fullProfile
                          )
                      )
                  );
                  return;

                }
               else if (notification.notificationType == 'comment' || notification.notificationType == 'reply') {
                 if (notification.post != null && notification.comment != null) {
                   final postObj = Post.fromJson(notification.post!);
                   final commentId = notification.comment!['id'];
                     Navigator.push(
                         context,
                         MaterialPageRoute(
                             builder: (context) => CommentsPage(
          token: widget.token,
          postId: postObj.id,
          scrollCommentId: commentId,
          )
                             )
                     );
                   }

                 }
                }


          )
          );




        }



      );
  }





    Widget build(BuildContext context) {
      return Scaffold(
          appBar: AppBar(
            title: Text("Friend requests & Notifications"),
          ),
          body: _isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      _errorMessage,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Friends Request",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                _friendRequests.isEmpty
                    ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text('no Friend request avaible'),
                )
                    : _buildFriendRequestList(),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Notifications",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                _notificationList.isEmpty
                    ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text('No notifications avaible'),
                )
                    : _buildNotificationList()
              ],
            ),
          )

      );

    }
}
