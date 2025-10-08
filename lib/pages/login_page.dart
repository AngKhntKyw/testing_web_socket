import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:test_socket/pages/home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final passwordController = TextEditingController();

  void login() async {
    if (formKey.currentState!.validate()) {
      log("Login..........");

      final response = await http.post(
        Uri.parse("http://192.168.0.111:8080/api/auth/login"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'username': nameController.text,
          'password': passwordController.text,
        }),
      );
      log("Status Code :  ${response.statusCode}");
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        if (!mounted) return;

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => HomePage(
              token: responseBody['token'],
              currentUser: responseBody['username'],
            ),
          ),
        );
      } else {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Form(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Login"),
              const SizedBox(height: 30),
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: "name"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "enter name";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 30),
              TextFormField(
                controller: passwordController,
                decoration: InputDecoration(labelText: "password"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "enter password";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton(onPressed: login, child: Text("login")),
            ],
          ),
        ),
      ),
    );
  }
}
