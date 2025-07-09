import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ismatov/api/api_service.dart';
import 'package:ismatov/models/notification_model.dart';


class NotificationService {

  final ApiService _apiService = ApiService();



  Future<List<NotificationModel>> getNotifications(String token) async {
    final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/my-notification/'),
        headers: {
          'Authorization': 'Token $token',
          'Content-type':'application/json',
        }
    );

    if (response.statusCode == 200) {
      final Map<String,dynamic> responseData = jsonDecode(response.body);
      final List<dynamic> results = responseData['results'];
      return results.map((item) => NotificationModel.fromJson(item)).toList();

    } else {
      throw Exception('Failed to load notifications');
    }



  }
  Future<void> markAsRead(int id, String token) async {
    await http.post(
      Uri.parse('${ApiService.baseUrl}/mark_as_read/$id/'),
        headers: {
          'Authorization':'Token $token',
          'Content-type':'application/json',
        }
    );
  }
}


