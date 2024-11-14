import 'package:chat/services/auth/authservice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PushNotif {
  static final _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin(); //
  static late Stream<List<DocumentSnapshot>> stream;
  static Future initializeNotification() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()!
        .requestNotificationsPermission();

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (payload) {},
    );
    //listenToStatusChnage();
    await initializeCloudMessaging();
  }

  static Future initializeCloudMessaging() async {
    //Terminated

    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? remoteMessage) {
      if (remoteMessage != null) {
        debugPrint(
            "Notification Request On Terminated:: ${remoteMessage.data["rideRequestId"]}");
      }
    });

    // Foreground

    FirebaseMessaging.onMessage.listen((RemoteMessage? remoteMessage) {
      if (remoteMessage!.notification != null) {
        displayNotification(
          title: remoteMessage.notification!.title!,
          body: remoteMessage.notification!.body!,
        );
      }

      debugPrint(
          "Notification Request On Foreground:: ${remoteMessage.data["rideRequestId"]}");
    });

    // Background
    FirebaseMessaging.onMessageOpenedApp.listen(
      (RemoteMessage? remoteMessage) {
        if (remoteMessage!.notification != null) {
          displayNotification(
            title: remoteMessage.notification!.title!,
            body: remoteMessage.notification!.body!,
          );
        }
        debugPrint(
            "Notification Request On Background:: ${remoteMessage.data["rideRequestId"]}");
      },
    );
  }

  Future getDeviceToken({int maxRetires = 3}) async {
    User? currentUser = Authservice().auth.currentUser;

    try {
      String? registrationToken;
      registrationToken = await _messaging.getToken();

      debugPrint("FCM token $registrationToken");
      Map<String, dynamic> data = {
        "notificationToken": registrationToken,
      };
      Authservice()
          .store
          .collection("Users")
          .doc(currentUser!.uid)
          .update(data);

      return registrationToken;
    } catch (e) {
      if (maxRetires > 0) {
        await Future.delayed(const Duration(seconds: 10));
        return getDeviceToken(maxRetires: -1);
      }
    }
  }

  static displayNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      'Default',
      'Basic Notification',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    var platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await _flutterLocalNotificationsPlugin.show(
      int.parse(1.toString()),
      title,
      body,
      platformChannelSpecifics,
      // payload: payload,
    );
  }
}
