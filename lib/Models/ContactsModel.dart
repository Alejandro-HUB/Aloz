class Contact {
  String firstName;
  String lastName;

  Contact({
    this.firstName = '',
    this.lastName = '',
  });

  static List<Contact> populateContactsList(
      final data, List<Contact> rowsData) {
    for (int i = 0; i < data.size; i++) {
      Contact newContact = Contact(
          firstName: "${data.docs[i]['firstName']}",
          lastName: "${data.docs[i]['lastName']}");
      rowsData.add(newContact);
    }
    return rowsData;
  }
}
