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
}
