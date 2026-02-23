import 'package:flutter/material.dart';
import 'campus_events_screen.dart';
import 'emergency_info_screen.dart';
import 'academic_calendar_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(12),
        children: [
          const Card(child: Center(child: Text('Student Dashboard'))),
          const Card(child: Center(child: Text("Today's Classes"))),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AcademicCalendarScreen(),
                ),
              );
            },
            child: const Card(
              child: Center(child: Text('Academic Calendar')),
            ),
          ),
          const Card(child: Center(child: Text('Reminders'))),

          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>  CampusEventsScreen(),
                ),
              );
            },
            child: const Card(
              child: Center(child: Text('Campus Events')),
            ),
          ),

          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EmergencyInfoScreen(),
                ),
              );
            },
            child: const Card(
              child: Center(child: Text('Emergency Info')),
            ),
          ),
        ],
      ),
    );
  }
}
