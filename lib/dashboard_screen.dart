import 'package:flutter/material.dart';
import 'campus_events_screen.dart';

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
          const Card(child: Center(child: Text('Academic Calendar'))),
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

          const Card(child: Center(child: Text('Emergency Info'))),
        ],
      ),
    );
  }
}
