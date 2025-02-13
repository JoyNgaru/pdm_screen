import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/login_screen.dart';
import '../screens/patient_home_screen.dart';
import '../screens/doctor_home_screen.dart';
import '../screens/caregiver_home_screen.dart';

class PdmNavigationDrawer extends StatelessWidget {
  final String username;
  final String userId;
  final String role;

  const PdmNavigationDrawer({
    Key? key,
    required this.username,
    required this.userId,
    required this.role,
  }) : super(key: key);

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  Future<void> _navigateToHome(BuildContext context) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
      return;
    }

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
        return;
      }

      Map<String, dynamic>? data = userDoc.data() as Map<String, dynamic>?;
      if (data == null ||
          !data.containsKey('role') ||
          !data.containsKey('id')) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
        return;
      }

      String role = data['role'];
      String userId = data['id'];
      String username = data['email'].split('@')[0];

      Widget homeScreen;
      switch (role) {
        case 'Patient':
          homeScreen = PatientHomeScreen(username: username, userId: userId);
          break;
        case 'Doctor':
          homeScreen = DoctorHomeScreen(username: username, userId: userId);
          break;
        case 'Caregiver':
          homeScreen = CaregiverHomeScreen(username: username, userId: userId);
          break;
        default:
          homeScreen = const LoginScreen();
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => homeScreen),
      );
    } catch (e) {
      debugPrint("Error fetching user data: $e");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(username),
            accountEmail: Text("Role: $role (ID: $userId)"),
            currentAccountPicture: const CircleAvatar(
              child: Icon(Icons.person, size: 40),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () => _navigateToHome(
                context), // ✅ Navigate to the correct home screen
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              // TODO: Add navigation to Profile Screen
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            onTap: () {
              // TODO: Add navigation to Notifications Screen
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              // TODO: Add navigation to Settings Screen
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () => _logout(context), // ✅ Logout function
          ),
        ],
      ),
    );
  }
}
