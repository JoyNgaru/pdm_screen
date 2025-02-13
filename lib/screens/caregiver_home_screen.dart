import 'package:flutter/material.dart';
import '../screens/pdm_navigation_drawer.dart';

class CaregiverHomeScreen extends StatelessWidget {
  final String username;
  final String userId;

  const CaregiverHomeScreen({
    Key? key,
    required this.username,
    required this.userId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Caregiver Home")),
      drawer: PdmNavigationDrawer(
        username: username,
        userId: userId,
        role: "Caregiver",
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Added padding for better UI
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Hello $username (ID: $userId),",
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                "Welcome to PD Monitor! Your care makes a difference.",
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
