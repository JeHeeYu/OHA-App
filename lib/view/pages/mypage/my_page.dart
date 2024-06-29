import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:oha/statics/colors.dart';
import 'package:oha/statics/images.dart';
import 'package:oha/statics/strings.dart';
import 'package:oha/vidw_model/my_page_view_model.dart';
import 'package:oha/view/pages/login_page.dart';
import 'package:oha/view/pages/mypage/profile_edit_page.dart';
import 'package:oha/view/pages/mypage/terms_and_Policies.dart';
import 'package:oha/view/widgets/complete_dialog.dart';
import 'package:provider/provider.dart';

import '../../../vidw_model/login_view_model.dart';
import '../../widgets/notification_app_bar.dart';
import 'delete_dialog.dart';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  LoginViewModel _loginViewModel = LoginViewModel();
  MyPageViewModel _myPageViewModel = MyPageViewModel();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();

    _loginViewModel = Provider.of<LoginViewModel>(context, listen: false);
    _myPageViewModel = Provider.of<MyPageViewModel>(context, listen: false);
  }

  void _onLogout() async {
    await _loginViewModel.logout().then((value) {
      if (value == 200) {
        _storage.deleteAll();

        Navigator.pop(context); // Close the dialog

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (Route<dynamic> route) => false,
        );

        CompleteDialog.showCompleteDialog(context, Strings.logoutComplete);
      }
    }).onError((error, stackTrace) {});
  }

  void _onWithDraw() async {
    try {
      await _loginViewModel.withDraw().then((value) => {
            Navigator.pop(context),
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
              (Route<dynamic> route) => false,
            ),
          });

      if (!mounted) return;

      CompleteDialog.showCompleteDialog(context, Strings.withDrawComplete);
    } catch (e) {}
  }

  void _showDeleteDialog(String title, String guide, VoidCallback yesCallback) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DeleteDialog(
          titleText: title,
          guideText: guide,
          yesCallback: () {
            Navigator.pop(context);
            yesCallback();
          },
          noCallback: () => Navigator.pop(context),
        );
      },
    );
  }

  void _showAgreementPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TermsAndPolicies()),
    );
  }

  Widget _buildProfileWidget() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfileEditPage()),
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          (_myPageViewModel.myInfoData.data?.data.profileUrl?.isEmpty ?? true)
              ? SvgPicture.asset(Images.defaultProfile)
              : Image.network(
                  _myPageViewModel.myInfoData.data?.data.profileUrl ?? ""),
          SizedBox(width: ScreenUtil().setWidth(12.0)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _myPageViewModel.myInfoData.data?.data.name ?? '',
                style: TextStyle(
                  fontFamily: "Pretendard",
                  fontSize: ScreenUtil().setSp(24.0),
                  fontWeight: FontWeight.w700,
                  color: const Color(UserColors.ui01),
                ),
              ),
              GestureDetector(
                onTap: () {
                  return;
                },
                child: Text(
                  Strings.loginProviderMap["NAVER"] ?? Strings.loginedWithKakao,
                  style: TextStyle(
                    fontFamily: "Pretendard",
                    fontSize: ScreenUtil().setSp(14.0),
                    fontWeight: FontWeight.w500,
                    color: const Color(UserColors.ui06),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContentsWidget(String title, VoidCallback callback, bool arrow) {
    return GestureDetector(
      onTap: callback,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: "Pretendard",
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          (arrow)
              ? const Icon(Icons.arrow_forward_ios, color: Colors.black)
              : Container(),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    _showDeleteDialog(
      Strings.logout,
      Strings.logoutGuide,
      _onLogout,
    );
  }

  void _showWithDrawDialog() {
    _showDeleteDialog(
      Strings.withDraw,
      Strings.withDrawGiude,
      _onWithDraw,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const NotificationAppBar(
        title: Strings.myPage,
      ),
      body: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(22.0)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: ScreenUtil().setHeight(17.0)),
                  _buildProfileWidget(),
                  SizedBox(height: ScreenUtil().setHeight(40.0)),
                  const Text(
                    Strings.updateHistory,
                    style: TextStyle(
                      fontFamily: "Pretendard",
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const Text(
                    Strings.noUpdateHistory,
                    style: TextStyle(
                      fontFamily: "Pretendard",
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(UserColors.ui06),
                    ),
                  ),
                  SizedBox(height: ScreenUtil().setHeight(28.0)),
                  _buildContentsWidget(
                      Strings.termsAndPolicies, _showAgreementPage, true),
                  SizedBox(height: ScreenUtil().setHeight(26.0)),
                  _buildContentsWidget(
                      Strings.accountCancel, _showWithDrawDialog, false),
                  SizedBox(height: ScreenUtil().setHeight(26.0)),
                  _buildContentsWidget(
                      Strings.logout, _showLogoutDialog, false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
