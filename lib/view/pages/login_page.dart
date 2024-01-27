import 'package:fk_user_agent/fk_user_agent.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:oha/network/network_manager.dart';
import 'package:oha/statics/colors.dart';

import '../../statics/images.dart';
import '../../statics/strings.dart';

enum LoginType {
  kakao,
  apple,
  google,
  naver,
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  Widget _buildLoginWidget(LoginType type) {
    return GestureDetector(
      onTap: () {
        switch (type) {
          case LoginType.kakao:
            break;
          case LoginType.apple:
            break;
          case LoginType.google:
            break;
          case LoginType.naver:
            break;
        }
      },
      child: SvgPicture.asset(
        _getLoginImage(type),
        height: ScreenUtil().setHeight(50.0),
        width: ScreenUtil().setWidth(50.0),
      ),
    );
  }

  String _getLoginImage(LoginType type) {
    switch (type) {
      case LoginType.kakao:
        return Images.loginKakao;
      case LoginType.apple:
        return Images.loginApple;
      case LoginType.google:
        return Images.loginGoogle;
      case LoginType.naver:
        return Images.loginNaver;
    }
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
        body: InAppWebView(
  initialUrlRequest: URLRequest(url: Uri.parse("http://52.79.158.1/api/auth/kakao/login")),
  //initialUrlRequest: URLRequest(url: Uri.parse("www.naver.com")),
  initialOptions: InAppWebViewGroupOptions(
    crossPlatform: InAppWebViewOptions(
      //userAgent: webViewUserAgent
    ),
  )
)
        // body: Column(
        //   crossAxisAlignment: CrossAxisAlignment.stretch,
        //   children: [
        //     SizedBox(height: ScreenUtil().setHeight(86.0)),
        //     Expanded(
        //         child: Padding(
        //       padding:
        //           EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(22.0)),
        //       child: Column(
        //         crossAxisAlignment: CrossAxisAlignment.start,
        //         children: [
        //           const Text(
        //             Strings.loginMainText,
        //             style: TextStyle(
        //                 color: Colors.black,
        //                 fontFamily: "Pretendard",
        //                 fontWeight: FontWeight.w600,
        //                 fontSize: 24),
        //           ),
        //           SizedBox(height: ScreenUtil().setHeight(6.0)),
        //           RichText(
        //             text: const TextSpan(
        //               children: [
        //                 TextSpan(
        //                   text: Strings.loginSubText1,
        //                   style: TextStyle(
        //                       color: Color(UserColors.primaryColor),
        //                       fontFamily: "Pretendard",
        //                       fontWeight: FontWeight.w500,
        //                       fontSize: 14),
        //                 ),
        //                 TextSpan(
        //                   text: Strings.loginSubText2,
        //                   style: TextStyle(
        //                       color: Color(UserColors.ui06),
        //                       fontFamily: "Pretendard",
        //                       fontWeight: FontWeight.w500,
        //                       fontSize: 14),
        //                 ),
        //               ],
        //             ),
        //           ),
        //         ],
        //       ),
        //     )),
        //     SvgPicture.asset(Images.loginBg),
        //     SizedBox(height: ScreenUtil().setHeight(28.0)),
        //     _buildLoginWidget(LoginType.kakao),
        //     SizedBox(height: ScreenUtil().setHeight(12.0)),
        //     _buildLoginWidget(LoginType.apple),
        //     SizedBox(height: ScreenUtil().setHeight(12.0)),
        //     _buildLoginWidget(LoginType.google),
        //     SizedBox(height: ScreenUtil().setHeight(12.0)),
        //     _buildLoginWidget(LoginType.naver),
        //     SizedBox(height: ScreenUtil().setHeight(166.0)),
        //   ],
        // ),
        );
  }
}
