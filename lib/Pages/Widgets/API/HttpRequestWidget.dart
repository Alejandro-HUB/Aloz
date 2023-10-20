// ignore_for_file: depend_on_referenced_packages, library_private_types_in_public_api, use_build_context_synchronously, deprecated_member_use

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../Assets/buttons.dart';
import '../../../Helpers/Constants/Styling.dart';
import '../../Home/HomePage.dart';

enum RequestMethod { get, post, put }

enum AuthorizationMethod {
  noAuth,
  apiKey,
  bearerToken,
  jwtBearer,
  basicAuth,
  digestAuth,
  oAuth1,
  oAuth2,
}

class HttpRequestWidget extends StatefulWidget {
  const HttpRequestWidget({Key? key}) : super(key: key);

  @override
  _HttpRequestWidgetState createState() => _HttpRequestWidgetState();
}

//Tabs
// ignore: constant_identifier_names
enum HttpRequestWidgetTab { Parameters, Headers, Authorization, Body }

HttpRequestWidgetTab _currentTab = HttpRequestWidgetTab.Parameters;

class _HttpRequestWidgetState extends State<HttpRequestWidget> {
  //Label Style
  final _labelStyle = const TextStyle(
      color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20);

  //Request Controllers
  final TextEditingController _uriController = TextEditingController();
  final TextEditingController _parametersController = TextEditingController();
  final TextEditingController _headersController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  final TextEditingController _responseController = TextEditingController();

  //Auth Controllers
  //Api Key, BeaerToken, jwtBeaer, userName, oAuth1, oAuth2
  final TextEditingController _authController = TextEditingController();

  //More Auth Controllers
  final TextEditingController _passwordController = TextEditingController();

  //Response Status Code
  String _responseStatusCode = '';

  RequestMethod _selectedRequestMethod = RequestMethod.get;
  AuthorizationMethod _selectedAuthorizationMethod = AuthorizationMethod.noAuth;

  @override
  void dispose() {
    _uriController.dispose();
    _parametersController.dispose();
    _headersController.dispose();
    _bodyController.dispose();
    _responseController.dispose();
    _authController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _sendRequest() async {
    try {
      final uri = Uri.parse(_uriController.text);
      final parameters = _parseParameters(_parametersController.text);
      var headers = _parseHeaders(_headersController.text);
      final body = _bodyController.text;

      // Add custom headers for CORS
      headers['Access-Control-Allow-Credentials'] = 'true';
      headers['Access-Control-Allow-Origin'] = '*';
      headers['Access-Control-Allow-Methods'] =
          'GET,OPTIONS,PATCH,DELETE,POST,PUT';
      headers['Access-Control-Allow-Headers'] =
          'X-CSRF-Token, X-Requested-With, Accept, Accept-Version, Content-Length, Content-MD5, Content-Type, Date, X-Api-Version';

      //Add Authorization Headers
      headers.addAll(addAuthorizationHeaders(headers));

      // Append Query Parameters
      final uriWithParameters = uri.replace(queryParameters: parameters);

      http.Response response;
      switch (_selectedRequestMethod) {
        case RequestMethod.get:
          response = await http.get(uriWithParameters, headers: headers);
          break;
        case RequestMethod.post:
          response =
              await http.post(uriWithParameters, headers: headers, body: body);
          break;
        case RequestMethod.put:
          response =
              await http.put(uriWithParameters, headers: headers, body: body);
          break;
      }

      setState(() {
        _responseStatusCode = ", Status Code: ${response.statusCode}";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Request Sent! $_responseStatusCode"),
          ),
        );
        _responseController.text = formatJson(response.body);
      });
    } catch (e) {
      // Handle the exception here
      print('Error occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error occurred: $e"),
        ),
      );
    }
  }

  Map<String, String> _parseParameters(String parametersText) {
    final parametersMap = <String, String>{};
    final keyValuePairs = parametersText.split('&');
    for (final pair in keyValuePairs) {
      final parts = pair.split('=');
      if (parts.length == 2) {
        final key = parts[0].trim();
        final value = parts[1].trim();
        parametersMap[key] = value;
      }
    }
    return parametersMap;
  }

  Map<String, String> _parseHeaders(String headersText) {
    final headersMap = <String, String>{};
    final headers = headersText.split(',');
    for (final header in headers) {
      final parts = header.split(':');
      if (parts.length == 2) {
        final key = parts[0].trim();
        final value = parts[1].trim();
        headersMap[key] = value;
      }
    }
    return headersMap;
  }

  String formatJson(String jsonString) {
    dynamic parsedJson = jsonDecode(jsonString);
    JsonEncoder encoder = const JsonEncoder.withIndent(
        '  '); // Specify the indentation level (two spaces in this example)
    String formattedString = encoder.convert(parsedJson);
    return formattedString;
  }

  Map<String, String> addAuthorizationHeaders(Map<String, String> headers) {
    switch (_selectedAuthorizationMethod) {
      case AuthorizationMethod.apiKey:
        headers['Authorization'] = 'Api-Key ${_authController.text}';
        break;
      case AuthorizationMethod.bearerToken:
        headers['Authorization'] = 'Bearer ${_authController.text}';
        break;
      case AuthorizationMethod.jwtBearer:
        headers['Authorization'] = 'Bearer ${_authController.text}';
        break;
      case AuthorizationMethod.basicAuth:
        final username = _authController.text;
        final password = _passwordController.text;
        final authString = base64.encode(utf8.encode('$username:$password'));
        headers['Authorization'] = 'Basic $authString';
        break;
      case AuthorizationMethod.digestAuth:
        final username = _authController.text;
        final password = _passwordController.text;
        final authString = base64.encode(utf8.encode('$username:$password'));
        headers['Authorization'] = 'Digest $authString';
        break;
      case AuthorizationMethod.oAuth1:
        headers['Authorization'] = 'OAuth ${_authController.text}';
        break;
      case AuthorizationMethod.oAuth2:
        headers['Authorization'] = 'Bearer ${_authController.text}';
        break;
      case AuthorizationMethod.noAuth:
        // No authorization headers needed
        break;
    }
    return headers;
  }

  Future<void> _saveData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final collection = FirebaseFirestore.instance
          .collection("UserWidgetData")
          .doc(user.uid.toString())
          .collection(currentWidget!.documentIdData);

      final data = {
        'requestMethod': _selectedRequestMethod.toString(),
        'uri': _uriController.text,
        'parameters': _parametersController.text,
        'headers': _headersController.text,
        'authorizationMethod': _selectedAuthorizationMethod.toString(),
        'auth': _authController.text,
        'authPassword': _passwordController.text,
        'body': _bodyController.text,
        'response': _responseController.text,
      };

      await collection.doc('data').set(data);

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
          _selectedRequestMethod = _parseRequestMethod(data['requestMethod']);
          _uriController.text = data['uri'] ?? '';
          _parametersController.text = data['parameters'] ?? '';
          _headersController.text = data['headers'] ?? '';
          _selectedAuthorizationMethod =
              _parseAuthorizationMethod(data['authorizationMethod']);
          _authController.text = data['auth'] ?? '';
          _passwordController.text = data['authPassword'] ?? '';
          _bodyController.text = data['body'] ?? '';
          _responseController.text = data['response'] ?? '';
        });
      }
    }
  }

  RequestMethod _parseRequestMethod(String? value) {
    switch (value) {
      case 'RequestMethod.get':
        return RequestMethod.get;
      case 'RequestMethod.post':
        return RequestMethod.post;
      case 'RequestMethod.put':
        return RequestMethod.put;
      default:
        return RequestMethod.get;
    }
  }

  AuthorizationMethod _parseAuthorizationMethod(String? value) {
    switch (value) {
      case 'AuthorizationMethod.noAuth':
        return AuthorizationMethod.noAuth;
      case 'AuthorizationMethod.apiKey':
        return AuthorizationMethod.apiKey;
      case 'AuthorizationMethod.bearerToken':
        return AuthorizationMethod.bearerToken;
      case 'AuthorizationMethod.jwtBearer':
        return AuthorizationMethod.jwtBearer;
      case 'AuthorizationMethod.basicAuth':
        return AuthorizationMethod.basicAuth;
      case 'AuthorizationMethod.digestAuth':
        return AuthorizationMethod.digestAuth;
      case 'AuthorizationMethod.oAuth1':
        return AuthorizationMethod.oAuth1;
      case 'AuthorizationMethod.oAuth2':
        return AuthorizationMethod.oAuth2;
      default:
        return AuthorizationMethod.noAuth;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  List<Widget> _buildAuthorizationInputs() {
    switch (_selectedAuthorizationMethod) {
      case AuthorizationMethod.apiKey:
        return [
          const SizedBox(height: 8.0),
          TextField(
            controller: _authController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'API Key',
              labelStyle: _labelStyle,
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
            ),
          ),
        ];
      case AuthorizationMethod.bearerToken:
        return [
          const SizedBox(height: 8.0),
          TextField(
            controller: _authController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Bearer Token',
              labelStyle: _labelStyle,
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
            ),
          ),
        ];
      case AuthorizationMethod.jwtBearer:
        return [
          const SizedBox(height: 8.0),
          TextField(
            controller: _authController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'JWT Bearer',
              labelStyle: _labelStyle,
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
            ),
          ),
        ];
      case AuthorizationMethod.basicAuth:
        return [
          const SizedBox(height: 8.0),
          TextField(
            controller: _authController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Username',
              labelStyle: _labelStyle,
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          TextField(
            controller: _passwordController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Password',
              labelStyle: _labelStyle,
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
            ),
          ),
        ];
      case AuthorizationMethod.digestAuth:
        return [
          const SizedBox(height: 8.0),
          TextField(
            controller: _authController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Username',
              labelStyle: _labelStyle,
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          TextField(
            controller: _passwordController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Password',
              labelStyle: _labelStyle,
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
            ),
          ),
        ];
      case AuthorizationMethod.oAuth1:
        return [
          const SizedBox(height: 8.0),
          TextField(
            controller: _authController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'OAuth 1.0',
              labelStyle: _labelStyle,
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
            ),
          ),
        ];
      case AuthorizationMethod.oAuth2:
        return [
          const SizedBox(height: 8.0),
          TextField(
            controller: _authController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'OAuth 2.0',
              labelStyle: _labelStyle,
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
            ),
          ),
        ];
      case AuthorizationMethod.noAuth:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Styling.purpleLight,
        title: Text(
          currentWidget!.title,
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: _saveData,
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: ListView(
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
              decoration: InputDecoration(
                labelText: 'Request Method',
                labelStyle: _labelStyle,
                enabledBorder: const UnderlineInputBorder(
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
                  decoration: InputDecoration(
                    labelText: 'Request URI',
                    labelStyle: _labelStyle,
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
            //Tabs
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: MyElevatedButton(
                      gradient: _currentTab == HttpRequestWidgetTab.Parameters
                          ? const LinearGradient(
                              colors: [Styling.redDark, Styling.orangeDark])
                          : const LinearGradient(colors: [
                              Styling.purpleLight,
                              Styling.purpleLight
                            ]),
                      label: "Parameters",
                      width: 150,
                      icon: const Icon(Icons.question_mark),
                      onPressed: () {
                        setState(() {
                          _currentTab = HttpRequestWidgetTab.Parameters;
                        });
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: const Text('Parameters'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: MyElevatedButton(
                      gradient: _currentTab == HttpRequestWidgetTab.Headers
                          ? const LinearGradient(
                              colors: [Styling.redDark, Styling.orangeDark])
                          : const LinearGradient(colors: [
                              Styling.purpleLight,
                              Styling.purpleLight
                            ]),
                      label: "Headers",
                      width: 150,
                      icon: const Icon(Icons.edit_document),
                      onPressed: () {
                        setState(() {
                          _currentTab = HttpRequestWidgetTab.Headers;
                        });
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: const Text('Headers'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: MyElevatedButton(
                      gradient:
                          _currentTab == HttpRequestWidgetTab.Authorization
                              ? const LinearGradient(
                                  colors: [Styling.redDark, Styling.orangeDark])
                              : const LinearGradient(colors: [
                                  Styling.purpleLight,
                                  Styling.purpleLight
                                ]),
                      label: "Authorization",
                      width: 150,
                      icon: const Icon(Icons.lock),
                      onPressed: () {
                        setState(() {
                          _currentTab = HttpRequestWidgetTab.Authorization;
                        });
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: const Text('Authorization'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: MyElevatedButton(
                      gradient: _currentTab == HttpRequestWidgetTab.Body
                          ? const LinearGradient(
                              colors: [Styling.redDark, Styling.orangeDark])
                          : const LinearGradient(colors: [
                              Styling.purpleLight,
                              Styling.purpleLight
                            ]),
                      label: "Body",
                      width: 150,
                      icon: const Icon(Icons.content_copy),
                      onPressed: () {
                        setState(() {
                          _currentTab = HttpRequestWidgetTab.Body;
                        });
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: const Text('Body'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            if (_currentTab == HttpRequestWidgetTab.Parameters)
              SizedBox(
                height: 100,
                child: SingleChildScrollView(
                  child: TextField(
                    controller: _parametersController,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Request Parameters',
                      labelStyle: _labelStyle,
                      hintText: 'key1=value1&key2=value2...',
                      hintStyle: const TextStyle(color: Colors.white),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 16.0),
            if (_currentTab == HttpRequestWidgetTab.Headers)
              SizedBox(
                height: 100,
                child: SingleChildScrollView(
                  child: TextField(
                    controller: _headersController,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Request Headers',
                      labelStyle: _labelStyle,
                      hintText: 'key1:value1,key2:value2...',
                      hintStyle: const TextStyle(color: Colors.white),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            if (_currentTab == HttpRequestWidgetTab.Body)
              Padding(
                padding: const EdgeInsets.all(0),
                child: SizedBox(
                  height: 100,
                  child: SingleChildScrollView(
                    child: TextField(
                      controller: _bodyController,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Request Body',
                        labelStyle: _labelStyle,
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 16.0),
            if (_currentTab == HttpRequestWidgetTab.Authorization)
              DropdownButtonFormField<AuthorizationMethod>(
                value: _selectedAuthorizationMethod,
                items: AuthorizationMethod.values.map((value) {
                  return DropdownMenuItem<AuthorizationMethod>(
                    value: value,
                    child: Text(
                      value.toString().split('.').last.toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedAuthorizationMethod = value!;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Authorization Method',
                  labelStyle: _labelStyle,
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
              ),
            const SizedBox(height: 16.0),
            if (_currentTab == HttpRequestWidgetTab.Authorization)
              ..._buildAuthorizationInputs(),
            const SizedBox(height: 16.0),
            MyElevatedButton(
              label: "Send",
              width: double.infinity,
              icon: const Icon(Icons.send),
              onPressed: _sendRequest,
              borderRadius: BorderRadius.circular(10),
              child: const Text('Send'),
            ),
            const SizedBox(height: 16.0),
            SingleChildScrollView(
              child: SizedBox(
                height: 400,
                child: TextField(
                  controller: _responseController,
                  maxLines: null,
                  readOnly: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Response$_responseStatusCode',
                    labelStyle: _labelStyle,
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }
}
