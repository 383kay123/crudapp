import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crudapp/Services/firestore.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Firestore service
  final FirestoreService firestoreService = FirestoreService();

  // Text controller
  final TextEditingController textController = TextEditingController();

  void openContactsBox(String? docID) {
    // Clear the text controller when opening the dialog
    textController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: TextField(
          controller: textController,
          textAlign: TextAlign.right, // Align text to the right
          decoration: InputDecoration(
            hintText: docID == null ? 'Add a new contact' : 'Update contact', // Change hint based on mode
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              if (docID == null) {
                // Add a new contact
                firestoreService.addContact(textController.text);
              } else {
                // Update the existing contact
                firestoreService.updateContact(docID, textController.text);
              }

              // Clear the text controller and close the box
              textController.clear();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.green,
            ),
            child: const Text('Save'), // Changed to 'Save' for clarity
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Center(
          child: Text(
            'Contacts',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => openContactsBox(null), // Pass null for new contact
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getContactsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            List<DocumentSnapshot> contactsList = snapshot.data!.docs;

            // Display the data as a list
            return ListView.builder(
              itemCount: contactsList.length,
              itemBuilder: (context, index) {
                DocumentSnapshot document = contactsList[index];

                // Get contact data
                Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                String contactText = data['name'] ?? 'No Name';
                String docID = document.id; // Get the document ID

                return ListTile(
                  title: Text(contactText),
                  trailing: IconButton(
                    onPressed: () => openContactsBox(docID), // Pass the document ID to update
                    icon: const Icon(Icons.edit), // Changed icon to edit for clarity
                  ),
                );
              },
            );
          } else {
            // If there is no data, return a message
            return const Center(child: Text('No Contacts'));
          }
        },
      ),
    );
  }
}