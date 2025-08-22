import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ismatov/api/api_service.dart';
import 'package:ismatov/api/friends_service.dart';
import 'package:ismatov/forms/loginPage.dart';
import 'package:ismatov/widgets/profile.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class FriendRequestPage extends StatefulWidget {
  final String token;
  FriendRequestPage({required this.token});

  @override
  _FriendRequestPageState createState() => _FriendRequestPageState();
}

class _FriendRequestPageState extends State<FriendRequestPage> {
  String? token;
  List<dynamic> incomingRequests = [];
  List<dynamic> outgoingRequests = [];
  List<dynamic> friendRequests = [];
  bool isLoadingRequests = true;
  bool isLoading = true;

  String? _friendStatus;
  String? _requestDirection;

  @override
  void initState(){
    super.initState();
    _initializeToken();
  }

  void _initializeToken() async {
    String? storedToken = await ApiService().getUserToken();
    print("Token Hive dan olingan $storedToken");
    if (storedToken != null && storedToken.isNotEmpty) {
      setState(() {
        token = storedToken;
      });
      fetchIncomingRequests();
    } else {
      print("Token not available! You need to log in again.");
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
      );

    }
  }

  Future<void> checkFriendStatus(String username) async {
    try {
      final response = await http.get(
        Uri.parse(
            '${ApiService.baseUrl}/friends/check_status/?username=$username'),
        headers: {'Authorization': 'Token ${widget.token}'
        }
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _friendStatus = data['status'];
          _requestDirection = data['direction'] ?? 'none';
        });
      }
    } catch (e ){
      print("Error checking friend status: $e");
    }
}



  Future<void> fetchIncomingRequests() async {
    if (token == null || token!.isEmpty) return;

    try{
      final requests = await FriendsService().fetchIncomingPendingRequests(widget.token);
      setState(() {
        incomingRequests = requests;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching incoming requests: $e");
      setState(() {
        isLoading = false;
      });
    }
  }
  Future<void> acceptFriendRequest(int requestId) async {
    try{
      await FriendsService().acceptFriendRequest(widget.token, requestId, () {
        // _loadFriendRequests();
        fetchIncomingRequests();
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Friend request accepted!"))
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to accept friend request: $e'))
      );
    }
  }
Future<void> fetchRequests() async {
    try{
      final incoming = await FriendsService().fetchIncomingPendingRequests(widget.token);
      final outgoing = await FriendsService().fetchOutgoingPendingRequest(widget.token);
      setState(() {
        incomingRequests = incoming;
        outgoingRequests = outgoing;
      });
    } catch (e) {
      print("Error fetching requests $e");
    }
}
void updateUI() async {
    await fetchRequests();
    setState(() {
      // fetchRequests();
    });
}

  Future<void> rejectFriendRequest(int requestId) async {
    try{
      await FriendsService().deleteFriendRequest(widget.token, requestId, (){
        // _loadFriendRequests();
        fetchIncomingRequests();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Friend request rejected")),
      );
    } catch(e){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to  reject friend request: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Friend Request"),
      ),
      body: isLoading
        ? Center(child: CircularProgressIndicator(),)
          : incomingRequests.isEmpty
        ? Center(child: Text("no incoming friend requests."),)
          : ListView.builder(
        itemCount: incomingRequests.length,
          itemBuilder: (context, index){
          final request = incomingRequests[index];
          return ListTile(
            onTap: () async {
              await checkFriendStatus(request['request_from']['username']);
            },
            leading: CircleAvatar(
              backgroundImage:  NetworkImage(request['request_from']['profile_image'] ?? ''),
            ),
            title: Text(request['request_from']['username']),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [

                IconButton(
                    icon: Icon(Icons.check,color: Colors.green),
                  onPressed: () async {
                      await acceptFriendRequest(request['id']
                      );
                  }
                ),
                IconButton(
                    icon: Icon(Icons.close,color: Colors.red),
                    onPressed: () async {
                      await rejectFriendRequest(request['id']
                      );
                    }
                ),
              ],
            ),
          );
          }
      )
    );
  }
}