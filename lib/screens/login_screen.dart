import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'patient_home_screen.dart';
import 'doctor_home_screen.dart';
import 'caregiver_home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> login() async {
    try {
      debugPrint("🔄 Attempting login for: ${emailController.text}");

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      User? user = userCredential.user;
      if (user == null) {
        debugPrint("❌ Login failed, user is null");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login failed, please try again.")),
        );
        return;
      }

      debugPrint("✅ Login successful! UID: ${user.uid}");

      // Fetch user data from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        debugPrint("❌ User data not found in Firestore.");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User data not found. Contact admin.")),
        );
        return;
      }

      Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;
      String role = userData?['role']?.toString().toLowerCase() ?? "";
      String username = userData?['username'] ??
          emailController.text.split('@')[0]; // Default to email username
      String userId = user.uid; // Firebase UID

      if (role.isEmpty) {
        debugPrint("❌ Missing user role in Firestore");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User role missing. Contact admin.")),
        );
        return;
      }

      debugPrint("✅ Role: $role, Username: $username, User ID: $userId");

      // Redirect based on role
      Widget homeScreen;
      switch (role) {
        case 'patient':
          homeScreen = PatientHomeScreen(username: username, userId: userId);
          break;
        case 'doctor':
          homeScreen = DoctorHomeScreen(username: username, userId: userId);
          break;
        case 'caregiver':
          homeScreen = CaregiverHomeScreen(username: username, userId: userId);
          break;
        default:
          debugPrint("❌ Invalid role: $role");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Invalid role. Contact admin.")),
          );
          return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => homeScreen),
      );
    } catch (e) {
      debugPrint("❌ Firebase Login Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login failed: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("PD Monitor")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Welcome to PD Monitor",
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: login, child: const Text("Login")),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const RegisterScreen()),
                );
              },
              child: const Text("Don't have an account? Register"),
            ),
          ],
        ),
      ),
    );
  }
}
