import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'screens/patient_home_screen.dart';
import 'screens/doctor_home_screen.dart';
import 'screens/caregiver_home_screen.dart';
import 'screens/login_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  /// ✅ Determines the home screen based on Firestore data
  Future<Widget> _getHomeScreen(User? user) async {
    if (user == null) {
      debugPrint("❌ No user found. Redirecting to LoginScreen.");
      return LoginScreen();
    }

    try {
      debugPrint("🔄 Fetching user data for UID: ${user.uid}");
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final data = userDoc.data();
      debugPrint("🔥 Firestore Raw Data: $data");

      if (data == null) {
        debugPrint("❌ Firestore document is null.");
        return LoginScreen();
      }

      if (!data.containsKey('role') ||
          !data.containsKey('email') ||
          !data.containsKey('pid')) {
        debugPrint("❌ Missing required fields: ${data.keys}");
        return LoginScreen();
      }

      final String username = data['email'].split('@')[0];
      final String userId = data['pid']; // ✅ Fetching `pid`
      final String role = data['role'];

      debugPrint("✅ User role: $role, User ID: $userId");

      switch (role) {
        case 'patient':
          return PatientHomeScreen(username: username, userId: userId);
        case 'doctor':
          return DoctorHomeScreen(username: username, userId: userId);
        case 'caregiver':
          return CaregiverHomeScreen(username: username, userId: userId);
        default:
          debugPrint("❌ Invalid role detected: $role");
          return LoginScreen();
      }
    } catch (e) {
      debugPrint("❌ Error fetching user data: $e");
      return LoginScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        final user = snapshot.data;
        return FutureBuilder<Widget>(
          future: _getHomeScreen(user),
          builder: (context, homeSnapshot) {
            if (homeSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                  body: Center(child: CircularProgressIndicator()));
            }
            return homeSnapshot.data ?? LoginScreen();
          },
        );
      },
    );
  }
}
