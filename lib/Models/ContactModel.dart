//Parsing JSON Data from MongoDB

import 'package:mongo_dart/mongo_dart.dart';
import 'dart:convert';

ContactModel ContactModelFromJson(String str) =>
  ContactModel.fromJson(json.decode(str));

String ContactModelToJson(ContactModel data) => json.encode(data.toJson());

class ContactModel {
  ContactModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.address,
  });

  int id;
  String firstName;
  String lastName;
  String address;

  factory ContactModel.fromJson(Map<String, dynamic> json) => ContactModel(
    id: json["_id"],
    firstName: json["firstName"],
    lastName: json["lastName"],
    address: json["address"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "firstName": firstName,
    "lastName": lastName,
    "address": address,
  };
}