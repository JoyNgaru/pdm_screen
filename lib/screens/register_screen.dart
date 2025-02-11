import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController linkedIdController =
      TextEditingController(); // For linking caregivers & doctors to patients
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String selectedRole = 'Patient'; // Default selection
  String generatedId = ''; // Stores PID, CID, or DID

  // Function to generate a unique ID based on role
  String generateUniqueId(String role) {
    String prefix = role
        .substring(0, 1)
        .toUpperCase(); // P for Patient, C for Caregiver, D for Doctor
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    return '$prefix$timestamp';
  }

  // Register User
  Future<void> register() async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      String uid = userCredential.user!.uid;
      generatedId = generateUniqueId(selectedRole);

      // Store user details in Firestore
      await _firestore.collection('users').doc(uid).set({
        'email': emailController.text.trim(),
        'role': selectedRole,
        'id': generatedId,
        if (selectedRole == 'Patient')
          'caregiverId': linkedIdController.text.trim(),
        if (selectedRole == 'Patient')
          'doctorId': linkedIdController.text.trim(),
        if (selectedRole == 'Caregiver')
          'patientId': linkedIdController.text.trim(),
        if (selectedRole == 'Doctor')
          'patientId': linkedIdController.text.trim(),
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Registration failed: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: "Password"),
            ),
            SizedBox(height: 20),
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
              decoration: InputDecoration(labelText: "Select Role"),
            ),
            SizedBox(height: 10),
            // Show linked ID input field only for Patients, Caregivers, and Doctors
            if (selectedRole != 'Patient')
              TextField(
                controller: linkedIdController,
                decoration: InputDecoration(
                  labelText: selectedRole == 'Caregiver'
                      ? "Enter Patient ID (PID)"
                      : "Enter Patient ID (PID)",
                ),
              ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: register, child: Text("Register")),
            SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Already have an account? Login"),
            ),
          ],
        ),
      ),
    );
  }
}
