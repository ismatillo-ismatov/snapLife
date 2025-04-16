import 'package:flutter/material.dart';
import 'package:ismatov/api/api_service.dart';
import 'package:ismatov/api/friends_service.dart';
import 'package:ismatov/models/userProfile.dart';
import 'package:hive/hive.dart';
import 'package:ismatov/models/friends.dart';
import 'package:ismatov/models/friendsList.dart';
import 'package:ismatov/widgets/friendListItem.dart';
import 'package:ismatov/widgets/profile.dart';


class FriendListScreen extends StatefulWidget {
  final int userId;
  const FriendListScreen({Key? key,required this.userId}) : super(key: key);

  @override
  _FriendListScreenState createState() => _FriendListScreenState();
}

class _FriendListScreenState extends State<FriendListScreen> {
   Future<List<Friend>>? _friendsFuture;
  // late Future<List<Friend>> _friendsFuture;
  final FriendsService _friendsService = FriendsService();
  String? _token;
  bool _isOnline = true;



  @override
  void initState() {
    super.initState();
    _loadFriends();
  }


  Future<void> _loadFriends() async {
    final token = await ApiService().getUserToken();
    if (token != null) {
      setState(() {
        _token = token;
        _friendsFuture = _friendsService.getUserFriends(token,widget.userId);
      });
    } else {
      setState(() {
        _token = token;
        _friendsFuture = _friendsService.getAllFriends(token!);
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Friend List"),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadFriends,
            ),
          ],
        ),
        body: FutureBuilder<List<Friend>>(
            future: _friendsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                    child: Text("You don't have any friends yet."));
              }
              return RefreshIndicator(
                onRefresh: _loadFriends,
                child: ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final friend = snapshot.data![index];
                    return FriendListItem(friend: friend);
                  },
                ),

              );
            }
        )
    );
  }
}

