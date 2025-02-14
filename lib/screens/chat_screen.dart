import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_page.dart'; // Import ChatPage

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Map<String, String>> contacts = [];
  bool isLoading = true; // Track loading state

  @override
  void initState() {
    super.initState();
    fetchContacts();
  }

  // Fetch contacts from Firestore subcollection
  Future<void> fetchContacts() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final contactsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('contacts') // ✅ Fetch from subcollection
          .get();

      if (contactsSnapshot.docs.isEmpty) {
        print("No contacts found in Firestore!");
      }

      List<Map<String, String>> loadedContacts = [];

      for (var doc in contactsSnapshot.docs) {
        final data = doc.data();
        print("Fetched Contact: $data"); // Debugging Output

        loadedContacts.add({
          "id": data["id"] ?? "",
          "name": data["name"] ?? "Unknown",
          "email": data["email"] ?? "No Email",
          "role": data["role"] ?? "No Role",
        });
      }

      setState(() {
        contacts = loadedContacts;
        isLoading = false; // Stop loading indicator
      });

      print("Final Contacts List: $contacts");
    } catch (e) {
      print("Error fetching contacts: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chat")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loading
          : contacts.isEmpty
              ? const Center(child: Text("No contacts found"))
              : ListView.builder(
                  itemCount: contacts.length,
                  itemBuilder: (context, index) {
                    final contact = contacts[index];
                    return ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(contact["name"] ?? "Unknown"),
                      subtitle:
                          Text("${contact["email"]} • ${contact["role"]}"),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatPage(
                              receiverId: contact["id"]!,
                              receiverName: contact["name"]!,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: fetchContacts, // Refresh Contacts
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
