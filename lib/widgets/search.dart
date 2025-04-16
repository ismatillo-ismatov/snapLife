import 'package:flutter/material.dart';
import 'package:ismatov/api/api_service.dart';
import 'package:ismatov/api/user_service.dart';
import 'package:ismatov/models/userProfile.dart';
import 'package:ismatov/models/post.dart';
import 'package:ismatov/widgets/comments_widget.dart';
import 'package:ismatov/widgets/profile.dart';

class SearchPage extends StatefulWidget {
  final UserProfile userProfile;
  const SearchPage({
    required this.userProfile,
    Key?key
}): super(key:key);
  @override
  _SearchPageState createState() => _SearchPageState();
}
class _SearchPageState extends State<SearchPage> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  bool _isLoading = false;








  void _searchUsers() async {
    setState(() {
      _isLoading = true;
    });
    try{
      final token  = await _apiService.getUserToken();
      if (token != null) {
        List<dynamic> users = await _apiService.searchUsers(_searchController.text,token);
        print(users);

        setState(() {
          _searchResults = users;
        });
      } else{
        print('Token topilmadi');
      }
    } catch(e) {
      print("Qidiruv xatolik: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Search users"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: "Search",
                suffixIcon: IconButton(
                    icon: Icon(Icons.search),
                  onPressed: _searchUsers,
                )
              ),
            ),
            SizedBox(height:16.0 ,),
            _isLoading
            ? CircularProgressIndicator()
                : Expanded(
                child: ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index){
                    final user = _searchResults[index];
                    return ListTile(
                      leading:  GestureDetector(
                    onTap: (){
                      print('Navigating to PrifilePage');

                      Navigator.push(
                      context,
                      MaterialPageRoute(
                    builder: (context) => ProfilePage(
                          userProfile: UserProfile(
                          id: user['profile_id']?? 0,
                          userName: user['username'] ?? 'No username',
                          profileImage: _apiService.formatImageUrl(user['ownerProfileImage']),
                          posts: user['posts'] != null
                          ? (user['posts'] as List<dynamic>)
                          .map((post) => Post.fromJson(post))
                              .toList()
                              : [],

                              ),

    ),


    )


    );
    },
    child: CircleAvatar(
    radius: 25,
    backgroundImage: user['ownerProfileImage'] != null
    ? NetworkImage(_apiService.formatImageUrl(user['ownerProfileImage']))
    : AssetImage('assets/images/nouser.png') as ImageProvider,
    backgroundColor: Colors.grey[300],
    ),
                        ),
                      title: Text(user['username'] ?? 'No username'),
    );
                  }
                      )


                )
          ],
        ),
      ),
    );
  }
}