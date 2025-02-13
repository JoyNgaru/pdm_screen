import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../main.dart'; // Import AuthWrapper

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController linkedIdController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String selectedRole = 'Patient'; // Default selection
  String generatedId = ''; // Stores PID, CID, or DID

  // Function to generate a unique ID based on role
  String generateUniqueId(String role) {
    String prefix = role.substring(0, 1).toUpperCase(); // P, C, or D
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    return '$prefix$timestamp';
  }

  // Register User
  Future<void> register() async {
    try {
      String email = emailController.text.trim();
      String password = passwordController.text.trim();
      String linkedId = linkedIdController.text.trim();

      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      String uid = userCredential.user!.uid;
      generatedId = generateUniqueId(selectedRole);

      // Prepare Firestore document
      Map<String, dynamic> userData = {
        'uid': uid,
        'email': email,
        'role': selectedRole,
      };

      // Add the correct ID field based on role
      if (selectedRole == 'Patient') {
        userData['pid'] = generatedId;
        if (linkedId.isNotEmpty) userData['caregiverId'] = linkedId;
      } else if (selectedRole == 'Caregiver') {
        userData['cid'] = generatedId;
        if (linkedId.isNotEmpty) userData['patientId'] = linkedId;
      } else if (selectedRole == 'Doctor') {
        userData['did'] = generatedId;
        if (linkedId.isNotEmpty) userData['patientId'] = linkedId;
      }

      // Store user in Firestore
      await _firestore.collection('users').doc(uid).set(userData);

      debugPrint("✅ Registration successful! Redirecting to AuthWrapper.");

      // Navigate to AuthWrapper (which will redirect based on role)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AuthWrapper()),
      );
    } catch (e) {
      debugPrint("❌ Registration Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Registration failed: ${e.toString()}")),
      );
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    linkedIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password"),
            ),
            const SizedBox(height: 20),
            // Role Selection Dropdown
            DropdownButtonFormField<String>(
              value: selectedRole,
              items: ['Patient', 'Caregiver', 'Doctor']
                  .map((role) =>
                      DropdownMenuItem(value: role, child: Text(role)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedRole = value!;
                });
              },
              decoration: const InputDecoration(labelText: "Select Role"),
            ),
            const SizedBox(height: 10),
            // Show linked ID input field only for Caregivers & Doctors
            if (selectedRole != 'Patient')
              TextField(
                controller: linkedIdController,
                decoration: InputDecoration(
                  labelText: selectedRole == 'Caregiver'
                      ? "Enter Patient ID (PID)"
                      : "Enter Patient ID (PID)",
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: register, child: const Text("Register")),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Already have an account? Login"),
            ),
          ],
        ),
      ),
    );
  }
}
