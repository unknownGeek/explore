import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:explore/pages/HomePage.dart';
import 'package:flutter/material.dart';

void main()
{
  WidgetsFlutterBinding.ensureInitialized();
  Firestore.instance.settings(timestampsInSnapshotsEnabled: true).then((_) {
    print("Timestamps enabled in snapshots\n");
  }, onError: (_) {
    print("Error enabling timestamps in snapshots\n");
  });
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Explore',
      debugShowCheckedModeBanner: false,
      theme: ThemeData
      (
        scaffoldBackgroundColor: Colors.black,
        dialogBackgroundColor: Colors.black,
        primarySwatch: Colors.deepPurple,//grey, blue, teal, deepPurple
        accentColor: Colors.black,
        cardColor: Colors.white70
      ),
      home: HomePage(),
    );
  }
}
// Android - 1 : Newly Added : emulator 5554
// Android - 2 : Old one : emulator 5556