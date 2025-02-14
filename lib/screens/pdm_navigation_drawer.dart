import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/login_screen.dart';
import '../screens/patient_home_screen.dart';
import '../screens/doctor_home_screen.dart';
import '../screens/caregiver_home_screen.dart';
import '../screens/chatbot_screen.dart';
import '../screens/contacts_screen.dart';
import 'package:pdm_screen/screens/chat_screen.dart';

class PdmNavigationDrawer extends StatelessWidget {
  final String username;
  final String userId;
  final String role;

  const PdmNavigationDrawer({
    super.key,
    required this.username,
    required this.userId,
    required this.role,
  });

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
      if (data == null || !data.containsKey('role')) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
        return;
      }

      String role = (data['role'] as String).toLowerCase();
      String username = data['email'].split('@')[0];
      String userId = data.containsKey('pid')
          ? data['pid']
          : data.containsKey('did')
              ? data['did']
              : data.containsKey('cid')
                  ? data['cid']
                  : "0000"; // Default ID

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
            onTap: () => _navigateToHome(context),
          ),
          ListTile(
            leading: Icon(Icons.contacts),
            title: Text("My Contacts"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ContactsScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.chat),
            title: const Text('Chat'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChatScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.sos),
            title: const Text('SOS'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.support),
            title: const Text('Support'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChatbotScreen()),
              );
            },
          ),
          if (role == 'patient') ...[
            ListTile(
              leading: const Icon(Icons.monitor_heart),
              title: const Text('Monitor'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('My Info'),
              onTap: () {},
            ),
          ],
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }
}
