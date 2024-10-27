import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../statics/Colors.dart';
import '../../statics/strings.dart';

class YesNoDialog extends StatelessWidget {
  final double height;
  final String titleText;
  final String guideText;
  final VoidCallback yesCallback;
  final VoidCallback noCallback;
  final String yesText;
  final String noText;

  const YesNoDialog({
    Key? key,
    required this.height,
    required this.titleText,
    required this.guideText,
    this.yesCallback = _yesCallback,
    this.noCallback = _noCallback,
    this.yesText = "예", // 기본값으로 "예"
    this.noText = "아니오", // 기본값으로 "아니오"
  }) : super(key: key);

  static void _yesCallback() {}

  static void _noCallback() {}

  Widget _buildButtonWidget(String title, bool isYesButton) {
    return GestureDetector(
      onTap: () {
        isYesButton ? yesCallback() : noCallback();
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: ScreenUtil().setWidth(150.0),
            height: ScreenUtil().setHeight(41.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(ScreenUtil().radius(5.0)),
              color: isYesButton
                  ? const Color(UserColors.primaryColor)
                  : const Color(UserColors.ui10),
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: isYesButton ? Colors.white : const Color(UserColors.ui06),
              fontFamily: "Pretendard",
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      alignment: Alignment.center,
      insetPadding: EdgeInsets.only(
        bottom: ScreenUtil().setHeight(50.0),
        left: ScreenUtil().setWidth(25.0),
        right: ScreenUtil().setWidth(25.0),
      ),
      child: Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ScreenUtil().radius(10.0)),
          color: Colors.white,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: ScreenUtil().setWidth(14.0),
              vertical: ScreenUtil().setHeight(22.0)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                titleText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black,
                  fontFamily: "Pretendard",
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: ScreenUtil().setHeight(24.0)),
              Text(
                guideText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(UserColors.ui01),
                  fontFamily: "Pretendard",
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: ScreenUtil().setHeight(24.0)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildButtonWidget(noText, false),
                  _buildButtonWidget(yesText, true),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}