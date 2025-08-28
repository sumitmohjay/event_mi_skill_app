import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:event_mi_skill/src/features/presentation/event_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'src/features/presentation/home_page.dart';
import 'src/features/presentation/profile_page.dart';
import 'src/features/presentation/setting_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return MaterialApp(
          title: 'Event App',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.blue,
            useMaterial3: true,
            appBarTheme: const AppBarTheme(
              centerTitle: true,
              elevation: 0,
              backgroundColor: Colors.white,
              iconTheme: IconThemeData(color: Colors.black),
              titleTextStyle: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          home: const MainPage(),
        );
      },
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  
  // List of pages for navigation
  final List<Widget> _pages = [
    const HomePage(),
    const EventPage(),
    const Scaffold(
      extendBody: true,
      body: Center(
        child: Text(
          'Favorites Page',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    ),
    const SettingPage(),
    const ProfilePage(),
  ];
  
  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      const Icon(Icons.home_outlined, size: 30, color: Colors.white),
      const Icon(Icons.event, size: 30, color: Colors.white),
      const Icon(Icons.favorite_border, size: 30, color: Colors.white),
      const Icon(Icons.settings_outlined, size: 30, color: Colors.white),
      const Icon(Icons.person_outline, size: 30, color: Colors.white),
    ];

    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: CurvedNavigationBar(
        items: items,
        index: _selectedIndex,
        height: 60.0, // Using fixed height instead of .h extension
        color: Colors.black,
        buttonBackgroundColor: Colors.red,
        backgroundColor: Colors.transparent, // Changed to transparent
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 300),
        letIndexChange: (index) => true,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}