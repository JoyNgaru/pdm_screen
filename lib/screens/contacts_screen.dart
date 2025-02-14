import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ContactsScreen extends StatefulWidget {
  @override
  _ContactsScreenState createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final TextEditingController _idController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late User _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser!;
  }

  Future<void> _addContact() async {
    String enteredId = _idController.text.trim();
    if (enteredId.isEmpty) return;

    try {
      // Search for user by pid, cid, or did
      QuerySnapshot userQuery = await _firestore
          .collection('users')
          .where('pid', isEqualTo: enteredId)
          .get();

      if (userQuery.docs.isEmpty) {
        userQuery = await _firestore
            .collection('users')
            .where('cid', isEqualTo: enteredId)
            .get();
      }
      if (userQuery.docs.isEmpty) {
        userQuery = await _firestore
            .collection('users')
            .where('did', isEqualTo: enteredId)
            .get();
      }

      if (userQuery.docs.isNotEmpty) {
        DocumentSnapshot userDoc = userQuery.docs.first;
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        String userBId = userDoc.id; // Firestore ID of User B

        // Save User B under User A's contacts
        await _firestore
            .collection('users')
            .doc(_currentUser.uid)
            .collection('contacts')
            .doc(userBId)
            .set({
          "id": enteredId,
          "name": userData['email'].split('@')[0],
          "email": userData['email'],
          "role": userData['role'],
        });

        // 🔥 Auto-add User A to User B's contacts
        DocumentSnapshot currentUserDoc =
            await _firestore.collection('users').doc(_currentUser.uid).get();
        Map<String, dynamic> currentUserData =
            currentUserDoc.data() as Map<String, dynamic>;

        await _firestore
            .collection('users')
            .doc(userBId)
            .collection('contacts')
            .doc(_currentUser.uid)
            .set({
          "id": currentUserData["pid"] ??
              currentUserData["cid"] ??
              currentUserData["did"] ??
              "Unknown",
          "name": _currentUser.email!.split('@')[0],
          "email": _currentUser.email!,
          "role": currentUserData['role'],
        });

        setState(() {
          _idController.clear();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Contact added successfully!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("User not found!")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error adding contact: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("My Contacts")),
      body: Column(
        children: [
          // Contact Input Field
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _idController,
                    decoration: InputDecoration(
                      labelText: "Enter PID, CID, or DID",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _addContact,
                ),
              ],
            ),
          ),

          // Display Contacts
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('users')
                  .doc(_currentUser.uid)
                  .collection('contacts')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("No contacts added yet."));
                }

                return ListView(
                  children: snapshot.data!.docs.map((doc) {
                    Map<String, dynamic> contact =
                        doc.data() as Map<String, dynamic>;
                    return ListTile(
                      leading: Icon(Icons.person),
                      title: Text(contact["name"]),
                      subtitle:
                          Text("${contact["email"]} (${contact["role"]})"),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _firestore
                              .collection('users')
                              .doc(_currentUser.uid)
                              .collection('contacts')
                              .doc(doc.id)
                              .delete();
                        },
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
