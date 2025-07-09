import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ismatov/api/api_service.dart';
import 'package:ismatov/models/post.dart';
import 'package:ismatov/models/userProfile.dart';
import 'package:ismatov/models/friendsList.dart';
import 'package:hive/hive.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:ismatov/models/friends.dart';
import 'dart:io';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';


class FriendsService {
  final ApiService _apiService = ApiService();


  Future<List<dynamic>> fetchFriendRequests(String token) async {
    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/friends/'),
      headers: {'Authorization': 'Token $token'},
    );
    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}");
    if (response.statusCode == 200){
      final data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception("Error get friend request:${response.body}");
    }

  }

  static Future<bool>updateOnlineStatus(bool isOnline,String token) async {
    final url = Uri.parse('${ApiService.baseUrl}/friends/update-online-status/');

    try{
      final  response = await http.post(
        url,
        headers:{
          'Content-Type': 'application/json',
          'Authorization':'Token $token',
        },
        body: json.encode({'is_online':isOnline}),
      );
      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch(e) {
      print("Error updating online status: $e");
      return false;
    }
  }

  Future<void> acceptRequest({
      required String token,
      required int requestId,
      required VoidCallback onSuccess,
      required BuildContext context,
      }) async {
    try{
      await acceptFriendRequest(
          token,
          requestId,
          onSuccess,
      );
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Friend request accepted")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error  accepting request")),
      );
      rethrow;
    }
  }






  Future<void> rejectRequest({
    required String token,
    required int requestId,
    required VoidCallback onSuccess,
    required BuildContext context,
}) async {
    try {
      await rejectFriendRequest(
          token,
          requestId,
          onSuccess,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Friend request rejected'))
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error rejecting request: $e')),
      );
      rethrow;

    }
  }



  Future<void> deleteFriend(String token, int profileId, Function callback) async {
    try{
      final response = await http.delete(
        Uri.parse('${ApiService.baseUrl}/friends/$profileId/delete-friend/'),
        headers: {'Authorization': 'Token $token'},
      );

    if (response.statusCode == 204){
      print('Friend deleted!');
      callback();
      return jsonDecode(response.body);
    } else {
      throw Exception("Error get friend request:${response.statusCode}");
    }
    } catch (e) {
      throw Exception('Delete friend error: $e');
    }
  }


  Future<void> sendFriendsRequest(String userName, String token, Function updateUI, BuildContext context) async {
    if( await isFriendsRequestSent(userName, token)){
      print("Friend request already sent!");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Friend request already sent!")),
      );
      return;
    }
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/friends/'),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'request_to': userName,
        }),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        print("Friend request sent successfully");
        updateUI();
      print(jsonEncode({'userId': userName}));
    } else {
        final errorMessage = jsonDecode(response.body)['error'] ?? "Failed to send friend request";
        print("Response body: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
        throw Exception("Failed to send friend request: ${response.body}");
      }

  }
  Future<bool> isFriendsRequestSent(String userName, String token) async {
    try {
      final friendRequests = await fetchFriendRequests(token);
      print("Friend requests from backend: $friendRequests");
      for (var request in friendRequests) {
        if (request['request_to'] == userName && request['status'] == 'Pending') {
          return true;
        }
      }
      return false;
    }catch (e) {
      print("error checking friend request status $e");
      return false;
    }
  }



 Future<void> acceptFriendRequest(String token, int requestId,Function updateUI) async {
    try {
      print('Accepting friend request ID: $requestId');
      final response = await http.put(
        Uri.parse('${ApiService.baseUrl}/friends/$requestId/accept/'),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'status': 'Accepted',
          'request_id':requestId,
          'action': 'accept'
        }),
      );
      if (response.statusCode == 200 ) {
        print('Friend request successfully accepted!');
        if(updateUI != null) {
          updateUI();
        }
      } else {
        final error = jsonDecode(response.body)['error'] ?? response.body;
        throw Exception("Failed to accept request: $error");
      }
    } catch (e){
      throw Exception("Could not accept friend request: ${e.toString()}");

    }
 }

 Future<void> rejectFriendRequest(String token, int requestId, Function updateUI) async {
    try{
      print("Rejecting friend request ID: $requestId");
      final response = await http.put(
        Uri.parse('${ApiService.baseUrl}/friends/$requestId/reject/'),
        headers: {
          'Authorization':'Token $token',
          'Content-Type':'application/json',
        },
        body: jsonEncode({
          'status':'Rejected',
          'request_id': requestId,
          'action': 'reject'
        })
      );
      if(response.statusCode == 200) {
        print("Friend request rejected successfully");
        if (updateUI != null){
          updateUI();
        }
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData(['detail']) ??
            errorData['error'] ??
            errorData['message'] ??
            'Unknown error accured';
        throw Exception("Failed to reject friend request: $errorMessage");
      }
    } catch (e){
      print('Error rejecting friend request: ${e.toString()}');
    }
 }



 Future<void> deleteFriendRequest(String token,int profileId, Function callback) async {
    try{
      final response = await http.delete(
        Uri.parse('${ApiService.baseUrl}/friends/$profileId/'),
        headers: {
          'Authorization': 'Token $token'
        }
      );

      if (response.statusCode == 204){
        callback();
      } else {
        throw Exception('Failed to delete friend request: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Delete Friend request error:$e ');
    }
 }

  Future<List<FriendRequest>> fetchIncomingPendingRequests(String token) async {
    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/friends/incoming-pending-requests/'),
      headers: {'Authorization': 'Token $token'},
    );
    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}");
    if (response.statusCode == 200){
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) {
        return FriendRequest(
            id: item['id'] ?? 0,
            requestFromId: item['id'] ?? 0,
            requestToId: item['id'] ?? 0,
            userName: item['userName'] ?? 'Nomalum',
            profileImage: item['profileImage'] != null
            ? '${ApiService.baseImage}${item['profileImage']}'
            : null,
            status: 'Pending',
          direction: 'none'
        );
      }).toList();

    } else {
      throw Exception("Error fetching incoming pending requests: ${response.body}");
    }
  }



  Future<List<dynamic>> fetchOutgoingPendingRequest(String token) async {
    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/friends/outgoing-pending-requests/'),
      headers: {'Authorization': 'Token $token'},
    );
    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}");
    if (response.statusCode == 200){
      final data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception("Error fetching outgoing pending requests: ${response.body}");
    }
  }



  Future<void> responseToFriendRequest(int requestId, bool accept, String token) async {
    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/friends/response'),
      headers: {
        'Authorization': 'Token $token',
        'Content-Type':'application/json'
      },
      body: jsonEncode({'request_id': requestId,'accept':accept}),
    );
    if(response.statusCode != 200) {
      throw Exception("Error to friends request: ${response.body}");
    }
}

  Future<Map<String, dynamic>> fetchFriendRequestStatus(String userName, String token) async {
    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/friends/check_status/?username=$userName'),
      headers: {'Authorization': 'Token $token'},
    );
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
      }
      throw Exception("Error fetching friend status: ${response.body}");

  }

  Future<List<UserProfile>> fetchFriendsList() async {
    final token = await _apiService.getUserToken();
    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/friends/'),

          headers: {'Authorization':'Token $token'},
    );
    if (response.statusCode == 200){
      final data = jsonDecode(response.body);
      return (data['results'] as List)
          .map((json) => UserProfile.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to  load friends List');
    }


  }
  Future<List<Friend>> getUserFriends(String token, int userId) async {
    try{
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/users/$userId/friends/'),
        headers: {'Authorization': 'Token $token'},
      );

      if (response.statusCode == 200){
        final Map<String, dynamic> json = jsonDecode(response.body);
        final List<dynamic> data = json['results'] ?? [];

        return data.map((json){
          if (json['user'] != null) {
            return Friend.fromJson(json['user']);
          }
          return Friend.fromJson(json);
        }).toList();
      } else {
        throw Exception('Failed to load Friends list: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Friends List error: $e');
    }
  }

  Future<List<Friend>> getAllFriends(String token) async {
    try{
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/friends/'),
        headers: {'Authorization': 'Token $token'},
      );
      if (response.statusCode == 200 ) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json){
          if(json['user'] != null) {
            return Friend.fromJson(json['user']);
          }
          return Friend.fromJson(json);
        }).toList();
      } else {
        throw Exception('Failed to load friends list: ${response.statusCode}');
      }
    } catch(e) {
      throw Exception('Friends List error: $e');
    }
  }
List<Post>getRandomFriendPosts(List<Post>allPosts,List<int>friendsIds){
    List<Post>friendPosts = allPosts.where((post) => friendsIds.contains(post.id)).toList();
    friendPosts.shuffle(Random());
    return friendPosts;
}

}