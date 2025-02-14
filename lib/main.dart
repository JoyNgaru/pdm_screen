import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'screens/patient_home_screen.dart';
import 'screens/doctor_home_screen.dart';
import 'screens/caregiver_home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/chatbot_screen.dart'; // Adjust path based on your project

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Ensure .env file loads properly
  try {
    await dotenv.load(fileName: ".env");
    debugPrint("✅ .env file loaded successfully");
  } catch (e) {
    debugPrint("❌ Error loading .env file: $e");
  }

  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PD Monitor',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  late Stream<User?> _authStream;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _authStream = FirebaseAuth.instance.authStateChanges();
  }

  Future<void> _fetchUserData(User user) async {
    try {
      debugPrint("🔄 Fetching user data for UID: ${user.uid}");
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        debugPrint("❌ User data not found in Firestore.");
        return;
      }

      final data = userDoc.data() as Map<String, dynamic>?;

      if (data == null || !data.containsKey('role')) {
        debugPrint("❌ Missing role in Firestore.");
        return;
      }

      setState(() {
        _userData = data;
      });

      debugPrint("✅ Firestore Data: $_userData");
    } catch (e) {
      debugPrint("❌ Error fetching user data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        final user = snapshot.data;

        if (user == null) {
          return const LoginScreen();
        }

        if (_userData == null) {
          _fetchUserData(user);
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        final String role = _userData?['role']?.toLowerCase() ??
            'unknown'; // ✅ Ensuring lowercase matching
        final String username = _userData?['email']?.split('@')[0] ?? 'User';
        final String userId =
            _userData?['pid'] ?? _userData?['cid'] ?? _userData?['did'] ?? '';

        debugPrint("✅ Redirecting based on role: $role");

        switch (role) {
          case 'patient':
            return PatientHomeScreen(username: username, userId: userId);
          case 'doctor':
            return DoctorHomeScreen(username: username, userId: userId);
          case 'caregiver':
            return CaregiverHomeScreen(username: username, userId: userId);
          default:
            debugPrint("❌ Invalid role detected.");
            return const LoginScreen();
        }
      },
    );
  }
}
