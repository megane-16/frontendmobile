import 'package:driveflow1/acceuil.dart';
import 'package:flutter/material.dart';
import 'views/lessons_viewer.dart';
import 'views/theory_view.dart';
import 'views/exam_view.dart';
import 'views/profile_view.dart';
import 'constants/app_colors.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  const CustomBottomNavigationBar({super.key});

  @override
  State<CustomBottomNavigationBar> createState() => _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  int _currentIndex = 0;

  // Liste des 5 vues/pages
  final List<Widget> _pages = [
    const Accueil(),       // Page d'accueil (Landing)
    const LessonsView(),   // Mes Leçons
    const TheoryView(),    // Théorie / Quiz
    const ExamView(),      // Examens
    const ProfileView(),   // Profil
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        elevation: 8,
        backgroundColor: AppColors.white,
        indicatorColor: AppColors.infoLight,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: AppColors.primary),
            label: 'Accueil',
          ),
          NavigationDestination(
            icon: Icon(Icons.directions_car_outlined),
            selectedIcon: Icon(Icons.directions_car, color: AppColors.primary),
            label: 'Leçons',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book, color: AppColors.primary),
            label: 'Théorie',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment, color: AppColors.primary),
            label: 'Examens',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: AppColors.primary),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}