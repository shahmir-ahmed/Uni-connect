import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_connect/screens/wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:internet_connection_checker/internet_connection_checker.dart';

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

  // navigator keys
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // internet connectivity variables
  late StreamSubscription subscription;
  bool isDeviceConnected = false;
  bool isAlertSet = false;

/*
  // internet connection check variables
  bool isDeviceConnected = false;
  bool isAlertSet = false;

  // internet connection check method
  getConnectivity() => Connectivity().onConnectivityChanged.listen(
        (ConnectivityResult result) async {
          isDeviceConnected = await InternetConnectionChecker().hasConnection;
          if (!isDeviceConnected && isAlertSet == false) {
            showDialogBox(context);
            setState(() => isAlertSet = true);
          }
        },
      );

  // alert dialog box when internet is disconnected
  showDialogBox(BuildContext context) {
    // set up the buttons
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () async {
        // close the alert dialog
        Navigator.pop(context, 'Cancel');
        setState(() => isAlertSet = false);
        isDeviceConnected = await InternetConnectionChecker().hasConnection;
        if (!isDeviceConnected && isAlertSet == false) {
          showDialogBox(context);
          setState(() => isAlertSet = true);
        }
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("No Connection"),
      content: Text("Please check your internet connectivity"),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
  */

  /*
  1. When app closed and student logged in 2 times notifcation is showing
  2. When app closed and student logged out 1 times notifcation is showing

  3. When app is opened and student logged in 1 times notifcation is showing
  4. When app is opened and student logged out notification is not showing

  5. When app is in background and student is logged in 1 time notifcation is showing
  6. When app is in background and student is logged out 1 time notification is showing

  Re: (03-04-2024) (Samsung)
  1. When app closed and student logged in 2 times notifcation is showing
  2. When app is in background and student is logged in 2 times notifcation is showing but previous double notification changed to single.
  3. When app is opened and student logged in 1 times notifcation is showing but previous double notification changed to single.

  order changed:
  1. When app is closed and student logged in 2 times notifcation is showing
  2. When app is opened and student logged in 1 times notifcation is showing but previous double notification changed to single.
  3. When app is in background and student is logged in 2 times notifcation is showing but previous single notification gone.

  4. When app is closed and student logged out 1 time notifcation is showing
  5. When app is opened and student logged out notification is not showing
  6. When app is in background and student is logged out 1 time notification is showing


  After removing background handler code: (Success, only background logged out notification recieving issue) (Previous double and single notification auto removed issue also gone)
  1. When app is opened and student is logged in 1 times notifcation is showing.
  2. When app is in background and student is logged in 1 time notifcation is showing.
  3. When app is closed and student is logged in 1 time notifcation is showing.

  4. When app is closed and student is logged out NO notifcation is showing
  5. When app is opened and student is logged out notification is NOT showing
  6. When app is in background and student is logged out 1 time notification is showing

  When logged out from student and logged into uni from same device:
  When app is closed and uni logged in:
  1. Notification is recived one time.

  When app is opened and uni logged in:
  1. Not recieved.
  
  When app is in background and uni logged in:
  1. Notification is recived one time.
  */

  @override
  void initState() {
    getConnectivity(); // Firestore works offline through Firestore Persistance feature. (login works but updating to firestore stucked on loading screen)
    // TODO: implement initState
    super.initState();
    // Initialize Firebase Messaging
    _initializeFirebaseMessaging();
    // Setup message handlers
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // print("Notification recieved!"); // not printed when app is in background and inside show notification function type also, then how is background notification showing?
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
    // FirebaseMessaging.onBackgroundMessage(
    //     _firebaseMessagingBackgroundHandler); // double notification showing when app is closed and student logged in is also glitch (solved when remove this line of code)
  }

  // initialize firebase messaging
  Future<void> _initializeFirebaseMessaging() async {
    // Request permission for receiving notifications on iOS
    await _firebaseMessaging.requestPermission();

    // Get the token
    String? token = await _firebaseMessaging.getToken();
    print("Firebase Messaging Token: $token");
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

  /*
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

    // Notification showing in all cases depict that in background and app is closed, this code cannot access the shared pref. or something different?

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
*/

  // internet connection check method
  // when app is opened first time this listener is registered
  getConnectivity() {
    subscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) async {
      for (ConnectivityResult result in results) {
        // listens for internet connection changes (when internet is connected or disconnected event is sent here)
        isDeviceConnected = await InternetConnectionChecker().hasConnection;
        // setState(() {
        //   this.isDeviceConnected = isDeviceConnected;
        // });
        if (!isDeviceConnected && isAlertSet == false) {
          // after 3 seconds show alert beacuse when first time user opens app and user is not connected to internet the splash screen is showing and above it this alert is shown and then instead of splash screen popping out after 2 secs this alert dialog is popped out
          // print('here'); // printed once
          _showDelayedNoInternetDialog();
        }
        /*
        else if (isDeviceConnected && isAlertSet == false) {
          print('Checking internet accesss 1');
          // If connected, check internet access
          _checkInternetAccess();
        }
        */
      }
    });
  }
/*
  // function to check if device is connected then is there internet access or not
  Future<void> _checkInternetAccess() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      print('result: $result');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        // Internet access available
        // Navigator.of(context).pop(); // Dismiss previous dialog if any
      } else {
        // No internet access, show AlertDialog
        // _showDelayedNoInternetDialog();
        showDialogBox(); // show dialog box instantly
      }
    } on SocketException catch (_) {
      print("Error accessing internet: $_");
      // No internet access, show AlertDialog
      // _showDelayedNoInternetDialog();
      showDialogBox(); // show dialog box instantly
    }
  }
  */

  // show no internet dialog delayed for 3sec
  _showDelayedNoInternetDialog() {
    Future.delayed(Duration(seconds: 3), () {
      showDialogBox();
      setState(() => isAlertSet = true);
    });
  }

  // show no internet alert dialog
  showDialogBox() => showCupertinoDialog<String>(
        context: navigatorKey.currentState!.overlay!.context,
        builder: (BuildContext context) => WillPopScope(
          onWillPop: () async =>
              false, // False will prevent and true will allow to dismiss
          child: CupertinoAlertDialog(
            title: const Text('No Connection'),
            content: const Text('Please check your internet connectivity'),
            actions: <Widget>[
              TextButton(
                onPressed: () async {
                  Navigator.pop(context, 'Cancel');
                  // set is alert set as false
                  setState(() => isAlertSet = false);
                  // again check internet status
                  isDeviceConnected =
                      await InternetConnectionChecker().hasConnection;
                  // show alert again if no internet and dialog is not set
                  if (!isDeviceConnected && isAlertSet == false) {
                    // print('here');
                    showDialogBox(); // show instant when closed
                    setState(() => isAlertSet = true);
                  }
                  /*else if (isDeviceConnected && isAlertSet == false) {
                    print('Checking internet accesss 2');
                    // check internet access if connected
                    _checkInternetAccess();
                  }
                  */
                },
                child: const Text('OK'),
              ),
            ],
          ),
        ),
      );

  // build method
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      home: Wrapper(),
/*
      home: !isDeviceConnected && !isAlertSet
          ? Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Material(
                  color: Colors.transparent,
                  child: AlertDialog(
                    title: Text('No Connection'),
                    content: Text('Please check your internet connectivity'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () async {
                          Navigator.pop(context, 'Cancel');
                          setState(() => isAlertSet = false);
                          final isDeviceConnected =
                              await InternetConnectionChecker().hasConnection;
                          setState(() {
                            this.isDeviceConnected = isDeviceConnected;
                          });
                          if (!this.isDeviceConnected && isAlertSet == false) {
                            // showDialogBox();
                            setState(() => isAlertSet = true);
                          }
                        },
                        child: Text('OK'),
                      ),
                    ],
                  )))
          : Wrapper(),
          */
    );
  }

  // dispose method
  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }
}
