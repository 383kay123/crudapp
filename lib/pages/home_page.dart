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
                  'Add Contact',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00754B),
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
      
      // Show success message
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Contact saved successfully')),
          );
        }
      });
    } catch (e) {
      // Show error message
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error saving contact')),
          );
        }
      });
    }
  },
  style: ElevatedButton.styleFrom(
    foregroundColor: Colors.white,
    backgroundColor: Color(0xFF00754B),
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
          borderSide: const BorderSide(color: Colors.blue),
        ),
      ),
    );
  }

 @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.white,
    floatingActionButton: FloatingActionButton(
      onPressed: () => openContactsBox(null),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50.0),
      ),
      child:  Image.asset('assets/images/add-user.png'),
    ),
    body: Column(
      children: [
        const SizedBox(height: 40),
        const Padding(
          padding: EdgeInsets.only(left: 20.0), // Add padding to move the text right
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Contacts', // The text you want to display
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00754B),
                  fontFamily: 'Poppins',
                ),
              ),
            
              Divider(
                thickness: 3.0,
                color: Color(0xFF00754B),
                endIndent: 270, // Adjusts line length
              ),
            ],
          ),
        ),
       Expanded(
  child: StreamBuilder<QuerySnapshot>(
    stream: firestoreService.getContactsStream(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      if (snapshot.hasError) {
        return const Center(child: Text('Error fetching contacts'));
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
              title: Text(contactText, 
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
              subtitle: Text(
    data['phone'] ?? 'No Phone Number',
    style: const TextStyle(
      color: Colors.grey,
      fontSize: 14.0,
      fontFamily: 'Poppins',
    ),
  ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    openContactsBox(
                      docID,
                      existingName: contactText,
                      existingPhone: data['phone'],
                      existingEmail: data['email'],
                    );
                  } else if (value == 'delete') {
                    firestoreService.deleteContact(docID);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, color: Color(0xFF00754B)),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete'),
                      ],
                    ),
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
),
      ]
      )
  );
      
}
}
