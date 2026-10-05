import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'profile_view.dart';

class MonitorNavigation extends StatefulWidget {
  const MonitorNavigation({super.key});

  @override
  State<MonitorNavigation> createState() => _MonitorNavigationState();
}

class _MonitorNavigationState extends State<MonitorNavigation> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    Center(child: Text('Tableau de bord moniteur')),
    Center(child: Text('Mes apprenants')),
    Center(child: Text('Planning des cours')),
    ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        indicatorColor: AppColors.infoLight,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Accueil'),
          NavigationDestination(icon: Icon(Icons.people_outline), label: 'Apprenants'),
          NavigationDestination(icon: Icon(Icons.calendar_month_outlined), label: 'Planning'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profil'),
        ],
      ),
    );
  }
}