import 'package:flutter/material.dart';
import 'package:garage_opener_mobile_client/pages/root_page.dart';
import 'package:garage_opener_mobile_client/services/authentication.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}


class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Garage Opener',
        theme: new ThemeData(
            primarySwatch: Colors.green
        ),
        home: new RootPage(auth: new Auth())
    );
  }
}