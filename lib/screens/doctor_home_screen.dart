import 'package:flutter/material.dart';
import '../screens/pdm_navigation_drawer.dart';


class DoctorHomeScreen extends StatelessWidget {
  final String username;
  final String userId;

  const DoctorHomeScreen({
    Key? key,
    required this.username,
    required this.userId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Doctor Home")),
      drawer: PdmNavigationDrawer(
        username: username,
        userId: userId,
        role: "Doctor",
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Hello Dr. $username (ID: $userId),",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              "Welcome to PD Monitor! You're here to help patients.",
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
