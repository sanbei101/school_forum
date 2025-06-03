import 'package:flutter/material.dart';
import 'package:school_forum/pages/home.dart';
import 'package:school_forum/pages/login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const supabaseUrl = 'https://synuuwhejivukiaodagq.supabase.co';
const supabaseKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InN5bnV1d2hlaml2dWtpYW9kYWdxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDg5NDMyNjAsImV4cCI6MjA2NDUxOTI2MH0.-vhTUsTzbdUMJh0EEFP-BSCcF66nkxqk0AIY1qNIC-A';

Future<void> main() async {
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);
  runApp(MyApp());
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
