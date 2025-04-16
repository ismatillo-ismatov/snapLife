import 'package:flutter/material.dart';
import 'package:ismatov/api/friends_service.dart';
import 'package:ismatov/models/userProfile.dart';
import 'package:hive/hive.dart';
import 'package:ismatov/models/friends.dart';
import 'package:ismatov/widgets/profile.dart';


class FriendRequestScreen extends StatefulWidget {
  final String token;
  FriendRequestScreen({required this.token, Key? key}) : super(key: key);

  @override
  _FriendRequestScreenState createState() => _FriendRequestScreenState();
}

class _FriendRequestScreenState extends State<FriendRequestScreen> {
  final FriendsService _friendsService = FriendsService();
  List<FriendRequest> _friendRequests = [];
  // List<dynamic> _friendRequests = [];
  bool _isLoading = true;
  String _errorMessage = '';
  // String _token = '';


  @override
  void initState() {
    super.initState();
    _fetchFriendRequests();
  }


  Future<void> _fetchFriendRequests() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
      final requests = await _friendsService.fetchIncomingPendingRequests(widget.token);
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





  void _acceptRequest(FriendRequest request) async {
    try{
      await _friendsService.acceptFriendRequest(
          widget.token,
          request.id,
              () {
            setState(() {
              _friendRequests.removeWhere((r) => r.id == request.id);
            });
          }
      );
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Friend request accepted")),

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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("friend Request")),
      body: _buildBody(),
    );
  }

  Widget _buildBody(){
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(),);
    }

    if(_errorMessage.isNotEmpty){
      return Center(child: Text(_errorMessage),);
    }

    if(_friendRequests.isEmpty){
      return Center(child: Text("No friend requests available."),);
    }

    return ListView.builder(
        itemCount: _friendRequests.length,
        itemBuilder:(context,index){
          final request = _friendRequests[index];
          final friendService = FriendsService();
          return GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ProfilePage(
                          userProfile: UserProfile(
                            id: request.id,
                            userName: request.userName,
                            profileImage: request.profileImage,

                          )
                      )

                  )
              );
            },

            child:  Card(
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
                          icon: Icon(Icons.check,color: Colors.green),
                          onPressed: () => _acceptRequest(request)
                      ),
                      IconButton(
                        icon: Icon(Icons.close,color:Colors.red),
                        onPressed: () => _rejectRequest(request),
                      ),
                    ],
                  ),
                )
            ),
          );
        }
    );
  }


}

