import 'package:flutter/material.dart';
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
import 'package:ismatov/widgets/friendsRequestScreen.dart';
import 'package:ismatov/widgets/message_widget.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ismatov/models/userProfile.dart';
import 'package:ismatov/widgets/posts.dart';
import 'package:ismatov/models/post.dart';
import 'package:ismatov/widgets/post_items.dart' as items;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;


class ProfilePage extends StatefulWidget {
  final UserProfile userProfile;
  const ProfilePage({
    required this.userProfile,
     Key?key}) :super(key:key);


  @override
  ProfilePageState createState() => ProfilePageState();
}
class ProfilePageState extends State<ProfilePage> {
  late Future<Map<String, dynamic>> _friendRequestFuture;
  final FriendsService _friendsService = FriendsService();
  bool isPressing = false;
  List<Post> userPosts = [];
  List<FriendRequest> _friendRequests = [];
  int _friendsCount = 0;

  String? _token;
  bool  isLoadingRequests = true;
  String friendRequestStatus = 'send friend request';
  String direction = 'none';



Future <void> loadFriendRequestStatus() async {
  try {
    var box = await Hive.openBox('friendRequests');
    await box.delete('friendRequestStatus_${widget.userProfile.userName}');
    await _fetchFriendRequestStatusFromBackend();
  }catch(error){
    print("Error loading friend request status: $error");
  }

  }
  @override
  void initState() {
    super.initState();
    _loadToken();
    _loadFriendsCount();
  }


  bool get _isCurrentuser {
  final box  = Hive.box('authBox');
  final currentUserId = box.get('user_id');
  return currentUserId == widget.userProfile.id;
  }

  Future<void> _loadFriendsCount() async {
  final token = await ApiService().getUserToken();
  if (token != null) {
    final friends = await FriendsService().getUserFriends(
        token, widget.userProfile.id,
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
  if(_token == null )return {'status':'error'};
    return  await _friendsService.fetchFriendRequestStatus(
        widget.userProfile.userName,
        _token!
    );
  }


  Future<void> _fetchFriendRequestStatusFromBackend() async {
    try {
      if (_token != null ) {
        print("Fetching friend request status with token: $_token");
        Map<String,dynamic> response = await FriendsService().fetchFriendRequestStatus(widget.userProfile.userName, _token!);
        print("Friend request status from backend: $response");
        var box = await Hive.openBox('friendRequests');
        await box.delete("friendRequestStatus_${widget.userProfile.userName}");
        await box.put(
            "friendRequestStatus_${widget.userProfile.userName}",
            response
        );
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
    if(_token != null ) {
      await _fetchFriendRequestStatusFromBackend();
      await _loadFriendRequests();
    }
    _checkForUpdates();
  }

  Future<void>_loadFriendRequests() async {
    try{
      if(_token != null) {
        final requests = await FriendsService().fetchIncomingPendingRequests(_token!);
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

      if(fetchedToken != null){
        setState(() {
          _token = fetchedToken;
        });
        await _fetchFriendRequestStatusFromBackend();
      }
    }catch(error){
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
    if (widget.userProfile.posts.isEmpty){
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
    print("userName: ${widget.userProfile.userName}");
    print(widget.userProfile.profileImage);
    print(widget.userProfile.posts);
  if (_token == null ){
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: Center(child: CircularProgressIndicator(),)
    );
  }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.userProfile.userName),
        actions: [
          IconButton(
              icon: Icon(Icons.logout),
            onPressed: () async {
                await UserService().logout();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
            },
          )
        ],
      ),

    body: SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        children: [

          Padding(padding: EdgeInsets.symmetric(horizontal: 110.w),
             child: Container(
              height: 200.h,
              width: 200.w,

              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    ),
                // borderRadius: BorderRadius.circular(80),
                image: DecorationImage(
                  image: widget.userProfile.profileImage != null && widget.userProfile.profileImage!.isNotEmpty
                      ? NetworkImage(widget.userProfile.profileImage!)
                      : AssetImage('assets/images/nouser.png') as ImageProvider,
                  scale: 1.0,
                  fit: BoxFit.cover,

                ),

              ),
              child: Transform.translate(
                offset: Offset(60.w, 200.h),
                child: Text(widget.userProfile.userName,
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ),
          SizedBox(height: 20.h,),
          ElevatedButton(
              child: Text(isPressing ? "Please wait ...":"Message"),
              onPressed: () async {
                print("Message button pressed");
                try {
                  final apiService = ApiService();
                  String? token = await apiService.getUserToken();
                  if( token == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Token not found. plaease log in again")),
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
                  if (widget.userProfile.id == null || widget.userProfile.id == 0){
                    print("Invalid receiver ID!");
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Invalid receiver ID!")),
                    );
                    return;
                  }
                  if (receiverId == null || receiverId == 0){
                    print("Invalid receiver ID!");
                    return;
                  }
                  print("Navigating to ChatPage whit sender: $senderId,receiver: $receiverId");
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatPage(
                          sender: senderId,
                          receiver: receiverId
                      ),
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
              }
          ),
          FutureBuilder<Map<String,dynamic>>(
              future: _friendRequestFuture,
              builder: (context,snapshot) {
                if (_isCurrentuser){
                  return SizedBox.shrink();
                }
                if(snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                if(snapshot.hasError){
                  return Text("Error loading status");
                }
                final data = snapshot.data ?? {};
                final status = data['status'] ?? 'none';
                final direction = data['direction'] ?? 'none';
                final requestId = data['request_id'];



                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildFriendRequestAction(status,direction,requestId),
                    ],
                );
              }
          ),
      Padding(padding: EdgeInsets.symmetric(horizontal: 50.w, vertical: 90.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
              Text("${widget.userProfile.posts.length}\nPosts"),
             InkWell(
               onTap:() {
                 Navigator.push(
                   context,
                   MaterialPageRoute(
                       builder: (context) =>  FriendListScreen(userId: widget.userProfile.id)
                   ),
                 );
               },
                 child: Column(
                   mainAxisSize: MainAxisSize.min,
                   children: [
                     Text("$_friendsCount"),
                     Text("Friends",style: TextStyle(fontSize: 14.sp),)


                   ],
                 )

             ),
          // Text("$_friendsCount\nFriends"),
          //
          //     Text("$_friendsCount\nfriends"),
              // Text("0\nfollowing"),
          ],

    ),
      ),
           GridView.builder(
             shrinkWrap: true,
             physics: NeverScrollableScrollPhysics(),
           gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
             crossAxisCount: 3,
             childAspectRatio: 1.0,
           ),
             itemCount: widget.userProfile.posts.length,
             itemBuilder: (context, index){
             final post = widget.userProfile.posts[index];
             return GestureDetector(
                 onTap: () async {
                   final deletedPostId = await Navigator.push(
                       context,
                       MaterialPageRoute(
                           builder: (context) => PostPage(
                               userProfile: widget.userProfile,
                               post: post,
                               initialIndex: index,
                               token: _token!
                           )
                       ),
                   );
                   if (deletedPostId != null) {
                     setState(() {
                       widget.userProfile.posts.removeWhere((post) => post.id ==  deletedPostId);
                     });
                   }

                 },

             child: Card(
               margin: EdgeInsets.all(1),
                     child: Container(
                       decoration: BoxDecoration(
                         image: DecorationImage(
                             image: post.postImage != null &&
                             post.postImage!.isNotEmpty
                                 ? NetworkImage(ApiService().formatImageUrl(post.postImage!))
                                 :AssetImage('assets/images/nouser.png')
                                 as ImageProvider,
                           fit: BoxFit.cover,
                         )
                       ),
                     ),
             ),
                   );

             },
       ),
    ]
      )

    )
      );
  }

  Widget _buildFriendRequestAction(String status, String direction, int? requestId) {
    if(_isCurrentuser) {
      return SizedBox.shrink();
    }
    print('Current status: $status, direction: $direction, requestId: $requestId');
    if (status == 'Pending') {
      if(direction == 'incoming'){
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
                icon: Icon(Icons.check, color: Colors.green),
                onPressed: () => _acceptRequest(widget.userProfile.id)
            ),
            IconButton(
              icon: Icon(Icons.close, color: Colors.red),
              onPressed: () => _rejectRequest(widget.userProfile.id),
            ),

          ],
        );
      } else {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
            isPressing ? "Canceling..." :"Request Sent",
            style: TextStyle(color: isPressing ? Colors.orange :Colors.grey, fontSize:16),
            ),
            SizedBox(width: 8,),
            IconButton(
                icon: Icon(Icons.cancel,color: Colors.orange),
                onPressed: isPressing ? null : () => _cancelFriendRequest(widget.userProfile.id),
            )
          ]
        );
      }

    }else if (status == 'Rejected'){
      return ElevatedButton(onPressed: isPressing ? null : _sendFriendRequest,
          child: isPressing
          ? CircularProgressIndicator()
              : Text("Send Friend Request"),
      );
    } else if (status == 'Accepted') {
      // return Text(
      //   "Friend",
      //   style: TextStyle(color: Colors.green, fontSize: 16),
      // );
    return IconButton(
    icon: Icon(Icons.delete,color: Colors.red),
    onPressed:  isPressing ? null : () {
      if (widget.userProfile.id != null){
      _showDeleteFriendDialog(widget.userProfile.id);
    }
    },
    );
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
    if(_token == null) return;

    try {
      setState(() => isPressing = true);
      await _friendsService.sendFriendsRequest(
        widget.userProfile.userName,
        _token!,
            () async {
          try {
            final newStatus = await _friendsService.fetchFriendRequestStatus(
                widget.userProfile.userName,
                _token!
            );

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
          SnackBar(content: Text('Failed to send request: ${e.toString()}'))
      );
    }
  }




  Future<void> _cancelFriendRequest(int profileId) async {
  if (_token == null || profileId == null) return;
    try{
      setState(() => isPressing = true);
      await _friendsService.deleteFriendRequest(
          _token!,
          profileId,
          () async {
            try {
              final newStatus = await _friendsService.fetchFriendRequestStatus(
                  widget.userProfile.userName,
                  _token!
              );
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
                SnackBar(content: Text('Error fetching new status: $e'))
              );
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
  if(_token == null || profileId == null ) return;

    try {
      await _friendsService.acceptFriendRequest(
          _token!,
          profileId,
              () {
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
          SnackBar(content: Text("Error accepting request: ${e.toString()}"))
      );
    }
  }

  Future<void> _rejectRequest(int? profileId) async {
    if(_token == null || profileId == null) return;
    try {
      setState(() => isPressing = true);
      await _friendsService.rejectFriendRequest(
        _token!,
        profileId,
            () async {
          try {
            final newStatus = await _friendsService.fetchFriendRequestStatus(
                widget.userProfile.userName,
                _token!
            );
            final status = newStatus['status'] == 'Rejected' ? 'none' : newStatus['status'];
            setState(() {
              isPressing = false;
              friendRequestStatus = status ?? 'none';
              direction = newStatus['direction'] ?? 'none';
              _friendRequestFuture = Future.value(newStatus);
            });
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Friend request rejected!'))
            );
          } catch (e) {
            setState(() => isPressing = false);
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error fetching new status'))
            );
          }

        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error rejecting request: ${e.toString()}'))
      );
    }
  }


Future<void> _deleteFriend(int? profileId) async {
  if (_token == null || profileId == null) return;

  try{
    setState(() => isPressing = true);
    await _friendsService.deleteFriend(
        _token!,
        profileId,
        () async {
          try {
            final newStatus = await _friendsService.fetchFriendRequestStatus(
                widget.userProfile.userName,
                _token!
            );
            setState(() {
              isPressing = false;
              friendRequestStatus = newStatus['status'] ?? 'none';
              direction = newStatus['direction'] ?? 'none';
              _friendRequestFuture = Future.value(newStatus);
            });
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Friend removed successfully'))
            );
          } catch(e) {
            setState(() => isPressing = false);
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error fetching new status: $e')),
            );
                }
        }
    );
  } catch (e) {
    setState(() => isPressing = false);
    }
}
void _showDeleteFriendDialog(int requestId) {
  showDialog(
      context:context,
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

      }
  );
}
}