import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crudapp/Services/firestore.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirestoreService firestoreService = FirestoreService();
  final TextEditingController textController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  void openContactsBox(String? docID, {String? existingName, String? existingPhone, String? existingEmail}) {
    textController.text = existingName ?? '';
    phoneController.text = existingPhone ?? '';
    emailController.text = existingEmail ?? '';

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15.0),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Edit Contact',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 10),
                _buildTextField(textController, 'Name'),
                const SizedBox(height: 10),
                _buildTextField(phoneController, 'Phone Number'),
                const SizedBox(height: 10),
                _buildTextField(emailController, 'Email'),
                const SizedBox(height: 20), // Add space before buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          if (docID == null) {
                            await firestoreService.addContact({
                              'name': textController.text,
                              'phone': phoneController.text,
                              'email': emailController.text,
                            });
                          } else {
                            await firestoreService.updateContact(docID, {
                              'name': textController.text,
                              'phone': phoneController.text,
                              'email': emailController.text,
                            });
                          }
                          // Clear text controllers after saving
                          textController.clear();
                          phoneController.clear();
                          emailController.clear();
                          Navigator.pop(context);
                        } catch (e) {
                          // Show error message
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error saving contact: $e')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.green,
                      ),
                      child: const Text('Save'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      textAlign: TextAlign.left,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.blue),
        ),
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
        onPressed: () => openContactsBox(null),
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

            return ListView.builder(
              itemCount: contactsList.length,
              itemBuilder: (context, index) {
                DocumentSnapshot document = contactsList[index];
                Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                String contactText = data['name'] ?? 'No Name';
                String docID = document.id;

                return ListTile(
                  title: Text(contactText),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => openContactsBox(docID,
                          existingName: contactText,
                          existingPhone: data['phone'],
                          existingEmail: data['email'],
                        ),
                        icon: const Icon(Icons.edit),
                      ),
                      IconButton(
                        onPressed: () => firestoreService.deleteContact(docID),
                        icon: const Icon(Icons.delete),
                      ),
                    ],
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('No Contacts'));
          }
        },
      ),
    );
  }
}