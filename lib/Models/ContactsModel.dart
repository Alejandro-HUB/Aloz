// ignore_for_file: file_names

import 'dart:convert';

class Contact {
  String id;
  String firstName;
  String lastName;
  String emailAddress;

  Contact({
    this.id = '',
    this.firstName = '',
    this.lastName = '',
    this.emailAddress = '',
  });

  Contact.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        firstName = json['firstName'],
        lastName = json['lastName'],
        emailAddress = json['emailAddress'];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'emailAddress': emailAddress
    };
  }

  static List<Contact> populateContactsList(
      final data, List<Contact> rowsData) {
    for (int i = 0; i < data.size; i++) {
      Contact newContact = Contact(
        id: "${data.docs[i]['id']}",
        firstName: "${data.docs[i]['firstName']}",
        lastName: "${data.docs[i]['lastName']}",
        emailAddress: "${data.docs[i]['emailAddress']}",
      );

      rowsData.add(newContact);
    }
    return rowsData;
  }

  List<Contact> convertJsonToContactList(String jsonStr) {
    List<Contact> contacts = [];

    List<dynamic> jsonData = jsonDecode(jsonStr);
    for (var item in jsonData) {
      Contact contact = Contact.fromJson(item);
      contacts.add(contact);
    }

    return contacts;
  }
}
