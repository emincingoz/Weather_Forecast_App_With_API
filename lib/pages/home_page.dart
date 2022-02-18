import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:kartal/kartal.dart';
import 'package:http/http.dart' as http;
import 'search_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String city = "Ankara";
  int? temperature;
  var locationData;
  var woeid;

  Future<void> getLocationData() async {
    locationData = await http.get(Uri.parse(
        'https://www.metaweather.com/api/location/search/?query=Ankara'));

    var locationDataParsed = jsonDecode(locationData.body);
    woeid = locationDataParsed[0]["woeid"];
  }

  Future<void> getLocationTemperature() async {
    var response = await http
        .get(Uri.parse('https://www.metaweather.com/api/location/$woeid/'));
    var temperatureDataParsed = jsonDecode(response.body);

    setState(() {
      temperature = (temperatureDataParsed['consolidated_weather'][0]
              ['the_temp'])
          .round();
    });
  }

  @override
  void initState() {
    getDataFromAPI();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.cover,
          image: AssetImage("assets/images/c.jpg"),
        ),
      ),
      child: Scaffold(
        //
        // scaffold image üzerine gelip resmi bozar.
        backgroundColor: Colors.transparent,
        body: Center(
          child: temperature != null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "$temperature° C",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: context.highValue,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "$city",
                          style: TextStyle(fontSize: context.mediumValue),
                        ),
                        IconButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (newcontext) => SearchPage()));
                            },
                            icon: Icon(Icons.search))
                      ],
                    )
                  ],
                )
              : CircularProgressIndicator(),
        ),
      ),
    );
  }

  Future<void> getDataFromAPI() async {
    await getLocationData();
    await getLocationTemperature();
  }
}
