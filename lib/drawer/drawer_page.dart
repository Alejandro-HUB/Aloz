import 'package:flutter/material.dart';
import 'package:projectcrm/constants.dart';
import 'package:projectcrm/responsive_layout.dart';

class DrawerPage extends StatefulWidget {
  @override
  _DrawerPageState createState() => _DrawerPageState();
}

class _DrawerPageState extends State<DrawerPage>{
  @override 
  Widget build(BuildContext context){
    return Drawer(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(Constants.kPadding),
          child: Column(
            children: [
              ListTile(
                title: Text(
                  "Admin Menu",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                trailing: ResponsiveLayout.isComputer(context) 
                    ? null 
                    : IconButton(
                      onPressed: (){
                        Navigator.pop(context);
                      }, 
                      icon: Icon(
                        Icons.close, 
                        color: Colors.white,
                      ),
                    ),
              ),
            ],
          )
        ),
      ),
    );
  }
}