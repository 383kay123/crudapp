import 'package:flutter/material.dart';

class EditContactPage extends StatelessWidget {
  final Map<String, dynamic> contactData;  // Pass in the contact data as a parameter

  const EditContactPage({required this.contactData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Contact'),
      ),