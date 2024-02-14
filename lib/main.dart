import 'dart:convert';

import 'package:flutter/material.dart';
import 'SecondRoute.dart' show SecondRoute;
import 'package:http/http.dart' as http;

void main() {
  runApp(MaterialApp(
    title: 'Flutter Navigation',
    theme: ThemeData(
      // This is the theme of your application.
      primarySwatch: Colors.green,
    ),
    home: FirstRoute(),
  ));
}

class FirstRoute extends StatefulWidget {
  @override
  State<FirstRoute> createState() => _FirstRouteState();
}

class _FirstRouteState extends State<FirstRoute> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  var token = "";

  Future<String?> sendPostRequest() async {
    var apiUrl = Uri.parse("http://192.168.1.108:8000/token");
    Map<String, String> formData = {
      'username': usernameController.text,
      'password': passwordController.text,
    };
    var response = await http.post(
      apiUrl,
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: formData,
    );

    if (response.statusCode == 200) {
      print("Post sent successfully");

      final responseFinal = json.decode(response.body);
      setState(() {
        token = responseFinal["access_token"];
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => SecondRoute(access_token: token)),
      );

      return response.body;
    } else {
      print(response.statusCode);
      print(response);
      print("Failed to send post");
    }
  }

  void fetchData() async {
    String? data = await sendPostRequest();
    if (data != null) {
      print('Received data: $data');
    } else {
      print('No data received');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        title: Text(''),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Login',
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 35, color: Colors.white),
          ),
          SizedBox(
            height: 30,
          ),
          Form(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextFormField(
                    controller: usernameController,
                    decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        label: const Text('Username'),
                        icon: Icon(
                          Icons.verified_user,
                          color: Colors.white,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.black),
                          borderRadius: BorderRadius.circular(10),
                        )),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: passwordController,
                    decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        label: const Text('Password'),
                        icon: Icon(
                          Icons.lock,
                          color: Colors.white,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.black),
                          borderRadius: BorderRadius.circular(10),
                        )),
                  )
                ],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: sendPostRequest,
            child: Text('Login'),
          ),
        ],
      ),
    );
  }
}
