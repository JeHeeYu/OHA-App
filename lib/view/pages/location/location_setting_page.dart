import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:oha/view/widgets/complete_dialog.dart';
import 'package:oha/view_model/location_view_model.dart';
import 'package:oha/view/pages/location/location_app_bar_widget.dart';
import 'package:oha/view/pages/location/location_find_button.dart';
import 'package:provider/provider.dart';
import '../../../statics/Colors.dart';
import '../../../statics/strings.dart';

class LocationSettingPage extends StatefulWidget {
  final bool isWrite;

  const LocationSettingPage({super.key, this.isWrite = false});

  @override
  State<LocationSettingPage> createState() => _LocationSettingPageState();
}

class _LocationSettingPageState extends State<LocationSettingPage> {
  final _controller = TextEditingController();
  List<Map<String, String>> _allLocationList = [];
  List<Map<String, String>> _displayLocationList = [];
  late LocationViewModel _locationViewModel;

  @override
  void initState() {
    super.initState();

    _locationViewModel = Provider.of<LocationViewModel>(context, listen: false);

    _allLocationList = _getAllLocations();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Map<String, String>> _getAllLocations() {
    List<Map<String, String>> locations = [];
    final data = _locationViewModel.getLocationData.data?.data.locations;

    if (data != null) {
      for (final province in data.keys) {
        final cityMap = data[province];
        if (cityMap != null) {
          for (final city in cityMap.keys) {
            final districts = cityMap[city];
            if (districts != null) {
              for (final district in districts) {
                locations.add({
                  'fullAddress': "$province $city ${district.address}",
                  'address': district.address,
                  'code': district.code,
                });
              }
            }
          }
        }
      }
    }
    return locations;
  }

  void _onLocationFound(Map<String, String>? location) {
    if (location != null) {
      setState(() {
        _controller.text = location['fullAddress']!;
        _displayLocationList = [location];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const LocationAppBarWidget(
          title: Strings.locationSetting, backIcon: Icons.close),
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(22.0)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _controller,
              textAlign: TextAlign.start,
              style: const TextStyle(
                color: Color(UserColors.ui01),
                fontFamily: "Pretendard",
                fontWeight: FontWeight.w700,
                fontSize: 16,
                letterSpacing: -0.41 / 16,
                height: 25 / 16,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(UserColors.ui11),
                hintText: Strings.locationHint,
                hintStyle: const TextStyle(
                  color: Color(UserColors.ui06),
                  fontFamily: "Pretendard",
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  letterSpacing: -0.41 / 14,
                  height: 25 / 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
              ),
              maxLines: 1,
              textInputAction: TextInputAction.done,
              onChanged: (value) {
                setState(() {
                  _displayLocationList = _allLocationList
                      .where((location) => location['fullAddress']!
                          .toLowerCase()
                          .contains(value.toLowerCase()))
                      .toList();
                });
              },
            ),
            SizedBox(height: ScreenUtil().setHeight(14.0)),
            LocationFindButton(onLocationFound: _onLocationFound),
            SizedBox(height: ScreenUtil().setHeight(22.0)),
            const Text(
              Strings.neighborhoodLocation,
              style: TextStyle(
                fontFamily: "Pretendard",
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(UserColors.ui06),
              ),
            ),
            SizedBox(height: ScreenUtil().setHeight(12.0)),
            Expanded(
              child: ListView.builder(
                  itemCount: (_displayLocationList.isEmpty)
                      ? _allLocationList.length
                      : _displayLocationList.length,
                  itemBuilder: (BuildContext context, int index) {
                    final locationMap = (_displayLocationList.isEmpty)
                        ? _allLocationList[index]
                        : _displayLocationList[index];
                    final locationDisplay = locationMap['fullAddress'] ?? '';
                    final locationCode = locationMap['code'] ?? '';

                    return Padding(
                      padding:
                          EdgeInsets.only(bottom: ScreenUtil().setHeight(24.0)),
                      child: GestureDetector(
                        onTap: () async {
                          if (!widget.isWrite &&
                              _locationViewModel
                                  .isLocationAlreadyAdded(locationCode)) {
                            CompleteDialog.showCompleteDialog(
                                context, Strings.isLocationAlreadyAdded);
                          } else {
                            await _locationViewModel.fetchFrequentDistricts();
                            Navigator.pop(context, locationMap);
                          }
                        },
                        child: Text(
                          locationDisplay,
                          style: const TextStyle(
                            fontFamily: "Pretendard",
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(UserColors.ui01),
                          ),
                        ),
                      ),
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
