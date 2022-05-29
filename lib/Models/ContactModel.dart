import 'package:mongo_dart/mongo_dart.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class Contact {
  String id = "";
  String firstName = "";
  String lastName = "";
  DateTime createdDate = DateTime.now();

  Contact();

  Contact.fromMap(Map<String, dynamic> data){
    id = data['id'];
    firstName = data['firstName'];
    lastName = data['lastName'];
    createdDate = data['createdDate'];
  }
}
