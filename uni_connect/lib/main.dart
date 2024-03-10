import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uni_connect/screens/wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';


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

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Wrapper(),
    );
  }
}
