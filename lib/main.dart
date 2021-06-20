import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:weather_app/background.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:weather_app/forecast.dart';

const forecastTextStyle = TextStyle(
  fontSize: 16.0,
  decoration: TextDecoration.none,
  fontFamily: 'Cabin',
  color: Colors.white,
  fontWeight: FontWeight.w700,
);

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // ignore: deprecated_member_use
  List<Forecast> forecastData = List<Forecast>(7);
  // ignore: deprecated_member_use
  List<Widget> forecastWidgets = List<Widget>(7);
  Position position;
  double lat, lon;
  String city, weather, weatherBack;
  double wind;
  var temp;
  int humidity, visibility;
  double k = 0;
  bool spinnerValue = true;

  void getPosition() async {
    position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low);
    print(position.latitude);
    print(position.longitude);
    lat = position.latitude;
    lon = position.longitude;
  }

  void getWeather() async {
    var url =
        'http://api.openweathermap.org/data/2.5/weather?q=surat&&units=metric&appid=2d2877f4bf18057e3651590098a4807b';
    var encoded = Uri.parse(url);
    Response response = await get(encoded);
    var urlForecast =
        'https://api.openweathermap.org/data/2.5/forecast?q=surat&&units=metric&cnt=7&appid=2d2877f4bf18057e3651590098a4807b';
    var encodedForecast = Uri.parse(urlForecast);
    Response responseForecast = await get(encodedForecast);
    var forecast = responseForecast.body;

    var data = response.body;
    weather = jsonDecode(data)['weather'][0]['description'].toString();
    weatherBack = jsonDecode(data)['weather'][0]['main'].toString();
    city = jsonDecode(data)['name'].toString();
    temp = jsonDecode(data)['main']['temp'];
    humidity = jsonDecode(data)['main']['humidity'];

    visibility = jsonDecode(data)['visibility'];
    k = visibility / 1000;

    wind = jsonDecode(data)['wind']['speed'] as double;
    setState(() {
      spinnerValue = false;
    });

    // DateTime dateTime = DateTime.now();
    //
    // print(TimeOfDay.now().hour);
    print(weatherBack);
    print(city);
    print(temp);

    for (int i = 0; i < 7; i++) {
      String temp = jsonDecode(forecast)['list'][i]['dt_txt'];
      String date = temp.split(" ")[0];
      String time = temp.split(" ")[1];
      String desc =
          jsonDecode(forecast)['list'][i]['weather'][0]['description'];
      double forecastTemp = jsonDecode(forecast)['list'][i]['main']['temp'];
      int forecastHumidity =
          jsonDecode(forecast)['list'][i]['main']['humidity'];
      forecastData[i] =
          Forecast(date, time, desc, forecastTemp, forecastHumidity);
    }

    forecastWeather();
  }

  @override
  void initState() {
    super.initState();
    getPosition();
    getWeather();
  }

  List forecastWeather() {
    for (int i = 0; i < 7; i++) {
      forecastWidgets[i] = Container(
        margin: EdgeInsets.only(right: 15.0),
        decoration: BoxDecoration(
          color: Color(0x60FFFFFF),
          borderRadius: BorderRadius.circular(20.0),
        ),
        height: 80,
        width: 280,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  forecastData[i].date != null ? forecastData[i].date : '--',
                  style: forecastTextStyle,
                ),
                Text(
                  forecastData[i].time != null ? forecastData[i].time : '--',
                  style: forecastTextStyle,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon(
                //   Icons.cloud,
                //   color: Colors.white,
                //   size: 30.0,
                // ),
                // SizedBox(
                //   width: 8.0,
                // ),
                Text(
                  forecastData[i].weatherDescription != null
                      ? forecastData[i].weatherDescription
                      : '--',
                  style: forecastTextStyle.copyWith(fontSize: 25.0),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  'Humidity: ' +
                      (forecastData[i].humidity.toString() != null
                          ? forecastData[i].humidity.toString()
                          : '--'),
                  style: forecastTextStyle,
                ),
                Text(
                  'Temperature: ' +
                      (forecastData[i].temperature.toString() != null
                          ? forecastData[i].temperature.toString()
                          : '--'),
                  style: forecastTextStyle,
                ),
              ],
            )
          ],
        ),
      );
    }

    return forecastWidgets;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Weather app',
      home: ModalProgressHUD(
        inAsyncCall: spinnerValue,
        child: SafeArea(
          child: Stack(
            children: [
              Background(
                  // weather: weatherBack,
                  ),
              Stack(
                children: [
                  Positioned(
                    top: 35.0,
                    left: 25.0,
                    child: Text(
                      city != null ? city : 'city',
                      style: TextStyle(
                        fontSize: 30.0,
                        fontFamily: 'Montserrat',
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 80.0,
                    left: 25.0,
                    child: Text(
                      temp != null ? temp.toStringAsFixed(0) + '°' : '0 °',
                      // temp.toStringAsFixed(0),
                      style: TextStyle(
                          fontFamily: 'Arvo',
                          fontSize: 140.0,
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                          // fontStyle: FontStyle.italic,
                          decoration: TextDecoration.none),
                    ),
                  ),
                  RotatedBox(
                    quarterTurns: 1,
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        margin: EdgeInsets.only(left: 45.0, top: 25.0),
                        child: Text(
                          weather != null ? weather.toUpperCase() : 'Weather',
                          // weather.toUpperCase(),
                          style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 25.0,
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              // fontStyle: FontStyle.italic,
                              decoration: TextDecoration.none),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: 140,
                      margin: EdgeInsets.only(bottom: 200.0),
                      child: ListView(
                        padding: EdgeInsets.all(10.0),
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        children: forecastWeather(),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      margin: EdgeInsets.only(
                          bottom: 30.0, left: 10.0, right: 10.0),
                      height: 90.0,
                      decoration: BoxDecoration(
                        color: Color(0x40FFFFFF),
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                humidity.toString() + '%',
                                // humidity.toString() + '%',
                                style: TextStyle(
                                  fontSize: 18.0,
                                  decoration: TextDecoration.none,
                                  fontFamily: 'Cabin',
                                  color: Colors.white,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              SizedBox(
                                height: 6.0,
                              ),
                              Text(
                                'Humidity',
                                style: TextStyle(
                                  fontSize: 14.0,
                                  decoration: TextDecoration.none,
                                  fontFamily: 'Cabin',
                                  color: Colors.white,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                          RotatedBox(
                            quarterTurns: 1,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15.0),
                              child: Divider(
                                color: Color(0xA0FFFFFF),
                                thickness: 2.0,
                              ),
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                visibility == null
                                    ? '0 Km'
                                    : visibility.toStringAsFixed(0) + ' Km',
                                style: TextStyle(
                                  fontSize: 18.0,
                                  decoration: TextDecoration.none,
                                  fontFamily: 'cabin',
                                  color: Colors.white,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              SizedBox(
                                height: 6.0,
                              ),
                              Text(
                                'Visibility',
                                style: TextStyle(
                                  fontSize: 14.0,
                                  decoration: TextDecoration.none,
                                  fontFamily: 'Cabin',
                                  color: Colors.white,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                          RotatedBox(
                            quarterTurns: 1,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15.0),
                              child: Divider(
                                color: Color(0xA0FFFFFF),
                                thickness: 2.0,
                              ),
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                wind == null
                                    ? '0 m/s'
                                    : wind.toStringAsFixed(2) + ' m/s',
                                style: TextStyle(
                                  fontSize: 18.0,
                                  decoration: TextDecoration.none,
                                  fontFamily: 'Cabin',
                                  color: Colors.white,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              SizedBox(
                                height: 6.0,
                              ),
                              Text(
                                'Wind Speed',
                                style: TextStyle(
                                  fontSize: 14.0,
                                  decoration: TextDecoration.none,
                                  fontFamily: 'Cabin',
                                  color: Colors.white,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
