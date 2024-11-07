import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crudapp/Services/firestore.dart';

class EditContactPage extends StatefulWidget {
  final String? docID;
  final String existingName;
  final String existingPhone;
  final String existingEmail;

  EditContactPage({
    Key? key,
    this.docID,
    required this.existingName,
    required this.existingPhone,
    required this.existingEmail,
  }) : super(key: key);

  @override
  _EditContactPageState createState() => _EditContactPageState();
}

class _EditContactPageState extends State<EditContactPage> {
  final FirestoreService firestoreService = FirestoreService();
  late TextEditingController textController;
  late TextEditingController phoneController;
  late TextEditingController emailController;

  @override
  void initState() {
    super.initState();
    textController = TextEditingController(text: widget.existingName);
    phoneController = TextEditingController(text: widget.existingPhone);
    emailController = TextEditingController(text: widget.existingEmail);
  }

  @override
  void dispose() {
    textController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.dispose();
  }

  Future<void> saveContact() async {
    try {
      if (widget.docID == null) {
        // Add new contact
        await firestoreService.addContact({
          'name': textController.text,
          'phone': phoneController.text,
          'email': emailController.text,
        });
      } else {
        // Update existing contact
        await firestoreService.updateContact(widget.docID!, {
          'name': textController.text,
          'phone': phoneController.text,
          'email': emailController.text,
        });
      }
      Navigator.pop(context, 'Contact saved successfully');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error saving contact')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
    child:   Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            
            const 
            SizedBox(height: 30,),
            const  Text(
                'Contacts', 
                textAlign: TextAlign.center,// The text you want to display
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00754B),
                  fontFamily: 'Poppins',
                ),
              ),

             
            
            const SizedBox(height: 50),
            // Title
            Text(
              widget.docID == null ? 'Add Contact' : 'Edit Contact',
              textAlign: TextAlign.left, 
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF00754B),
                fontFamily: 'Poppins',
              ),
            ),

           const Divider(
              thickness: 2,
              endIndent: 250,
              color: Color(0xFF00754B),
            ),
            const SizedBox(height: 20),
    const Text('Name', style: TextStyle(fontFamily: 'Poppins',fontWeight: FontWeight.w600),),
   
    const SizedBox(height: 5,),
   
    _buildTextField(textController, 'Name', 'Enter your name'), // Unique hint text
   
    const SizedBox(height: 20),
    
    const Text('Phone Number',style: TextStyle(fontFamily: 'Poppins',fontWeight: FontWeight.w600),),
    
   const SizedBox(height: 5,),

    _buildTextField(phoneController, 'Phone Number', 'Enter your phone number'), // Unique hint text
    
    const SizedBox(height: 10),
   
   const Text('Email',style: TextStyle(fontFamily: 'Poppins',fontWeight: FontWeight.w600),),
   
  const SizedBox(height: 5,),

    _buildTextField(emailController, 'Email', 'Enter your email'), // Unique hint text
    
    const SizedBox(height: 20),
            // Buttons Row
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: saveContact,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xFF00754B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Save'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Navigate back on cancel
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ],
        ),
      ),
      ),
    );
  }

  // Helper method to build text fields
  Widget _buildTextField(TextEditingController controller, String label,String hintText) {
    return TextField(
      controller: controller,
      
      textAlign: TextAlign.left,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.black26),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: Colors.white, width: 0.5),
          
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: Color(0xFF00754B),width: 0.5),
        ),
      ),
    );
  }
}