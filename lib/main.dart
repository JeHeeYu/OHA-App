import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:oha/view/pages/agreements/agreements_page.dart';
import 'package:oha/view/pages/home_page.dart';
import 'package:oha/view/pages/login_page.dart';
import 'package:oha/view/pages/splash_page.dart';

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

    if (Platform.isAndroid) {
    await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (BuildContext context, child) => MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const App(),
      ),
    );
  }
}
