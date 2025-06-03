import 'package:flutter/material.dart';
import 'package:school_forum/home.dart';
import 'package:school_forum/login.dart';

void main() {
  runApp(const MyApp());
}

class AppRoutes {
  static const String home = 'home';
  static const String login = 'login';
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      title: '校园集市',
      debugShowCheckedModeBanner: false,
      routes: {
        AppRoutes.home: (context) => const HomePage(),
        AppRoutes.login: (context) => const LoginPage(),
      },
      initialRoute: AppRoutes.login,
    );
  }
}
