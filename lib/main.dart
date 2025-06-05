import 'package:flutter/material.dart';
import 'package:school_forum/pages/home.dart';
import 'package:school_forum/pages/login.dart';
import 'package:school_forum/pages/me.dart';
import 'package:school_forum/pages/search.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const supabaseUrl = 'https://synuuwhejivukiaodagq.supabase.co';
const supabaseKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InN5bnV1d2hlaml2dWtpYW9kYWdxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDg5NDMyNjAsImV4cCI6MjA2NDUxOTI2MH0.-vhTUsTzbdUMJh0EEFP-BSCcF66nkxqk0AIY1qNIC-A';

Future<void> main() async {
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);
  runApp(MyApp());
}

class AppRoutes {
  static const String main = '/';
  static const String login = '/login';
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
        AppRoutes.login: (context) => const LoginPage(),
        AppRoutes.main: (context) => const MainContainer(),
      },
      initialRoute: AppRoutes.login,
    );
  }
}

class MainContainer extends StatefulWidget {
  const MainContainer({super.key});

  @override
  State<MainContainer> createState() => _MainContainerState();
}

class _MainContainerState extends State<MainContainer> {
  int _currentIndex = 0;

  late final PageController _pageController = PageController(
    initialPage: _currentIndex,
  );
  final List<Widget> _pages = [
    const HomePage(),
    const SearchPage(),
    const MePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF1A1A1A),
        selectedItemColor: const Color(0xFF00D4AA),
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          _pageController.jumpToPage(index);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.store), label: '集市'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: '搜索'),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: '消息',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: '我的',
          ),
        ],
      ),
    );
  }
}
