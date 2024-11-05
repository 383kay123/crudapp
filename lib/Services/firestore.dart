import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  // Define the contacts collection reference
  final CollectionReference contactsCollection =
      FirebaseFirestore.instance.collection('contacts');

  // Method to update a contact
  Future<void> updateContact(String docID, Map<String, String> data) async {
    await contactsCollection.doc(docID).update(data);
  }

  // Method to add a contact
  Future<void> addContact(Map<String, String> data) async {
    await contactsCollection.add(data);
  }

  // READ: Get contacts from database
  Stream<QuerySnapshot> getContactsStream() {
    return contactsCollection.orderBy('timestamp', descending: true).snapshots();
  }

  // Update contact given a doc id
  Future<void> updateContactById(String docID, String newContact) async {
    await contactsCollection.doc(docID).update({
      'name': newContact,
      'timestamp': Timestamp.now(),
    });
  }

  // Delete contacts from database
  Future<void> deleteContact(String docID) async {
    await contactsCollection.doc(docID).delete();
  }
}