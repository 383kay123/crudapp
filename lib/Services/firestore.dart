import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  
  // Changed variable name for clarity
  final CollectionReference contactsCollection =  // Renamed from 'contacts'
      FirebaseFirestore.instance.collection('contacts');

  // CREATE: Add a new contact
  Future<void> addContact(String contactName) {  
    return contactsCollection.add({  
      'name': contactName,  
      'timestamp': Timestamp.now(),
    });
  }

  // READ: Get contacts from database
  Stream<QuerySnapshot> getContactsStream() { // Corrected method name for consistency
    // Use contactsCollection instead of contacts
    return contactsCollection.orderBy('timestamp', descending: true).snapshots();
  }

  //update contact given a doc id
  Future<void>updateContact(String docID,String newContact) {
    return contactsCollection.doc(docID).update({
      'name': newContact,
      'timestamp': Timestamp.now(),

    });
  }
}