import 'package:flutter/material.dart';
import 'package:oha/view/pages/upload/upload_page.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:oha/statics/Colors.dart';
import 'package:oha/statics/images.dart';
import 'package:oha/statics/strings.dart';
import 'package:oha/view/widgets/infinity_button.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UploadAgreementsPage extends StatefulWidget {
  const UploadAgreementsPage({super.key});

  @override
  State<UploadAgreementsPage> createState() => _UploadAgreementsPageState();
}

class _UploadAgreementsPageState extends State<UploadAgreementsPage> {
  bool _allAgreements = false;
  bool _albumAgreements = false;
  bool _cameraAgreements = false;
  bool _micAgreements = false;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Widget _buildAllAgreementsWidget() {
    return Stack(
      alignment: Alignment.centerLeft,
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8.0)),
            color: const Color(UserColors.ui11),
          ),
          child: SizedBox(height: ScreenUtil().setHeight(50.0)),
        ),
        Padding(
          padding: EdgeInsets.all(ScreenUtil().setWidth(11.0)),
          child: Row(
            children: [
              GestureDetector(
                  onTap: () {
                    _toggleAgreementState(Strings.allAgreements);
                  },
                  child: SvgPicture.asset(
                      _allAgreements ? Images.check : Images.uncheck)),
              SizedBox(width: ScreenUtil().setWidth(11.0)),
              const Text(
                Strings.allAgreements,
                style: TextStyle(
                    color: Colors.black,
                    fontFamily: "Pretendard",
                    fontWeight: FontWeight.w700,
                    fontSize: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAgreementsWidget(String title, String guide, bool isChecked) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
            onTap: () {
              _toggleAgreementState(title);
            },
            child: SvgPicture.asset(isChecked ? Images.check : Images.uncheck)),
        SizedBox(width: ScreenUtil().setWidth(11.0)),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                  color: Color(UserColors.ui04),
                  fontFamily: "Pretendard",
                  fontWeight: FontWeight.w500,
                  fontSize: 16),
            ),
            Text(
              guide,
              style: const TextStyle(
                  color: Color(UserColors.ui04),
                  fontFamily: "Pretendard",
                  fontWeight: FontWeight.w500,
                  fontSize: 13),
            ),
          ],
        ),
      ],
    );
  }

  void _toggleAgreementState(String title) {
    setState(() {
      switch (title) {
        case Strings.albumAgreement:
          _albumAgreements = !_albumAgreements;
          break;
        case Strings.cameraAccessAgreement:
          _cameraAgreements = !_cameraAgreements;
          break;
        case Strings.micAccessAgreement:
          _micAgreements = !_micAgreements;
          break;
        default:
          _allAgreements = !_allAgreements;
          _albumAgreements = _allAgreements;
          _cameraAgreements = _allAgreements;
          _micAgreements = _allAgreements;
          break;
      }
    });
  }

  bool _getAllAgreements() {
    return _albumAgreements && _cameraAgreements && _micAgreements;
  }

  void _requestPermissions() async {
    if (_cameraAgreements) {
      await Permission.camera.request();
      await _storage.write(key: Strings.isCameraGranted, value: 'true');
    }
    if (_micAgreements) {
      await Permission.microphone.request();
      await _storage.write(key: Strings.isMicGranted, value: 'true');
    }
    
    if(!mounted || !_getAllAgreements()) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const UploadPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(22.0)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: ScreenUtil().setHeight(86.0)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    Strings.uploadMainGuide,
                    style: TextStyle(
                        color: Colors.black,
                        fontFamily: "Pretendard",
                        fontWeight: FontWeight.w600,
                        fontSize: 24),
                  ),
                  SizedBox(height: ScreenUtil().setHeight(4.0)),
                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: Strings.uploadSubGuide1,
                          style: TextStyle(
                              color: Color(UserColors.primaryColor),
                              fontFamily: "Pretendard",
                              fontWeight: FontWeight.w500,
                              fontSize: 14),
                        ),
                        TextSpan(
                          text: Strings.uploadSubGuide2,
                          style: TextStyle(
                              color: Color(UserColors.ui06),
                              fontFamily: "Pretendard",
                              fontWeight: FontWeight.w500,
                              fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: ScreenUtil().setHeight(56.0)),
                  _buildAllAgreementsWidget(),
                  SizedBox(height: ScreenUtil().setHeight(32.0)),
                  Padding(
                    padding: EdgeInsets.only(left: ScreenUtil().setWidth(11.0)),
                    child: Column(
                      children: [
                        _buildAgreementsWidget(Strings.albumAgreement,
                            Strings.albumAgreementGuide, _albumAgreements),
                        SizedBox(height: ScreenUtil().setHeight(14.0)),
                        _buildAgreementsWidget(
                            Strings.cameraAccessAgreement,
                            Strings.cameraAccessAgreementGuide,
                            _cameraAgreements),
                        SizedBox(height: ScreenUtil().setHeight(14.0)),
                        _buildAgreementsWidget(Strings.micAccessAgreement,
                            Strings.micAccessAgreementGuide, _micAgreements),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: ScreenUtil().setHeight(44)),
              child: InfinityButton(
                height: ScreenUtil().setHeight(50.0),
                radius: 8.0,
                backgroundColor: _getAllAgreements()
                    ? const Color(UserColors.primaryColor)
                    : const Color(UserColors.ui10),
                text: Strings.next,
                textSize: 16,
                textWeight: FontWeight.w600,
                textColor: _getAllAgreements()
                    ? Colors.white
                    : const Color(UserColors.ui06),
                callback: () => _requestPermissions(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
