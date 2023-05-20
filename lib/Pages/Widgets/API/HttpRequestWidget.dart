import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../Helpers/Constants/Styling.dart';
import '../../Home/drawer_page.dart';

enum RequestMethod { get, post, put }

class HttpRequestWidget extends StatefulWidget {
  const HttpRequestWidget({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _HttpRequestWidgetState createState() => _HttpRequestWidgetState();
}

class _HttpRequestWidgetState extends State<HttpRequestWidget> {
  final TextEditingController _uriController = TextEditingController();
  final TextEditingController _parametersController = TextEditingController();
  final TextEditingController _headersController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  final TextEditingController _responseController = TextEditingController();

  RequestMethod _selectedRequestMethod = RequestMethod.get;

  @override
  void dispose() {
    _uriController.dispose();
    _parametersController.dispose();
    _headersController.dispose();
    _bodyController.dispose();
    _responseController.dispose();
    super.dispose();
  }

  Future<void> _sendRequest() async {
    final uri = Uri.parse(_uriController.text);
    final headers = _parseHeaders(_headersController.text);
    final body = _bodyController.text;

    http.Response response;
    switch (_selectedRequestMethod) {
      case RequestMethod.get:
        response = await http.get(uri, headers: headers);
        break;
      case RequestMethod.post:
        response = await http.post(uri, headers: headers, body: body);
        break;
      case RequestMethod.put:
        response = await http.put(uri, headers: headers, body: body);
        break;
    }

    setState(() {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Request Sent!"),
        ),
      );
      _responseController.text = response.body;
    });
  }

  Map<String, String> _parseHeaders(String headersText) {
    final headersMap = <String, String>{};
    final lines = headersText.split('\n');
    for (final line in lines) {
      final keyValuePairs = line.split(',');
      for (final pair in keyValuePairs) {
        final parts = pair.split(':');
        if (parts.length == 2) {
          final key = parts[0].trim();
          final value = parts[1].trim();
          headersMap[key] = value;
        }
      }
    }
    return headersMap;
  }

  Future<void> _saveData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final collection = FirebaseFirestore.instance
          .collection("UserWidgetData")
          .doc(user.uid.toString())
          .collection(currentWidget!.documentIdData);

      final data = {
        'uri': _uriController.text,
        'parameters': _parametersController.text,
        'headers': _headersController.text,
        'body': _bodyController.text,
        'response': _responseController.text,
      };

      await collection.doc('data').set(data);

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Sending Data to Cloud Firestore"),
        ),
      );
    }
  }

  Future<void> _loadData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final collection = FirebaseFirestore.instance
          .collection("UserWidgetData")
          .doc(user.uid.toString())
          .collection(currentWidget!.documentIdData);

      final doc = await collection.doc('data').get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          _uriController.text = data['uri'] ?? '';
          _parametersController.text = data['parameters'] ?? '';
          _headersController.text = data['headers'] ?? '';
          _bodyController.text = data['body'] ?? '';
          _responseController.text = data['response'] ?? '';
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Styling.purpleLight,
        title: const Text(
          'HTTP Request Widget',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<RequestMethod>(
              value: _selectedRequestMethod,
              items: RequestMethod.values.map((value) {
                return DropdownMenuItem<RequestMethod>(
                  value: value,
                  child: Text(
                    value.toString().split('.').last.toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedRequestMethod = value!;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Request Method',
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            SizedBox(
              height: 100,
              child: SingleChildScrollView(
                child: TextField(
                  controller: _uriController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Request URI',
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            SizedBox(
              height: 100,
              child: SingleChildScrollView(
                child: TextField(
                  controller: _parametersController,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Request Parameters (key=value)',
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            SizedBox(
              height: 100,
              child: SingleChildScrollView(
                child: TextField(
                  controller: _headersController,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Request Headers (key: value)',
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            SizedBox(
              height: 100,
              child: SingleChildScrollView(
                child: TextField(
                  controller: _bodyController,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Request Body',
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _sendRequest,
              style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                backgroundColor: MaterialStateProperty.all<Color>(
                  Styling.redDark.withOpacity(0.9),
                ),
                overlayColor: MaterialStateProperty.all<Color>(
                  Styling.orangeDark.withOpacity(0.9),
                ),
              ),
              child: const Text(
                'Send',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: SizedBox(
                height: 100,
                child: SingleChildScrollView(
                  child: TextField(
                    controller: _responseController,
                    maxLines: null,
                    readOnly: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Response',
                      labelStyle: TextStyle(color: Colors.white),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _saveData,
              style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                backgroundColor: MaterialStateProperty.all<Color>(
                  Styling.redDark.withOpacity(0.9),
                ),
                overlayColor: MaterialStateProperty.all<Color>(
                  Styling.orangeDark.withOpacity(0.9),
                ),
              ),
              child: const Text(
                'Save',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
