import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/landing_page_screen.dart';
import 'screens/sign_in_screen.dart';
import 'screens/sign_up_screen.dart';
import 'screens/profile_setup_basic_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/colleges_screen.dart';
import 'screens/scholarships_screen.dart';
import 'screens/examination_screen.dart';
import 'screens/resources_screen.dart';
import 'screens/roadmap_page_screen.dart';
import 'screens/about_us_screen.dart';
import 'screens/profile_page_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppWrapper();
  }
}

class AppWrapper extends StatefulWidget {
  const AppWrapper({super.key});

  @override
  State<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> {
  bool _isAuthenticated = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isAuthenticated = prefs.getBool('isAuthenticated') ?? false;
      _isLoading = false;
    });
  }

  Future<void> _handleLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isAuthenticated', true);
    setState(() {
      _isAuthenticated = true;
    });
  }

  Future<void> _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    setState(() {
      _isAuthenticated = false;
    });
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LandingPageScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return MaterialApp(
      title: 'Career Guidance App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      initialRoute: _isAuthenticated ? '/dashboard' : '/',
      routes: {
        '/': (context) => const LandingPageScreen(),
        '/signin': (context) => SignInScreen(onLogin: _handleLogin),
        '/signup': (context) => SignUpScreen(onSignup: _handleLogin),
        '/profile-setup-basic': (context) => ProfileSetupBasicScreen(onLogin: _handleLogin),
        '/roadmap': (context) => const RoadmapPageScreen(),
        '/dashboard': (context) => MainScaffold(
              currentRoute: '/dashboard',
              onLogout: _handleLogout,
              child: const DashboardScreen(),
            ),
        '/colleges': (context) => MainScaffold(
              currentRoute: '/colleges',
              onLogout: _handleLogout,
              child: const CollegesScreen(),
            ),
        '/scholarships': (context) => MainScaffold(
              currentRoute: '/scholarships',
              onLogout: _handleLogout,
              child: const ScholarshipsScreen(),
            ),
        '/exam': (context) => MainScaffold(
              currentRoute: '/exam',
              onLogout: _handleLogout,
              child: const ExaminationScreen(),
            ),
        '/resources': (context) => MainScaffold(
              currentRoute: '/resources',
              onLogout: _handleLogout,
              child: const ResourcesScreen(),
            ),
        '/about': (context) => MainScaffold(
              currentRoute: '/about',
              onLogout: _handleLogout,
              child: const AboutUsScreen(),
            ),
        '/profile': (context) => MainScaffold(
              currentRoute: '/profile',
              onLogout: _handleLogout,
              child: const ProfilePageScreen(),
            ),
      },
    );
  }
}

// Main Scaffold with Navbar
class MainScaffold extends StatefulWidget {
  final String currentRoute;
  final VoidCallback onLogout;
  final Widget child;

  const MainScaffold({
    super.key,
    required this.currentRoute,
    required this.onLogout,
    required this.child,
  });

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  bool _dropdownOpen = false;

  final List<Map<String, String>> navItems = [
    {'route': '/dashboard', 'label': 'Dashboard'},
    {'route': '/colleges', 'label': 'Colleges'},
    {'route': '/scholarships', 'label': 'Scholarships'},
    {'route': '/exam', 'label': 'Examinations'},
    {'route': '/resources', 'label': 'Resources'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.8),
        elevation: 1,
        title: LayoutBuilder(
          builder: (context, constraints) {
            // Show full menu on desktop, hamburger on mobile
            if (MediaQuery.of(context).size.width < 800) {
              return const Text('Career App', style: TextStyle(color: Colors.black87));
            } else {
              return Row(
                children: navItems.map((item) {
                  final isActive = widget.currentRoute == item['route'];
                  return Padding(
                    padding: const EdgeInsets.only(right: 24.0),
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, item['route']!);
                      },
                      child: Text(
                        item['label']!,
                        style: TextStyle(
                          color: isActive ? Colors.blue[700] : Colors.black87,
                          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            }
          },
        ),
        leading: MediaQuery.of(context).size.width < 800
            ? Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu, color: Colors.black87),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              )
            : null,
        actions: [
          // Bell icon with notification badge
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Colors.black87),
                onPressed: () {
                  // Handle notification
                },
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: const Text(
                    '3',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          // Profile dropdown
          PopupMenuButton<String>(
            icon: const Icon(Icons.person_outline, color: Colors.black87, size: 28),
            offset: const Offset(0, 50),
            onSelected: (value) {
              if (value == 'logout') {
                widget.onLogout();
              } else {
                Navigator.pushNamed(context, value);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: '/profile',
                child: Text('Profile'),
              ),
              const PopupMenuItem(
                value: '/about',
                child: Text('About Us'),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
          ),
          const SizedBox(width: 16),
        ],
      ),
      drawer: MediaQuery.of(context).size.width < 800
          ? Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  const DrawerHeader(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF444EE7), Color(0xFF6B74FF)],
                      ),
                    ),
                    child: Text(
                      'Menu',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ...navItems.map((item) {
                    final isActive = widget.currentRoute == item['route'];
                    return ListTile(
                      title: Text(
                        item['label']!,
                        style: TextStyle(
                          color: isActive ? Colors.blue[700] : Colors.black87,
                          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      selected: isActive,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, item['route']!);
                      },
                    );
                  }).toList(),
                ],
              ),
            )
          : null,
      body: widget.child,
    );
  }
}