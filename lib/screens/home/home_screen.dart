import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../dashboard/dashboard_screen.dart';
import '../subscribers/subscribers_screen.dart';
import '../meters/meters_screen.dart';
import '../readings/readings_screen.dart';
import '../bills/bills_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    final role = user?.role ?? 'reader';

    List<Widget> screens = [];
    List<BottomNavigationBarItem> navItems = [];

    if (role == 'admin') {
      screens = const [
        DashboardScreen(),
        SubscribersScreen(),
        MetersScreen(),
        ReadingsScreen(),
        BillsScreen(),
      ];
      navItems = const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'الرئيسية'),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'المشتركين'),
        BottomNavigationBarItem(
          icon: Icon(Icons.electric_meter),
          label: 'العدادات',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.speed), label: 'القراءات'),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long),
          label: 'الفواتير',
        ),
      ];
    } else if (role == 'reader') {
      screens = const [ReadingsScreen()];
    } else if (role == 'collector') {
      screens = const [BillsScreen()];
    }

    if (_currentIndex >= screens.length) {
      _currentIndex = 0;
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body:
            screens.isNotEmpty
                ? screens[_currentIndex]
                : const Center(child: Text('لا توجد صلاحيات')),
        bottomNavigationBar:
            navItems.length > 1
                ? BottomNavigationBar(
                  currentIndex: _currentIndex,
                  type: BottomNavigationBarType.fixed,
                  selectedItemColor: Colors.blue.shade700,
                  unselectedItemColor: Colors.grey,
                  onTap: (index) => setState(() => _currentIndex = index),
                  items: navItems,
                )
                : null,
      ),
    );
  }
}
