// Future<UserProfile> fetchUserProfile(String token) async {
//   final response = await http.get(
//     Uri.parse('$baseUrl/my-profile/'),
//     headers: {'Authorization': 'Token $token'},
//   );
//
//   print('Response status: ${response.statusCode}');
//   print('Response body: ${response.body}');
//
//   if (response.statusCode == 200) {
//     final jsonResponse = json.decode(response.body);
//     return UserProfile.fromJson(jsonResponse);
//   } else {
//     throw Exception("Failed to load user profile");
//   }
// }
