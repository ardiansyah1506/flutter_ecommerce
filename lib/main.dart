import 'package:flutter/material.dart';
import 'package:frontend/screens/login_page.dart';



void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Role-Based App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginPage(), // SplashScreen sebagai halaman pertama
    );
  }
}
