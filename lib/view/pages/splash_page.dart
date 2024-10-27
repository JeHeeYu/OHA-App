import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:oha/statics/images.dart';
import 'package:oha/utils/app_initializer.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkInternetConnection();
  }

  Future<void> _checkInternetConnection() async {
    try {
      var connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        _showNoInternetDialog();
      } else {
        AppInitializer.initialize(context);
      }
    } catch (e) {
      print("에러 발생 123123: $e");
      _showErrorDialog(e.toString());
    }
  }

  void _showNoInternetDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("인터넷 연결 끊김"),
          content: const Text("인터넷에 연결되어 있지 않습니다. 앱을 종료합니다."),
          actions: <Widget>[
            TextButton(
              child: const Text("확인"),
              onPressed: () {
                Navigator.of(context).pop();
                _closeApp();
              },
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("오류 발생"),
          content: Text("오류가 발생했습니다: $message"),
          actions: <Widget>[
            TextButton(
              child: const Text("확인"),
              onPressed: () {
                Navigator.of(context).pop();
                _closeApp();
              },
            ),
          ],
        );
      },
    );
  }

  void _closeApp() {
    Future.delayed(const Duration(milliseconds: 100), () {
      SystemNavigator.pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: SvgPicture.asset(
              Images.splashBg,
              fit: BoxFit.cover,
            ),
          ),
          const Positioned(
            right: 30,
            bottom: 30,
            child: Text(
              "Ver 1.5.4\n241027",
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
