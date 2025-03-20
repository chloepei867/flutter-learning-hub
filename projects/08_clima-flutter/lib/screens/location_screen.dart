import 'package:clima/screens/city_screen.dart';
import 'package:flutter/material.dart';
import 'package:clima/utilities/constants.dart';
import 'package:clima/services/weather.dart';

class LocationScreen extends StatefulWidget {

  LocationScreen({this.locationWeather});
  final locationWeather;

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  WeatherModel weatherModel = WeatherModel();
  int? temperature;
  String? weatherIcon;
  String? cityName;
  String? weatherMessage;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    updateUI(widget.locationWeather);
  }

  void updateUI(dynamic weatherData) {
    if (weatherData == null) {
      temperature = 0;
      weatherIcon = 'Error';
      weatherMessage = 'Unable to get weather data';
      cityName = '';
      return;
    }
    setState(() {
      double temp = weatherData['main']['temp'];
      temperature = temp.toInt();
      var condition = weatherData['weather'][0]['id'];
      weatherIcon = weatherModel.getWeatherIcon(condition);
      weatherMessage = weatherModel.getMessage(temperature!);
      cityName = weatherData['name'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('images/location_background.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.white.withValues(alpha: 0.8,red: 255,green: 255,blue: 255),
                BlendMode.dstATop,
            ),
          ),
        ),
        constraints: BoxConstraints.expand(),
        child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                        onPressed: () async {
                          var weatherData = await weatherModel.getLocationWeather();
                          updateUI(weatherData);
                        },
                        child: Icon(
                          Icons.near_me,
                          size: 50.0,
                        ),
                    ),
                    TextButton(
                      onPressed: () async {
                        var typedName = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) =>CityScreen()),
                        );
                        if (typedName != null) {
                          var weatherData = await weatherModel.getCityWeather(typedName);
                          updateUI(weatherData);
                        }
                      },
                      child: Icon(
                        Icons.location_city,
                        size: 50.0,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(left: 15.0),
                  child: Row(
                    children: [
                      //display the temperature
                      Text(
                        '$temperature°',
                        style: kTempTextStyle,
                      ),
                      Text(
                        weatherIcon!,
                        style: kConditionTextStyle,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 15.0),
                  child: Text(
                    "$weatherMessage in $cityName!",
                    textAlign: TextAlign.right,
                    style: kMessageTextStyle,
                  ),
                ),
              ],
            ),
        ),
      ),
    );
  }
}
