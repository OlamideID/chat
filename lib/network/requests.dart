import 'dart:convert';
import 'dart:developer';

import 'package:chat/components/cert.dart';
import 'package:http/http.dart' as http;

sendNotificationUrl() =>
    'https://fcm.googleapis.com/v1/projects/chat-29c58/messages:send';

class HttpRequests {
  static Future<void> chatNotifier({required String userToken}) async {
    try {
      var fcmToken = await GetServiceKey.getServiceToken();
      var data = jsonEncode({
        "message": {
          "token": userToken,
          "notification": {
            "title": "New Message",
            "body": "You have a new message",
          },
          "data": {
            "type": "chat",
          },
        }
      });
      var headers = {
        'Authorization': 'Bearer $fcmToken',
        'Content-Type': 'application/json',
      };
      final response = await http.post(
        Uri.parse(sendNotificationUrl()),
        headers: headers,
        body: data,
      );
      if (response.statusCode == 200) {
        log(response.body);
      } else {
        log('Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load data');
      }
    } catch (e) {
      log('Error sending notification: $e');
      throw Exception('Failed to load data');
    }
  }
}