import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:oha/view/pages/location/location_setting_page.dart';
import 'package:oha/view/widgets/complete_dialog.dart';
import 'package:oha/view_model/upload_view_model.dart';
import 'package:provider/provider.dart';

import '../../../statics/Colors.dart';
import '../../../statics/strings.dart';
import '../../../view_model/location_view_model.dart';
import '../../../view_model/weather_view_model.dart';
import '../../widgets/button_icon.dart';
import 'location_change_dialog.dart';

class LocationSettingBottomSheet extends StatelessWidget {
  const LocationSettingBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _LocationSettingBottomSheetContent();
  }
}

class _LocationSettingBottomSheetContent extends StatefulWidget {
  @override
  _LocationSettingBottomSheetContentState createState() =>
      _LocationSettingBottomSheetContentState();
}

class _LocationSettingBottomSheetContentState
    extends State<_LocationSettingBottomSheetContent> {
  final List<String> _selectedLocations = ["", "", "", ""];
  final List<String> _fullLocations = ["", "", "", ""];
  final List<String> _frequentRegionCode = ["", "", "", ""];

  LocationViewModel _locationViewModel = LocationViewModel();
  WeatherViewModel _weatherViewModel = WeatherViewModel();
  UploadViewModel _uploadViewModel = UploadViewModel();

  @override
  void initState() {
    super.initState();
    _locationViewModel = Provider.of<LocationViewModel>(context, listen: false);
    _weatherViewModel = Provider.of<WeatherViewModel>(context, listen: false);
    _uploadViewModel = Provider.of<UploadViewModel>(context, listen: false);
    getFrequentLocation();
    getFrequentRegionCode();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _removeLocation(int index) {
    if (_locationViewModel.getFrequentLength() <= 1) {
      Navigator.pop(context);

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return LocationChangeDialog(
            yesCallback: () => onLocationChangeYes(context),
            noCallback: () => onLocationChangeNo(context),
          );
        },
      );
    } else {
      getFrequentLocation();
      getFrequentRegionCode();

      Map<String, dynamic> sendData = {"code": _frequentRegionCode[index]};
      _locationViewModel.deleteFrequentDistricts(sendData);

      setState(() {
        _selectedLocations[index] = "";
        _fullLocations[index] = "";
      });
    }
  }

  void onLocationChangeYes(BuildContext context) {
    Navigator.pop(context);
    _addFrequentLocation(context, 0);
  }

  void onLocationChangeNo(BuildContext context) {
    Navigator.pop(context);
  }

  void _addFrequentLocation(BuildContext context, int index) async {
    Map<String, String?>? result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => const LocationSettingPage(isWrite: false)),
    );

    if (result != null) {
      String fullAddress = result['fullAddress'] ?? "";
      String address = result['address'] ?? "";
      String code = result['code'] ?? "";

      Map<String, dynamic> sendData = {"code": code};

      await _locationViewModel.addFrequentDistricts(sendData);

      setState(() {
        _selectedLocations[index] = address;
        _fullLocations[index] = fullAddress;
      });
    }

    _locationViewModel.fetchFrequentDistricts();
  }

  void getFrequentRegionCode() {
    List<String> list = _locationViewModel.getFrequentRegionCode();

    for (int i = 0; i < list.length; i++) {
      _frequentRegionCode[i] = list[i];
    }
  }

  void getFrequentLocation() {
    List<String> fullList = _locationViewModel.getFrequentFullAddress();
    List<String> thirdList = _locationViewModel.getFrequentThirdAddress();

    for (int i = 0; i < fullList.length; i++) {
      _fullLocations[i] = fullList[i];
    }

    for (int i = 0; i < thirdList.length; i++) {
      _selectedLocations[i] = thirdList[i];
    }
  }

  Widget _buildLocationWidget(BuildContext context, int index) {
    bool isSelectedLocation =
        _locationViewModel.getDefaultLocation == _selectedLocations[index];

    return GestureDetector(
      onTap: () async {
        if (_selectedLocations[index] == "") {
          _addFrequentLocation(context, index);
        } else {
          Navigator.pop(context, {
            'lastAddress': _selectedLocations[index],
            'regionCode': _frequentRegionCode[index]
          });

          showDialog(
            context: context,
            barrierColor: Colors.transparent,
            builder: (BuildContext context) {
              return CompleteDialog(
                  title:
                      "${_selectedLocations[index]}${Strings.locationSelectGuide}");
            },
          );

          Map<String, dynamic> sendData = {
            Strings.codeKey: _frequentRegionCode[index]
          };

          try {
            await _locationViewModel.changeDefaultFrequentDistricts(sendData);
            _locationViewModel.setDefaultLocation(_selectedLocations[index]);
            _locationViewModel
                .setDefaultLocationCode(_frequentRegionCode[index]);

            await _weatherViewModel.getDefaultWeather();
            await _weatherViewModel.fetchWeatherCount(
                {Strings.regionCodeKey: _frequentRegionCode[index]});

            sendData = {
              Strings.regionCodeKey: _locationViewModel.getDefaultLocationCode,
              Strings.offsetKey: '0',
              Strings.sizeKey: '10',
            };
            _uploadViewModel.clearUploadGetData();
            await _uploadViewModel.posts(sendData);
          } catch (error) {}
        }
      },
      child: Container(
        width: ScreenUtil().setWidth(139.0),
        height: ScreenUtil().setHeight(41.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ScreenUtil().radius(5.0)),
          color: isSelectedLocation
              ? const Color(UserColors.primaryColor)
              : Colors.white,
          border: Border.all(
              color: isSelectedLocation
                  ? Colors.white
                  : const Color(UserColors.ui08)),
        ),
        child: Padding(
          padding:
              EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(12.0)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  (_selectedLocations[index].isEmpty)
                      ? Strings.addLocation
                      : _selectedLocations[index],
                  style: TextStyle(
                    color: isSelectedLocation
                        ? Colors.white
                        : (_selectedLocations[index].isEmpty
                            ? const Color(UserColors.ui06)
                            : const Color(UserColors.ui01)),
                    fontFamily: "Pretendard",
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              ButtonIcon(
                icon:
                    (_selectedLocations[index] == "") ? Icons.add : Icons.close,
                iconColor: isSelectedLocation
                    ? Colors.white
                    : const Color(UserColors.ui01),
                callback: () => (_selectedLocations[index] == "")
                    ? _addFrequentLocation(context, index)
                    : _removeLocation(index),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: ScreenUtil().setHeight(248.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(ScreenUtil().radius(30.0)),
          topRight: Radius.circular(ScreenUtil().radius(30.0)),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: ScreenUtil().setWidth(49.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: ScreenUtil().setHeight(16.0)),
            const Text(
              Strings.locationSetting,
              style: TextStyle(
                color: Colors.black,
                fontFamily: "Pretendard",
                fontWeight: FontWeight.w600,
                fontSize: 22,
              ),
            ),
            SizedBox(height: ScreenUtil().setHeight(10.0)),
            RichText(
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: Strings.loginSubText1,
                    style: TextStyle(
                      color: Color(UserColors.primaryColor),
                      fontFamily: "Pretendard",
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  TextSpan(
                    text: Strings.locationSettingDioagGuide,
                    style: TextStyle(
                      color: Color(UserColors.ui06),
                      fontFamily: "Pretendard",
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: ScreenUtil().setHeight(16.0)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: ScreenUtil().setWidth(8.0)),
                    child: _buildLocationWidget(context, 0),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: ScreenUtil().setWidth(8.0)),
                    child: _buildLocationWidget(context, 1),
                  ),
                ),
              ],
            ),
            SizedBox(height: ScreenUtil().setHeight(12.0)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: ScreenUtil().setWidth(8.0)),
                    child: _buildLocationWidget(context, 2),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: ScreenUtil().setWidth(8.0)),
                    child: _buildLocationWidget(context, 3),
                  ),
                ),
              ],
            ),
            SizedBox(height: ScreenUtil().setHeight(16.0)),
            const Center(
              child: Text(
                Strings.frequentlyVistedAreaGuide,
                style: TextStyle(
                    color: Color(UserColors.ui06),
                    fontFamily: "Pretendard",
                    fontWeight: FontWeight.w500,
                    fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
