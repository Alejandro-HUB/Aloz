import 'dart:collection';

import 'package:mongo_dart/mongo_dart.dart';
import 'package:projectcrm/Models/ContactModel.dart';
import 'package:flutter/cupertino.dart';

class ContactNotifier with ChangeNotifier {
  List<Contact> _contactsList = [];
  Contact _currentContact = new Contact();

  UnmodifiableListView<Contact> get contacts => UnmodifiableListView(_contactsList);

  Contact get currentContact => _currentContact;
  set contactList(List<Contact> contactList){
    _contactsList = contactList;
    notifyListeners();
  }

  set currentContact(Contact contact){
    _currentContact = contact;
    notifyListeners();
  }
}