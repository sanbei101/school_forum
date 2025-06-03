import 'package:flutter/material.dart';
import 'package:school_forum/main.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login Page')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.home);
          },
          child: const Text('Go to Main Page'),
        ),
      ),
    );
  }
}
