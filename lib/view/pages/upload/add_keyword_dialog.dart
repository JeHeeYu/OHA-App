import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../statics/Colors.dart';
import '../../../statics/strings.dart';
import '../../widgets/infinity_button.dart';
import 'package:oha/view_model/upload_view_model.dart';

class AddKeywordDialog extends StatefulWidget {
  const AddKeywordDialog({super.key});

  @override
  State<AddKeywordDialog> createState() => _AddKeywordDialogState();
}

class _AddKeywordDialogState extends State<AddKeywordDialog> {
  final _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late UploadViewModel _uploadViewModel;

  @override
  void initState() {
    super.initState();
    _uploadViewModel = Provider.of<UploadViewModel>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
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
          Strings.exampleKeyword,
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

  Widget _buildKeywordWidget(String text, int index) {
    final textSize = _getTextWidth(
      text: text,
      style: const TextStyle(
        color: Color(UserColors.ui01),
        fontFamily: "Pretendard",
        fontWeight: FontWeight.w500,
        fontSize: 16,
      ),
    );

    return GestureDetector(
      onTap: () {
        setState(() {});
      },
      child: Container(
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
              text,
              style: const TextStyle(
                color: Color(UserColors.ui01),
                fontFamily: "Pretendard",
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
            SizedBox(width: ScreenUtil().setWidth(3.0)),
            GestureDetector(
              onTap: () {
                setState(() {
                  _uploadViewModel.getKetwordList.removeAt(index);
                });
              },
              child: const Icon(Icons.cancel, color: Color(UserColors.ui07)),
            ),
            SizedBox(width: ScreenUtil().setWidth(7.0)),
          ],
        ),
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

  void addKeyword() {
    setState(() {
      if (_controller.text.isNotEmpty) {
        _uploadViewModel.setUploadKeywordList(_controller.text);
        _controller.text = "";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Padding(
        padding: EdgeInsets.only(
            top: ScreenUtil().setHeight(70.0),
            left: ScreenUtil().setWidth(12.0),
            right: ScreenUtil().setWidth(12.0)),
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
                    Strings.addKeywordSetting,
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
                          text: Strings.addKeywordGuide1,
                          style: TextStyle(
                              color: Color(UserColors.primaryColor),
                              fontFamily: "Pretendard",
                              fontWeight: FontWeight.w500,
                              fontSize: 12),
                        ),
                        TextSpan(
                          text: Strings.addKeywordGuide2,
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
                  (_uploadViewModel.getKetwordList.isEmpty)
                      ? _buildExampleWidget()
                      : SizedBox(
                          height: ScreenUtil().setHeight(35.0),
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _uploadViewModel.getKetwordList.length,
                            separatorBuilder:
                                (BuildContext context, int index) {
                              return SizedBox(
                                  width: ScreenUtil().setWidth(8.0));
                            },
                            itemBuilder: (BuildContext context, int index) {
                              return _buildKeywordWidget(
                                  _uploadViewModel.getKetwordList[index],
                                  index);
                            },
                          ),
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
                      textAlignVertical: TextAlignVertical.center,
                      style: const TextStyle(
                        color: Color(UserColors.ui01),
                        fontFamily: "Pretendard",
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        decoration: TextDecoration.none,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(UserColors.ui11),
                        hintText: Strings.uploadWriteHintText,
                        hintStyle: const TextStyle(
                          color: Color(UserColors.ui06),
                          fontFamily: "Pretendard",
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          decoration: TextDecoration.none,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      textInputAction: TextInputAction.done,
                      onSubmitted: (value) {
                        addKeyword();
                      },
                    ),
                  ),
                  SizedBox(height: ScreenUtil().setHeight(22.0)),
                  Padding(
                    padding:
                        EdgeInsets.only(bottom: ScreenUtil().setHeight(42.0)),
                    child: InfinityButton(
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
                      callback: () {
                        addKeyword();
                        Navigator.pop(context, _uploadViewModel.getKetwordList);
                      },
                    ),
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
