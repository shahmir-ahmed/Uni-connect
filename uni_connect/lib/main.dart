import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_connect/screens/wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> main() async {
  // WidgetsFlutterBinding initializing first before firebase app b/c of error
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase first before making any query to firebase
  // await Firebase.initializeApp();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // set orientation of app to potrait only
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  runApp(
      const MyApp()); // fires this function runApp which registers this MyApp() as our root widget
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // fcm object
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  /*
  1. When app closed and student logged in 2 times notifcation is showing
  2. When app closed and student logged out 1 times notifcation is showing

  3. When app is opened and student logged in 1 times notifcation is showing
  4. When app is opened and student logged out notification is not showing

  5. When app is in background and student is logged out 1 time notification is showing
  6. When app is in background and student is logged in 1 time notifcation is showing

  - Device switch and login on another device notification are sent on the new device, and in terminated and background notification is still showing and single not 2 times.
  */

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // Initialize Firebase Messaging
    _initializeFirebaseMessaging();
    // Setup message handlers
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Handle foreground messages
      _showNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Handle notification clicks when the app is in the foreground
      print("Notification clicked: ${message.notification?.title}");
      // You can navigate to a specific screen or perform any desired action
      /*
      void handleMessage(BuildContext context, RemoteMessage message) {
        if (message.data['type'] == 'msj') {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => MessageScreen(
                        id: message.data['id'],
                      )));
        }
      }
      */
    });

    // background notification handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler); // double notification showing when app is closed and student logged in is also glitch
  }

  // initialize firebase messaging
  Future<void> _initializeFirebaseMessaging() async {
    // Request permission for receiving notifications on iOS
    await _firebaseMessaging.requestPermission();

    // Get the token
    String? token = await _firebaseMessaging.getToken();
    print("Firebase Messaging Token: $token");
  }

  // when app in background or terminated handler (not handled by the app, notification are still being recieved in all cases (logged in - background, logged in - terminated and logged out case also))
  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    print("Background message received: ${message.notification?.title}");

    // Handle background messages
    // Check if student is logged in then show notification otherwise not show
    // get the shared preferences instance
    SharedPreferences pref = await SharedPreferences.getInstance();
    // get the shared preferences data
    String? type = pref.getString('userType'); // user type

    // print('type: $type');

    // if a user is logged in and that user is student then show notication
    if (type != null) {
      if (type == 'student') {
        // Display notification in the notification bar
        RemoteNotification? notification = message.notification;
        AndroidNotification? android = message.notification?.android;
        if (notification != null && android != null) {
          // Create a flutter local notification
          var flutterLocalNotificationPlugin =
              FlutterLocalNotificationsPlugin();
          var initializationSettingsAndroid =
              AndroidInitializationSettings('@mipmap/launcher_icon');
          // var initializationSettingsIOS = IOSInitializationSettings();
          var initializationSettings =
              InitializationSettings(android: initializationSettingsAndroid);
          // var initializationSettings = InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
          await flutterLocalNotificationPlugin
              .initialize(initializationSettings);

          // print('showing notification');
          // print('here'); // not printed when user logged out

          var androidPlatformChannelSpecifics = AndroidNotificationDetails(
            'your channel id',
            'your channel name',
            channelDescription: 'your channel description',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: false,
          );
          // var iOSPlatformChannelSpecifics = IOSNotificationDetails();
          var platformChannelSpecifics =
              NotificationDetails(android: androidPlatformChannelSpecifics);
          // var platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);

          await flutterLocalNotificationPlugin.show(
            0,
            notification.title,
            notification.body,
            platformChannelSpecifics,
            payload: 'New Payload',
          );
        }
      }
    }
  }

  // handle foreground notification
  void _showNotification(RemoteMessage message) async {
    // Check if student is logged in then show notification otherwise not show
    // get the shared preferences instance
    SharedPreferences pref = await SharedPreferences.getInstance();
    // get the shared preferences data
    String? type = pref.getString('userType'); // user type

    // print('type: $type');

    // if a user is logged in and that user is student then show notification
    if (type != null) {
      if (type == 'student') {
        // Display notification in the notification bar
        RemoteNotification? notification = message.notification;
        AndroidNotification? android = message.notification?.android;
        if (notification != null && android != null) {
          // Create a flutter local notification
          var flutterLocalNotificationPlugin =
              FlutterLocalNotificationsPlugin();
          var initializationSettingsAndroid =
              AndroidInitializationSettings('@mipmap/launcher_icon');
          // var initializationSettingsIOS = IOSInitializationSettings();
          var initializationSettings =
              InitializationSettings(android: initializationSettingsAndroid);
          // var initializationSettings = InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
          await flutterLocalNotificationPlugin
              .initialize(initializationSettings);

          // print('showing notification'); // also not printed when user logged out and app in background then how is notification showing?, maybe some kind of glitch

          var androidPlatformChannelSpecifics = AndroidNotificationDetails(
            'your channel id',
            'your channel name',
            channelDescription: 'your channel description',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: false,
          );
          // var iOSPlatformChannelSpecifics = IOSNotificationDetails();
          var platformChannelSpecifics =
              NotificationDetails(android: androidPlatformChannelSpecifics);
          // var platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);

          await flutterLocalNotificationPlugin.show(
            0,
            notification.title,
            notification.body,
            platformChannelSpecifics,
            payload: 'New Payload',
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Wrapper(),
    );
  }
}
