import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:oha/statics/colors.dart';
import 'package:oha/statics/images.dart';
import 'package:oha/statics/strings.dart';
import 'package:oha/vidw_model/location_view_model.dart';
import 'package:oha/vidw_model/weather_view_model.dart';
import 'package:oha/view/pages/home/weather_register_page.dart';
import 'package:provider/provider.dart';

class NowWeatherTab extends StatefulWidget {
  const NowWeatherTab({super.key});

  @override
  State<NowWeatherTab> createState() => _NowWeatherTabState();
}

class _NowWeatherTabState extends State<NowWeatherTab> {
  WeatherViewModel _weatherViewModel = WeatherViewModel();
  LocationViewModel _locationViewModel = LocationViewModel();
  String regionCode = "";

  @override
  void initState() {
    super.initState();

    _locationViewModel = Provider.of<LocationViewModel>(context, listen: false);
    _weatherViewModel = Provider.of<WeatherViewModel>(context, listen: false);

    getRegionCode();
    Map<String, dynamic> sendData = {"regionCode": regionCode};

    _weatherViewModel.fetchWeatherCount(sendData);
  }

  void getRegionCode() {
    regionCode =
        _locationViewModel.getFrequentLocationData.data?.data[0].code ?? '0';
  }

  Widget _buildWeatherInfoWIdget(String imagePath, String title, int count) {
    return Column(
      children: [
        SvgPicture.asset(imagePath),
        Text(
          title,
          style: const TextStyle(
            fontFamily: "Pretendard",
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(UserColors.ui01),
          ),
        ),
        SizedBox(height: ScreenUtil().setHeight(17.0)),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: count.toString(),
                style: const TextStyle(
                    color: Color(UserColors.primaryColor),
                    fontFamily: "Pretendard",
                    fontWeight: FontWeight.w600,
                    fontSize: 12),
              ),
              const TextSpan(
                text: Strings.weatherRegistered,
                style: TextStyle(
                    color: Color(UserColors.ui06),
                    fontFamily: "Pretendard",
                    fontWeight: FontWeight.w600,
                    fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: ScreenUtil().setHeight(12.0)),
            const Text(
              Strings.nowWeatherNews,
              style: TextStyle(
                fontFamily: "Pretendard",
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(UserColors.ui01),
              ),
            ),
            SizedBox(height: ScreenUtil().setHeight(12.0)),
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(ScreenUtil().radius(8.0)),
                    color: Colors.white,
                  ),
                  child: SizedBox(
                    height: ScreenUtil().setHeight(182.0),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: ScreenUtil().setWidth(25.0)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildWeatherInfoWIdget(
                          Images.littleCloudyDisable, "약간 흐려요", 1132),
                      _buildWeatherInfoWIdget(Images.cloudyDisable, "흐려요", 121),
                      _buildWeatherInfoWIdget(
                          Images.veryColdDisable, "매우 추워요", 30),
                    ],
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const WeatherRegisterPage()),
                );
              },
              child: Stack(
                children: [
                  SvgPicture.asset(Images.weatherRegistedBg),
                  Padding(
                    padding: EdgeInsets.only(
                        top: ScreenUtil().setHeight(155.0),
                        left: ScreenUtil().setWidth(32.0)),
                    child: Container(
                      width: ScreenUtil().setWidth(139.0),
                      height: ScreenUtil().setHeight(41.0),
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(ScreenUtil().radius(8.0)),
                        border: Border.all(
                            color: const Color(UserColors.ui08),
                            width: ScreenUtil().setWidth(1.0)),
                        color: Colors.white,
                      ),
                      child: const Center(
                        child: Text(
                          Strings.register,
                          style: TextStyle(
                            fontFamily: "Pretendard",
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(UserColors.ui01),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: ScreenUtil().setHeight(100.0)),
          ],
        ),
      ),
    );
  }
}
