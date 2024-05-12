import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:oha/statics/colors.dart';
import 'package:oha/statics/images.dart';
import 'package:oha/statics/strings.dart';
import 'package:oha/vidw_model/location_view_model.dart';
import 'package:oha/view/pages/home/weather/weather_select_dialog.dart';
import 'package:oha/view/widgets/infinity_button.dart';
import 'package:provider/provider.dart';

import '../../../../vidw_model/weather_view_model.dart';
import '../../../widgets/back_close_app_bar.dart';
import '../../../widgets/complete_dialog.dart';
import '../../location/location_setting_dialog.dart';

class WeatherRegisterPage extends StatefulWidget {
  const WeatherRegisterPage({super.key});

  @override
  State<WeatherRegisterPage> createState() => _WeatherRegisterPageState();
}

class _WeatherRegisterPageState extends State<WeatherRegisterPage> {
  String _selectTitle = "";
  String _selectImage = "";
  String _selectRegionCode = "";
  String _selectThirdAddress = "";
  String _selectWeatherCode = "";
  LocationViewModel _locationViewModel = LocationViewModel();
  WeatherViewModel _weatherViewModel = WeatherViewModel();
  List<String> _frequentRegionCode = ["", "", "", ""];
  List<String> _frequentThirdAddress = ["", "", "", ""];

  /*
    흐림	WTHR_CLOUDY
    약간 흐림	WTHR_PARTLY_CLOUDY
    구름 많음	WTHR_MOSTLY_CLOUDY
    맑음	WTHR_CLEAR
    비	WTHR_RAIN
    천둥	WTHR_THUNDER
    눈	WTHR_SNOW
    천둥 비	WTHR_THUNDER_RAIN
    매우 더움	WTHR_VERY_HOT
    밤공기	WTHR_NIGHT_AIR
    바람	WTHR_WIND
    매우 추움	WTHR_VERY_COLD
    무지개	WTHR_RAINBOW
  */

  final String cloudy = "WTHR_CLOUDY";
  final String littleCloudy = "WTHR_PARTLY_CLOUDY";
  final String manyCloud = "WTHR_MOSTLY_CLOUDY";
  final String sunny = "WTHR_CLEAR";
  final String rain = "WTHR_RAIN";
  final String thunder = "WTHR_THUNDER";
  final String snow = "WTHR_SNOW";
  final String thunderSnow = "WTHR_THUNDER_RAIN";
  final String veryHot = "WTHR_VERY_HOT";
  final String nightAir = "WTHR_NIGHT_AIR";
  final String wind = "WTHR_WIND";
  final String veryCold = "WTHR_VERY_COLD";
  final String rainbow = "WTHR_RAINBOW";

  @override
  void initState() {
    super.initState();

    _locationViewModel = Provider.of<LocationViewModel>(context, listen: false);

    getFrequentRegionCode();
    getFrequentThirdAddress();
  }

  void getFrequentRegionCode() {
    List<String> list = _locationViewModel.getFrequentRegionCode();

    if (list.isNotEmpty) {
      _selectRegionCode = list[0];
    }

    for (int i = 0; i < list.length; i++) {
      _frequentRegionCode[i] = list[i];
    }
  }

  void getFrequentThirdAddress() {
    List<String> list = _locationViewModel.getFrequentThirdAddress();

    if (list.isNotEmpty) {
      _selectThirdAddress = list[0];
    }

    for (int i = 0; i < list.length; i++) {
      _frequentThirdAddress[i] = list[i];
    }
  }

  Widget _buildTitleGuide() {
    return Column(
      children: [
        SizedBox(height: ScreenUtil().setHeight(12.0)),
        const Text(
          Strings.neighborhoodWeather,
          style: TextStyle(
              color: Colors.black,
              fontFamily: "Pretendard",
              fontWeight: FontWeight.w600,
              fontSize: 20),
        ),
        SizedBox(height: ScreenUtil().setHeight(9.0)),
        const Text(
          Strings.weatherRegisterGuide,
          style: TextStyle(
              color: Color(UserColors.ui06),
              fontFamily: "Pretendard",
              fontWeight: FontWeight.w400,
              fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildWeatherInfoGuide() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          Strings.questionWeather,
          style: TextStyle(
              color: Color(UserColors.ui01),
              fontFamily: "Pretendard",
              fontWeight: FontWeight.w600,
              fontSize: 16),
        ),
        SizedBox(height: ScreenUtil().setHeight(9.0)),
        const Text(
          Strings.chooseIcon,
          style: TextStyle(
              color: Color(UserColors.ui06),
              fontFamily: "Pretendard",
              fontWeight: FontWeight.w400,
              fontSize: 13),
        ),
        SizedBox(height: ScreenUtil().setHeight(22.0)),
      ],
    );
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

  Widget _buildCurrentLocationGuide() {
    return const Text(
      Strings.curretLocationNeighborhood,
      style: TextStyle(
        fontFamily: "Pretendard",
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Color(UserColors.ui01),
      ),
    );
  }

  Widget _buildCurrentLocation() {
    return GestureDetector(
      onTap: () async {
        Map<String, String?>? result = await showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
          ),
          builder: (BuildContext context) {
            return LocationSettingBottomSheet();
          },
        );

        if (result != null) {
          String lastAddress = result['lastAddress'] ?? "";
          String regionCode = result['regionCode'] ?? "";
          setState(() {
            _selectThirdAddress = lastAddress;
            _selectRegionCode = regionCode;
          });
        }
      },
      child: Container(
        width: ScreenUtil().setWidth(139.0),
        height: ScreenUtil().setHeight(41.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ScreenUtil().radius(8.0)),
          border: Border.all(
              color: const Color(UserColors.ui08),
              width: ScreenUtil().setWidth(1.0)),
          color: Colors.white,
        ),
        child: Padding(
          padding: EdgeInsets.only(left: ScreenUtil().setWidth(15.0)),
          child: Row(
            children: [
              const Icon(Icons.expand_more, color: Color(UserColors.ui06)),
              SizedBox(width: ScreenUtil().setWidth(10.0)),
              Text(
                _selectThirdAddress,
                style: const TextStyle(
                  fontFamily: "Pretendard",
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(UserColors.ui01),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _getWeatherSelect() async {
    final result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return WeatherSelectDialog();
      },
    );

    if (result != null) {
      setState(() {
        _selectTitle = result['title'];
        _selectImage = result['image'];
        _selectWeatherCode = getWeatherCode(_selectTitle);
      });
    }
  }

  Widget _buildEmptyWeatherSelect() {
    return GestureDetector(
      onTap: () async {
        _getWeatherSelect();
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(ScreenUtil().radius(8.0)),
              color: Colors.white,
              border: Border.all(
                color: const Color(UserColors.ui08),
              ),
            ),
            child: SizedBox(
              height: ScreenUtil().setHeight(82.0),
            ),
          ),
          Padding(
            padding:
                EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(25.0)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SvgPicture.asset(Images.cloudyDisable),
                SvgPicture.asset(Images.littleCloudyDisable),
                SvgPicture.asset(Images.manyCloudDisable),
                SvgPicture.asset(Images.sunnyDisable),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectWidgetWidget() {
    return GestureDetector(
      onTap: () {
        _getWeatherSelect();
      },
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(ScreenUtil().radius(8.0)),
              color: Colors.white,
              border: Border.all(
                color: const Color(UserColors.ui08),
              ),
            ),
            child: SizedBox(
              height: ScreenUtil().setHeight(82.0),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: ScreenUtil().setWidth(25.0)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SvgPicture.asset(_selectImage),
                SizedBox(
                  width: ScreenUtil().setWidth(32.0),
                ),
                Text(
                  _selectTitle,
                  style: const TextStyle(
                      color: Colors.black,
                      fontFamily: "Pretendard",
                      fontWeight: FontWeight.w600,
                      fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool completeState() {
    return _selectImage != "" &&
        _selectTitle != "" &&
        _selectThirdAddress != "" &&
        _selectRegionCode != "";
  }

  String getWeatherCode(String title) {
    switch (title) {
      case Strings.cloudy:
        return cloudy;
      case Strings.littleCloudy:
        return littleCloudy;
      case Strings.manyCloud:
        return manyCloud;
      case Strings.sunny:
        return sunny;
      case Strings.rain:
        return rain;
      case Strings.thunder:
        return thunder;
      case Strings.snow:
        return snow;
      case Strings.thunderSnow:
        return thunderSnow;
      case Strings.veryHot:
        return veryHot;
      case Strings.nightAir:
        return nightAir;
      case Strings.wind:
        return wind;
      case Strings.veryCold:
        return veryCold;
      case Strings.rainbow:
        return rainbow;
      default:
        return "";
    }
  }

  void sendWeatherPosting() {
    if (completeState()) {
      Map<String, dynamic> sendData = {
        "regionCode": _selectRegionCode,
        "weatherCode": _selectWeatherCode
      };

      _weatherViewModel.addWeatherPosting(sendData).then((response) {
        if (response == 201) {
          Navigator.pop(context);
          showDialog(
            context: context,
            barrierColor: Colors.transparent,
            builder: (BuildContext context) {
              return const CompleteDialog(title: Strings.addWeatherCompleteText);
            },
          );
        } else {}
      }).catchError((error) {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const BackCloseAppBar(title: Strings.weatherRegister),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(22.0)),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTitleGuide(),
                    SizedBox(height: ScreenUtil().setHeight(46.0)),
                    _buildCurrentLocationGuide(),
                    SizedBox(height: ScreenUtil().setHeight(12.0)),
                    _buildCurrentLocation(),
                    SizedBox(height: ScreenUtil().setHeight(50.0)),
                    _buildWeatherInfoGuide(),
                    (_selectTitle == "" || _selectImage == "")
                        ? _buildEmptyWeatherSelect()
                        : _buildSelectWidgetWidget(),
                    SizedBox(height: ScreenUtil().setHeight(23.0)),
                    const Text(
                      Strings.peopleWeatherInfo,
                      style: TextStyle(
                          color: Color(UserColors.ui06),
                          fontFamily: "Pretendard",
                          fontWeight: FontWeight.w400,
                          fontSize: 13),
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
                            border: Border.all(
                              color: const Color(UserColors.ui08),
                            ),
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
                              _buildWeatherInfoWIdget(
                                  Images.cloudyDisable, "흐려요", 121),
                              _buildWeatherInfoWIdget(
                                  Images.veryColdDisable, "매우 추워요", 30),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: ScreenUtil().setHeight(52.0)),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: ScreenUtil().setHeight(23.0)),
              child: InfinityButton(
                height: ScreenUtil().setHeight(50.0),
                radius: ScreenUtil().radius(8.0),
                backgroundColor: (completeState())
                    ? const Color(UserColors.primaryColor)
                    : const Color(UserColors.ui10),
                text: Strings.register,
                textSize: 16,
                textWeight: FontWeight.w600,
                textColor: (completeState())
                    ? Colors.white
                    : const Color(UserColors.ui06),
                callback: sendWeatherPosting,
              ),
            )
          ],
        ),
      ),
    );
  }
}
