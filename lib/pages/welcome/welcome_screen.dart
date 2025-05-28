import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:seyir/main.dart';
import 'package:seyir/pages/controls/token_control.dart';
import 'package:seyir/pages/homeScreens/home_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  WelcomeScreenState createState() => WelcomeScreenState();
}

class WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  bool isConnected = true;
  Future<bool> fetchedToken = Future.value(SeyirApp.tokenNotifier.value);
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  void check() async {
    final controller = Get.put<TokenControl>(TokenControl());
    fetchedToken = controller.fetchTokenItems();
    fetchedToken.then((val) {
      SeyirApp.tokenNotifier.value = val;
    }).catchError((error) {
      // Handle token fetch error in UI if needed
      print("Error fetching token: $error");
      // Optionally set a state to show an error message
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..forward();
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    check();
    checkInternetConnectivity();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> checkInternetConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    setState(() {
      isConnected = (connectivityResult == ConnectivityResult.mobile ||
          connectivityResult == ConnectivityResult.wifi);
    });

    if (!isConnected) {
      Timer(
        const Duration(seconds: 2),
        () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        ),
      );
    } else {
      Timer(const Duration(seconds: 2), () => const HomeScreen());
      // Timer(const Duration(seconds: 2), () => showNoConnectionDialog(context));
    }
  }

  void showNoConnectionDialog(BuildContext context) {
    Widget okButton = TextButton(
      child: const Text(
        "Gaýtadan synanyş",
        style: TextStyle(
          color: Color(0xffffffff),
          fontFamily: 'Bricolage',
          fontWeight: FontWeight.bold,
        ),
      ),
      onPressed: () {
        Navigator.pushNamed(context, '/welcome'); // Close the dialog
      },
    );

    AlertDialog alert = AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.wifi_off, color: Colors.redAccent),
          const SizedBox(width: 8),
          Text(
            'Duýduryş!',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontFamily: 'Bricolage',
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: Text(
        "Internet baglanyşy tapylmady. Zähmet çekip, internet baglanyşyňyzy barlap, täzeden synanyşyň.",
        style: TextStyle(
          color: Colors.grey.shade700,
          fontFamily: 'Bricolage',
          fontWeight: FontWeight.normal,
        ),
        textAlign: TextAlign.center,
      ),
      actions: [
        Center(child: okButton), // Center the button
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xff7cd4c8), Colors.teal.shade300],
          ),
        ),
        padding: const EdgeInsets.all(15),
        child: Center(
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: SizedBox(
              width: MediaQuery.of(context).size.width / 1.2,
              child: Image.asset(
                "assets/seyir/nav_logo_light.png",
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
