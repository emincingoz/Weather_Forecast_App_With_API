import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kartal/kartal.dart';
import 'package:http/http.dart' as http;
import '../widgets/daily_weather.dart';
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
  double? lat;
  double? lon;
  String weatherName = 'Clear';
  Position? position;
  String? iconName = '01d';

  Future<void> getDevicePosition() async {
    position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low);

    lat = position!.latitude;
    lon = position!.longitude;

    getLocationWeatherInformationFromOpenWeather();
  }

  Future<void> getLocationDataFromOpenWeather() async {
    //locationData = await http.get(Uri.parse(
    //  'https://www.metaweather.com/api/location/search/?query=$city'));

    locationData = await http.get(Uri.parse(
        'https://api.openweathermap.org/geo/1.0/direct?q=$city&limit=5&appid=a98f4eb51523a442b67e0887b3213729'));

    var locationDataParsed = jsonDecode(locationData.body);
    lat = locationDataParsed[0]['lat'];
    lon = locationDataParsed[0]['lon'];
  }

  Future<void> getLocationWeatherInformationFromOpenWeather() async {
    //var response = await http
    //  .get(Uri.parse('https://www.metaweather.com/api/location/$woeid/'));

    var response = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&units=metric&appid=a98f4eb51523a442b67e0887b3213729'));

    var parsedData = jsonDecode(utf8.decode(response.bodyBytes));

    setState(() {
      city = parsedData['name'];
      temperature = (parsedData['main']['temp']).round();
      weatherName = parsedData['weather'][0]['main'];
      iconName = parsedData['weather'][0]['icon'];
    });
  }

  @override
  void initState() {
    _determinePosition();
    //getDevicePosition();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.cover,
          image: AssetImage("assets/images/$weatherName.jpg"),
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
                    Container(
                      height: context.highValue + context.mediumValue,
                      width: context.highValue + context.mediumValue,
                      child: Image.network(
                          'https://openweathermap.org/img/wn/$iconName@4x.png'),
                    ),
                    Text(
                      "$temperature° C",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: context.highValue,
                        shadows: const [
                          Shadow(
                            color: Colors.black38,
                            blurRadius: 10,
                            offset: Offset(-3, 3),
                          )
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "$city",
                          style: TextStyle(
                            fontSize: context.mediumValue,
                            shadows: const [
                              Shadow(
                                color: Colors.black38,
                                blurRadius: 10,
                                offset: Offset(-3, 3),
                              )
                            ],
                          ),
                        ),
                        IconButton(
                            onPressed: () async {
                              city = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (newcontext) => SearchPage()));
                              getDataFromAPIOpenWeather();
                              setState(() {});
                            },
                            icon: Icon(Icons.search))
                      ],
                    ),
                    SizedBox(
                      height: context.highValue,
                    ),
                    Container(
                      height: 120,

                      ///
                      /// Alanı dinamik olarak kullanmak için MediaQuery ile cihazın alanı çekilebilir.
                      /// Yada FractionallySizedBox kullanarak widthFactor verilebilir.
                      ///
                      //width: MediaQuery.of(context).size.width * 0.90,
                      child: FractionallySizedBox(
                        widthFactor: 0.9,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: 5,
                          itemBuilder: (context, index) {
                            return DailyWeather(
                              date: 'Pazartesi', //dates[index],
                              temp: '20', //temps[index],
                              image: 'c', //images[index],
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                )
              : CircularProgressIndicator(),
        ),
      ),
    );
  }

  Future<void> getDataFromAPIOpenWeather() async {
    await getLocationDataFromOpenWeather();
    await getLocationWeatherInformationFromOpenWeather();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await getDevicePosition();
  }
}
