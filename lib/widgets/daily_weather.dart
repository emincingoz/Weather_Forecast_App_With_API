import 'package:flutter/material.dart';
import 'package:kartal/kartal.dart';

class DailyWeather extends StatelessWidget {
  final String image;
  final String temp;
  final String date;

  const DailyWeather(
      {Key? key, required this.image, required this.temp, required this.date})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Colors.transparent,
      child: Container(
        height: 120,
        width: 100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              'https://openweathermap.org/img/wn/10d@4x.png',
              height: 50,
              width: 50,
            ),
            Text("$temp° C"),
            Text("$date"),
          ],
        ),
      ),
    );
  }
}
