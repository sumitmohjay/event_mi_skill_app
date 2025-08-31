import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:event_mi_skill/src/features/presentation/event_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'src/features/presentation/home_page.dart';
import 'src/features/presentation/event_organizer_profile_page.dart';
import 'src/features/presentation/user_management_page.dart';
import 'src/group_page/group_page.dart';
import 'src/event_management/provider/event_provider.dart';
import 'src/event_management/event_local_datasource.dart';
import 'src/event_management/event_repository_impl.dart';
import 'src/widgets/app_header.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sharedPreferences = await SharedPreferences.getInstance();
  runApp(MyApp(sharedPreferences: sharedPreferences));
}

class MyApp extends StatelessWidget {
  final SharedPreferences sharedPreferences;
  
  const MyApp({super.key, required this.sharedPreferences});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider<EventProvider>(
              create: (_) => EventProvider(
                eventRepository: EventRepositoryImpl(
                  localDataSource: EventLocalDataSourceImpl(
                    sharedPreferences: sharedPreferences,
                  ),
                ),
              ),
            ),
          ],
          child: MaterialApp(
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
          ),
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
  
  // List of page titles for the header
  final List<String> _pageTitles = [
    'Home',
    'Events',
    'User',
    'Groups',
    'Profile',
  ];
  
  // List of pages for navigation
  final List<Widget> _pages = [
    const HomePage(),
    const EventPage(),
    const UserManagementPage(),
    const GroupPage(),
    const EventOrganizerProfilePage(),
  ];
  
  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      const Icon(Icons.home_outlined, size: 30, color: Colors.white),
      const Icon(Icons.event, size: 30, color: Colors.white),
      const Icon(Icons.person_outline, size: 30, color: Colors.white),
      const Icon(Icons.group_outlined, size: 30, color: Colors.white),
      const Icon(Icons.account_circle_outlined, size: 30, color: Colors.white),
    ];

    return Scaffold(
      appBar: AppHeader(
        title: _pageTitles[_selectedIndex],
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Handle notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Handle search
            },
          ),
        ],
      ),
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