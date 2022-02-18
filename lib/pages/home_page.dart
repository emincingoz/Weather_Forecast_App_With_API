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
  String city = "Istanbul";
  int? temperature;
  var locationData;
  var lat;
  var lon;

  Future<void> getLocationData() async {
    //locationData = await http.get(Uri.parse(
    //  'https://www.metaweather.com/api/location/search/?query=$city'));

    locationData = await http.get(Uri.parse(
        'https://api.openweathermap.org/geo/1.0/direct?q=$city&limit=5&appid=a98f4eb51523a442b67e0887b3213729'));

    var locationDataParsed = jsonDecode(locationData.body);
    lat = locationDataParsed[0]['lat'];
    lon = locationDataParsed[0]['lon'];
  }

  Future<void> getLocationTemperature() async {
    //var response = await http
    //  .get(Uri.parse('https://www.metaweather.com/api/location/$woeid/'));

    var response = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&units=metric&appid=a98f4eb51523a442b67e0887b3213729'));

    var temperatureDataParsed = jsonDecode(response.body);

    setState(() {
      temperature = (temperatureDataParsed['main']['temp']).round();
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
                            onPressed: () async {
                              city = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (newcontext) => SearchPage()));
                              getDataFromAPI();
                              setState(() {});
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
