import 'package:googleapis_auth/auth_io.dart';
import 'dart:developer';

class GetServiceKey {
  static Future<String> getServiceToken() async {
    final scopes = [
      'https://www.googleapis.com/auth/userinfo.email',
      'https://www.googleapis.com/auth/firebase.database',
      'https://www.googleapis.com/auth/firebase.messaging',
    ];

    // Load the service account credentials securely (e.g., from a file or environment variable)
    const serviceAccountJson = '''{
      "type": "service_account",
      "project_id": "chat-29c58",
      "private_key_id": "b0614d59279cb575f5626b97cf5661a611376446",
      "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDlJiQuWXF5MLyY...",
      "client_email": "firebase-adminsdk-yha6a@chat-29c58.iam.gserviceaccount.com",
      "client_id": "103597736047368733860",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-yha6a%40chat-29c58.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    }''';

    final client = await clientViaServiceAccount(
      ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
    );

    final accessServerToken = client.credentials.accessToken.data;
    log(accessServerToken.toString());

    return accessServerToken;
  }
}