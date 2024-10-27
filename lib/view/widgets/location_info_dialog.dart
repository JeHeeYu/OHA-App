import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../statics/colors.dart';
import '../../statics/strings.dart';
import '../../view_model/upload_view_model.dart';
import 'button_icon.dart';
import 'infinity_button.dart';

class LocationInfoDialog extends StatefulWidget {
  @override
  _LocationInfoDialogState createState() => _LocationInfoDialogState();
}

class _LocationInfoDialogState extends State<LocationInfoDialog> {
  final _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late UploadViewModel _uploadViewModel;

  @override
  void initState() {
    super.initState();
    _uploadViewModel = Provider.of<UploadViewModel>(context, listen: false);
  }

  Widget _buildExampleWidget() {
    return Container(
      width: ScreenUtil().setWidth(106.0),
      height: ScreenUtil().setHeight(35.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ScreenUtil().radius(22.0)),
        color: Colors.white,
        border: Border.all(color: const Color(UserColors.ui08)),
      ),
      child: const Center(
        child: Text(
          Strings.exampleLocation,
          style: TextStyle(
            color: Color(UserColors.ui06),
            fontFamily: "Pretendard",
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildLocationWidget(String location, bool isMain) {
    final textSize = _getTextWidth(
      text: location,
      style: const TextStyle(
        color: Color(UserColors.ui01),
        fontFamily: "Pretendard",
        fontWeight: FontWeight.w500,
        fontSize: 16,
      ),
    );

    return Container(
      height: ScreenUtil().setHeight(35.0),
      width: textSize.width + ScreenUtil().setWidth(50.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ScreenUtil().radius(22.0)),
        border: Border.all(color: const Color(UserColors.ui08)),
      ),
      alignment: Alignment.center,
      child: Row(
        children: [
          SizedBox(width: ScreenUtil().setWidth(10.0)),
          Text(
            location,
            style: const TextStyle(
              color: Color(UserColors.ui01),
              fontFamily: "Pretendard",
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
          SizedBox(width: ScreenUtil().setWidth(4.0)),
          ButtonIcon(
            icon: Icons.cancel,
            iconColor: const Color(UserColors.ui07),
            callback: () {
              setState(() {
                if (isMain) {
                  _uploadViewModel.setMainUploadLocation("");
                } else {
                  _uploadViewModel.setDetailUploadLocation("");
                }
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSMIndicator() {
    return Center(
      child: Container(
        width: ScreenUtil().setWidth(67.0),
        height: ScreenUtil().setHeight(5.0),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(100.0),
        ),
      ),
    );
  }

  void _onAddClicked() {
    Navigator.pop(context);
  }

  void _onEnterClicked() {
    if (_controller.text.isEmpty) return;

    _uploadViewModel.setDetailUploadLocation(_controller.text);

    _controller.clear();
  }

  static Size _getTextWidth({
    required String text,
    required TextStyle style,
    int? maxLines,
    TextDirection? textDirection,
  }) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: maxLines ?? 1,
      textDirection: textDirection ?? TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.size;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Padding(
        padding: EdgeInsets.only(
          top: ScreenUtil().setHeight(70.0),
          left: ScreenUtil().setWidth(12.0),
          right: ScreenUtil().setWidth(12.0),
        ),
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            width: double.infinity,
            height: ScreenUtil().setHeight(347.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(22.0)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: ScreenUtil().setHeight(11.0)),
                  _buildSMIndicator(),
                  SizedBox(height: ScreenUtil().setHeight(29.0)),
                  const Text(
                    Strings.addInputLocation,
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: "Pretendard",
                      fontWeight: FontWeight.w600,
                      fontSize: 22,
                    ),
                  ),
                  SizedBox(height: ScreenUtil().setHeight(4.0)),
                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: Strings.addInputLocationGuide1,
                          style: TextStyle(
                              color: Color(UserColors.ui06),
                              fontFamily: "Pretendard",
                              fontWeight: FontWeight.w500,
                              fontSize: 12),
                        ),
                        TextSpan(
                          text: Strings.addInputLocationGuide2,
                          style: TextStyle(
                              color: Color(UserColors.primaryColor),
                              fontFamily: "Pretendard",
                              fontWeight: FontWeight.w500,
                              fontSize: 12),
                        ),
                        TextSpan(
                          text: Strings.addInputLocationGuide3,
                          style: TextStyle(
                              color: Color(UserColors.ui06),
                              fontFamily: "Pretendard",
                              fontWeight: FontWeight.w500,
                              fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: ScreenUtil().setHeight(22.0)),
                  Row(
                    children: [
                      (_uploadViewModel.getMainUploadLocation.isEmpty)
                          ? _buildExampleWidget()
                          : _buildLocationWidget(
                              _uploadViewModel.getMainUploadLocation, true),
                      SizedBox(width: ScreenUtil().setWidth(11.0)),
                      (_uploadViewModel.getDetailUploadLocation.isNotEmpty)
                          ? _buildLocationWidget(
                              _uploadViewModel.getDetailUploadLocation, false)
                          : Container(),
                    ],
                  ),
                  SizedBox(height: ScreenUtil().setHeight(22.0)),
                  SizedBox(
                    height: ScreenUtil().setHeight(50.0),
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      maxLines: 1,
                      expands: false,
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                        color: Color(UserColors.ui01),
                        fontFamily: "Pretendard",
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(UserColors.ui11),
                        hintText: Strings.locationHintText,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide.none,
                        ),
                        hintStyle: const TextStyle(
                          color: Color(UserColors.ui06),
                          fontFamily: "Pretendard",
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      textInputAction: TextInputAction.done,
                      onSubmitted: (value) {
                        setState(() {
                          _onEnterClicked();
                        });
                      },
                      onChanged: (text) {
                        setState(() {});
                      },
                    ),
                  ),
                  SizedBox(height: ScreenUtil().setHeight(22.0)),
                  InfinityButton(
                    height: ScreenUtil().setHeight(50.0),
                    radius: ScreenUtil().radius(8.0),
                    backgroundColor: (_controller.text.isEmpty)
                        ? const Color(UserColors.ui10)
                        : const Color(UserColors.primaryColor),
                    text: Strings.add,
                    textSize: 16,
                    textWeight: FontWeight.w600,
                    textColor: (_controller.text.isEmpty)
                        ? const Color(UserColors.ui06)
                        : Colors.white,
                    callback: _onAddClicked,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
