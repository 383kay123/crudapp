import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crudapp/Services/firestore.dart';
import 'package:crudapp/pages/editcontact.dart';
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
  // Set the text fields with existing contact data if available
  textController.text = existingName ?? '';
  phoneController.text = existingPhone ?? '';
  emailController.text = existingEmail ?? '';

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => EditContactPage(
        docID: docID,
        existingName: existingName ?? '',
        existingPhone: existingPhone ?? '',
        existingEmail: existingEmail ?? '',
      ),
    ),
  ).then((result) {
    // Show a confirmation snackbar after successful save
    if (result != null && result == 'Contact saved successfully') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result,style: TextStyle(fontFamily: 'Poppins',color: Color(0xFF00754B),),),
        backgroundColor: Colors.white,
        behavior: SnackBarBehavior.floating,),
      );
    }
  });
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
              leading: Image.asset('assets/images/user.png'),
               

              
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
       return Center(
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Image.asset('assets/images/open-box.png'),
     const SizedBox(height: 10,),
      const Text('You have no contacts yet', style: TextStyle(fontFamily: 'Poppins',fontWeight: FontWeight.w400, fontSize: 15),),
    ],
  ),
);
      }
    },
  ),
),
      ]
      )
  );

}
}