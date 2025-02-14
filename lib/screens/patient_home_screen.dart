import 'package:flutter/material.dart';
import 'pdm_navigation_drawer.dart';

class PatientHomeScreen extends StatelessWidget {
  final String username;
  final String userId;

  const PatientHomeScreen({
    super.key,
    required this.username,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Patient Home")),
      drawer: PdmNavigationDrawer(
          username: username, userId: userId, role: "Patient"),
      body: Center(
        child: Text(
          "Hello $username, (ID: $userId) \nWelcome to PD Monitor!",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
