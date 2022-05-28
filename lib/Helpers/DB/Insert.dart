import 'package:flutter/material.dart';

class MongoDbInsert extends StatefulWidget {
  MongoDbInsert({Key? key}) : super(key: key);

  @override
  _MongoDbInsertState createState() => _MongoDbInsertState();
}

class _MongoDbInsertState extends State<MongoDbInsert> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Text(
              "Insert Data",
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 50,),
            TextField(
              decoration: InputDecoration(
                labelText: "First Name",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
