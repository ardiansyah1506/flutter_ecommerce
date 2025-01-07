import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/home_page.dart';
import 'screens/login_page.dart';

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
      home: SplashScreen(), // SplashScreen sebagai halaman pertama
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateAfterSplash();
  }

  Future<void> _navigateAfterSplash() async {
    await Future.delayed(Duration(seconds: 3)); // Durasi splash screen

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final role = prefs.getString('role'); // Ambil role pengguna

    if (token != null && role != null) {
      // Jika pengguna sudah login, arahkan ke HomePage sesuai role
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(role: role),
        ),
      );
    } else {
      // Jika belum login, arahkan ke LoginPage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginPage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF5B4F07),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/logo_blankis.png', height: 150),
            const SizedBox(height: 20),
            const Text(
              'Selamat Datang di Blangkis (Blangkon Pakis)',
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFFF9B14F),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
