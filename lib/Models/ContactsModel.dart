class Contact {
  String firstName;
  String lastName;
  String emailAddress;
  bool? selected;

  Contact({
    this.firstName = '',
    this.lastName = '',
    this.emailAddress = '',
    this.selected = false,
  });

  static List<Contact> populateContactsList(
      final data, List<Contact> rowsData) {
    for (int i = 0; i < data.size; i++) {
      Contact newContact = Contact(
          firstName: "${data.docs[i]['firstName']}",
          lastName: "${data.docs[i]['lastName']}",
          emailAddress: "${data.docs[i]['emailAddress']}");
      rowsData.add(newContact);
    }
    return rowsData;
  }
}
