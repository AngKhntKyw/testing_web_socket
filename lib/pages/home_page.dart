import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:test_socket/pages/chat_page.dart';

class HomePage extends StatefulWidget {
  final String token;
  final String currentUser;
  const HomePage({super.key, required this.token, required this.currentUser});

  @override
  State<HomePage> createState() => _HomePageState();
}

Future<List<dynamic>?> getUsers() async {
  final response = await http.get(
    Uri.parse("http://192.168.0.111:8080/api/users"),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
  );
  log("Status Code Users :  ${response.statusCode}");
  if (response.statusCode == 200) {
    log(response.body);
    final List<dynamic> responseBody = jsonDecode(response.body);
    log(responseBody.toString());
    return responseBody;
  } else {
    return null;
  }
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Home")),
      body: FutureBuilder(
        future: getUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          } else {
            List<dynamic> dy = snapshot.data!;
            return ListView.builder(
              itemCount: dy.length,
              itemBuilder: (context, index) {
                return ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatPage(
                          name: dy[index]['username'],
                          token: widget.token,
                          currentUser: widget.currentUser,
                        ),
                      ),
                    );
                  },
                  leading: CircleAvatar(child: Text((index + 1).toString())),
                  title: Text(dy[index]['username']),
                );
              },
            );
          }
        },
      ),
    );
  }
}
