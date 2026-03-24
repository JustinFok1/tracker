import 'package:flutter/material.dart';
import 'package:peptide_tracker/screens/add_vial_screen.dart';
import 'calender_screen.dart';
import 'home_screen.dart';
import 'track_screen.dart';
import '../widgets/bottom_nav.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;

  final screens = [
    const HomeScreen(),
    const TrackScreen(),
    const CalendarScreen(),
    const Center(child: Text("Lifestyle")),
    const Center(child: Text("Profile")),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),

      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: screens[currentIndex]),

            Padding(
              padding: const EdgeInsets.all(16),
              child: BottomNav(
                currentIndex: currentIndex,
                onTap: (index) {
                  setState(() => currentIndex = index);
                },
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddVialScreen(),
            ),
          );
        },
        backgroundColor: const Color(0xFFB388FF),
        child: const Icon(Icons.add),
      ),
    );
  }
}