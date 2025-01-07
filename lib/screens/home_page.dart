import 'package:flutter/material.dart';
import 'admin_page.dart';
import 'user_page.dart';

class HomePage extends StatelessWidget {
  final String role;

  const HomePage({Key? key, required this.role}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return role == 'admin'
        ? AdminPage()
        : UserPage();
  }
}
