import 'package:client_weather_app/services/weather_service.dart';
import 'package:client_weather_app/models/weather_model.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lottie/lottie.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  // api key
  final _weatherService = WeatherService(dotenv.env['API_KEY'] ?? '');
  Weather? _weather;

  // fetch weather
  _fetchWeather() async {
    // get the current position
    var position = (await _weatherService.getCurrentCityandPosition()).position;

    // get weather for the position
    try {
      final weather = await _weatherService.getWeather(
          position.latitude, position.longitude);
      setState(() {
        _weather = weather;
      });
    }
    // errors DEBUG TEMP
    catch (e) {
      debugPrint(e.toString());
    }
  }

  // weather animations
  String getWeatherAnimation(String? mainCondition) {
    if (mainCondition == null) return 'assets/sunny.json';

    switch (mainCondition.toLowerCase()) {
      case 'clouds':
        return 'assets/cloudy.json';
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'fog':
      case 'dust':
        return 'assets/misty.json';
      case 'rain':
      case 'drizzle':
      case 'shower rain':
        return 'assets/rainy.json';
      case 'clear':
        return 'assets/sunny.json';
      default:
        return 'assets/sunny.json';
    }
  }

  // gradient function

  LinearGradient getGradientForTimeOfDay() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      // Morning:
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color.fromARGB(255, 213, 213, 70),
          Color.fromARGB(159, 68, 179, 219),
        ],
      );
    } else if (hour >= 12 && hour < 17) {
      // Afternoon:
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color.fromARGB(255, 108, 225, 240),
          Color.fromARGB(118, 68, 81, 219),
        ],
      );
    } else if (hour >= 17 && hour < 22) {
      // Evening:
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color.fromARGB(159, 68, 81, 219),
          Color.fromARGB(131, 235, 47, 100),
        ],
      );
    } else {
      // Night:
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color.fromARGB(199, 54, 54, 168),
          Color.fromARGB(255, 9, 9, 45),
        ],
      );
    }
  }

  // init state
  @override
  void initState() {
    super.initState();

    // fetch the weather on startup
    _fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    // var bgColour = const Color.fromARGB(255, 28, 28, 28);
    var bgColour = const Color.fromARGB(255, 255, 255, 255);
    var textColour = const Color.fromARGB(238, 255, 255, 255);
    // var textColour = const Color.fromARGB(159, 64, 64, 64);
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    return Scaffold(
        backgroundColor: bgColour,
        body: Container(
          decoration: BoxDecoration(
            gradient: getGradientForTimeOfDay(),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_on,
                  color: textColour,
                ),
                SizedBox(height: 10),
                // city name
                Text(
                  _weather?.cityName ?? "Loading city...",
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: textColour,
                  ),
                ),
                SizedBox(height: 40),
                // animation
                Lottie.asset(getWeatherAnimation(_weather?.mainCondition)),
                SizedBox(height: 40),
                //  temperature
                Text(
                  '${_weather?.temperature.round() ?? "Loading temp... "}°C',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: textColour,
                  ),
                ),
                Text(
                  _weather?.mainCondition ?? "Loading condition...",
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: textColour,
                  ),
                )
              ],
            ),
          ),
        ));
  }
}
