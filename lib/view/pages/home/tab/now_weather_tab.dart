import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:oha/statics/colors.dart';
import 'package:oha/statics/images.dart';
import 'package:oha/statics/strings.dart';
import 'package:oha/view/pages/error_page.dart';
import 'package:oha/view/widgets/loading_widget.dart';
import 'package:oha/view/widgets/now_weather_widget.dart';
import 'package:provider/provider.dart';

import '../../../../network/api_response.dart';
import '../../../../view_model/location_view_model.dart';
import '../../../../view_model/weather_view_model.dart';
import '../weather/my_weather_register_page.dart';
import '../weather/weather_register_page.dart';

class NowWeatherTab extends StatefulWidget {
  const NowWeatherTab({super.key});

  @override
  State<NowWeatherTab> createState() => _NowWeatherTabState();
}

class _NowWeatherTabState extends State<NowWeatherTab> {
  String regionCode = "";
  VoidCallback? _retryCallback;

  @override
  void initState() {
    super.initState();
  }

  Widget _buildNowWeatherNewsText() {
    return const Text(
      Strings.nowWeatherNews,
      style: TextStyle(
        fontFamily: "Pretendard",
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Color(UserColors.ui01),
      ),
    );
  }

  Widget _buildMyRegisterWeatherWidget() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const MyWeatherRegisterPage()),
        );
      },
      child: Padding(
        padding: EdgeInsets.only(top: ScreenUtil().setHeight(22.0)),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(ScreenUtil().radius(8.0)),
                color: Colors.white,
                border: Border.all(
                  color: const Color(UserColors.primaryColor),
                  width: ScreenUtil().setWidth(1.0),
                ),
              ),
              child: SizedBox(
                height: ScreenUtil().setHeight(50.0),
              ),
            ),
            const Text(
              Strings.myWeatherInformation,
              style: TextStyle(
                fontFamily: "Pretendard",
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(UserColors.primaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherRegisterWidget() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  const WeatherRegisterPage(editState: false)),
        );
      },
      child: SvgPicture.asset(Images.weatherRegistedBg)
    );
  }

  Widget _buildCompleteWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: ScreenUtil().setHeight(12.0)),
        _buildNowWeatherNewsText(),
        SizedBox(height: ScreenUtil().setHeight(12.0)),
        const NowWeatherWidget(),
        _buildMyRegisterWeatherWidget(),
        SizedBox(height: ScreenUtil().setHeight(32.0)),
        _buildWeatherRegisterWidget(),
        SizedBox(height: ScreenUtil().setHeight(100.0)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(22.0)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCompleteWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
