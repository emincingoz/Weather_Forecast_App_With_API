import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:kartal/kartal.dart';
import 'package:http/http.dart' as http;

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String? choosenCity;
  final textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.cover,
          image: AssetImage('assets/images/search.jpg'),
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: Center(
            child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: TextField(
                controller: textController,
                /*onChanged: (value) {
                  choosenCity = value;
                  print(choosenCity);
                },*/
                decoration: const InputDecoration(hintText: "Şehir Seçiniz"),
                style: TextStyle(fontSize: context.mediumValue),
                textAlign: TextAlign.center,
              ),
            ),
            TextButton(
                onPressed: () async {
                  var response = await http.get(Uri.parse(
                      'https://api.openweathermap.org/geo/1.0/direct?q=${textController.text}&limit=5&appid=a98f4eb51523a442b67e0887b3213729'));
                  jsonDecode(response.body).isEmpty
                      ? _showDialog()
                      : Navigator.pop(context, textController.text);
                },
                child: const Text(
                  "Şehri Seç",
                  style: TextStyle(color: Colors.white),
                ))
          ],
        )),
      ),
    );
  }

  void _showDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: const Text("HATA"),
          content: const Text("Geçersiz bir şehir girdiniz!"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            TextButton(
              child: const Text("Kapat"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
