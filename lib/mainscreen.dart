import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;


FirebaseAuth auth = FirebaseAuth.instance;

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  TextEditingController username = TextEditingController();
  TextEditingController title = TextEditingController();
  TextEditingController body = TextEditingController();
  late AndroidNotificationChannel channel;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  String? mtoken = " ";

  @override
  void initState() {
    super.initState();

    getTokenFromFirestore();

    requestPermission();

    loadFCM();

    listenFCM();

    getToken();

    FirebaseMessaging.instance.subscribeToTopic("Animal");
  }

  List userId = [];
  List userToken = [];
  void getTokenFromFirestore() async {




    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection("UserTokens").get();

    querySnapshot.docs.asMap().forEach((key, value) {
           // print(value.id);
    });
    for (int i = 0; i < querySnapshot.docs.length; i++) {
      var a = querySnapshot.docs[i];

      //print("helllo ${a.id}");
      userId.add(a.id);

      final data = await FirebaseFirestore.instance.collection("UserTokens").doc(a.id).get();

      // userToken.add(data.data()?.values.toString());
      data.data()?.forEach((key, value) {
        userToken.add(value);
      });
      // print("userid $userId");
      print("userid $userToken ");

    }
  }

  void saveToken(String token) async {

    await FirebaseFirestore.instance.collection("UserTokens").doc(auth.currentUser?.uid).set({
      'token' : token,
    });

  }
//String token,
  void sendPushMessage(String token, String title, String body) async {
       // print(token.replaceAll("\\p{P}",""));
      try {
        await http.post(
          Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization': 'key=AAAAjWzSMv8:APA91bEiKYFKwgrEQ-jHbGyEb6D_Uuydfda_gE0mIzY39zJ-LXFFk5OHZuhjKSpTjuLd-KanVf13HQdQvSQ7VWSZYGjpjGjt-_0lckMpQDIVI07F3PzdKtM4kRwIqx25f3IRO6pm4sdY',
          },
          body: jsonEncode(
            <String, dynamic>{
              'notification': <String, dynamic>{
                'body': body,
                'title': title
              },
              'priority': 'high',
              'data': <String, dynamic>{
                'click_action': 'FLUTTER_NOTIFICATION_CLICK',
                'id': '1',
                'status': 'done'
              },
              "to": token,
            },
          ),
        );
      } catch (e) {
        print("error push notification");
      }
  }

  void getToken() async {
    await FirebaseMessaging.instance.getToken().then(
            (token) {
          setState(() {
            mtoken = token;
          });

          saveToken(token!);
        }
    );
  }

  void requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }

  void listenFCM() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null && !kIsWeb) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              // TODO add a proper drawable resource to android, for now using
              //      one that already exists in example app.
              icon: 'launch_background',
            ),
          ),
        );
      }
    });
  }

  void loadFCM() async {
    if (!kIsWeb) {
      channel = const AndroidNotificationChannel(
        'high_importance_channel', // id
        'High Importance Notifications', // title
        importance: Importance.high,
        enableVibration: true,
      );

      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

      /// Create an Android Notification Channel.
      ///
      /// We use this channel in the `AndroidManifest.xml` file to override the
      /// default FCM channel to enable heads up notifications.
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      /// Update the iOS foreground notification presentation options to allow
      /// heads up notifications.
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: username,
            ),
            TextFormField(
              controller: title,
            ),
            TextFormField(
              controller: body,
            ),
            GestureDetector(
              onTap: () async {
                // String name = username.text.trim();
                String? name = auth.currentUser?.uid.toString();
                String titleText = title.text;
                String bodyText = body.text;

                if(name != "") {
                  DocumentSnapshot snap = await FirebaseFirestore.instance.collection("UserTokens").doc(name).get();

                  String token = snap['token'];
                  // print("hello $token");
                  for(int i = 0; i < userToken.length;i++)
                  {
                    // print("hello ${userToken[i]}");
                    sendPushMessage(userToken[i], titleText, bodyText);
                  }
                  //sendPushMessage(token, titleText, bodyText);

                }
              },
              child: Container(
                height: 40,
                width: 200,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}