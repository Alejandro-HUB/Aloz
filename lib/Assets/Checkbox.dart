import 'package:flutter/material.dart';
import '../Helpers/Constants/Styling.dart';
import '../Models/ContactsModel.dart';
import '../Pages/Contacts/Contacts.dart';

class MyCheckbox extends StatefulWidget {
  List<Contact> ContactsList = [];

  MyCheckbox({required this.ContactsList});

  @override
  _MyCheckboxState createState() => _MyCheckboxState();
}

class _MyCheckboxState extends State<MyCheckbox> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
        child: ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          itemCount: widget.ContactsList.length,
          itemBuilder: (BuildContext context, int index) {
            return new Container(
              padding: new EdgeInsets.all(4.0),
              child: Column(
                children: <Widget>[
                  new CheckboxListTile(
                      checkColor: Colors.white,
                      activeColor: Styling.orangeDark,
                      dense: true,
                      //font change
                      value: widget.ContactsList[index].selected,
                      onChanged: (bool? val) {
                        itemChange(val, index);
                      })
                ],
              ),
            );
          }),
    ));
  }

  void itemChange(bool? val, int index) {
    setState(() {
      widget.ContactsList[index].selected = val;
    });
  }
}
