import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:oha/view/widgets/image_save_dialog.dart';
import 'package:oha/view/widgets/report_dialog.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_downloader/image_downloader.dart';

import '../../statics/Colors.dart';
import '../../statics/strings.dart';

class FourMoreDialog {
  static Widget _buildSMIndicator() {
    return Padding(
      padding: EdgeInsets.only(top: ScreenUtil().setHeight(12.0)),
      child: Center(
        child: Container(
          width: ScreenUtil().setWidth(67.0),
          height: ScreenUtil().setHeight(5.0),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(100.0),
          ),
        ),
      ),
    );
  }

  static Widget _contentsWidget(BuildContext context, String title,
      Function(String) onTap, String imageUrl, int postId) {
    return GestureDetector(
      onTap: () async {
        if (title == Strings.report) {
          Navigator.of(context).pop();
          ReportDialog.show(context, postId);
        } else if (title == Strings.saveImage) {
          Navigator.of(context).pop();
          await _saveImage(context, imageUrl);
        } else {
          Navigator.of(context).pop();
          onTap(title);
        }
      },
      child: Container(
        width: double.infinity,
        height: ScreenUtil().setHeight(50.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ScreenUtil().radius(8.0)),
          color: const Color(UserColors.ui10),
        ),
        child: Center(
          child: Text(
            title,
            style: const TextStyle(
              fontFamily: "Pretendard",
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(UserColors.ui01),
            ),
          ),
        ),
      ),
    );
  }

  static Future<void> _saveImage(BuildContext context, String imageUrl) async {
    var status = await Permission.storage.request();
    if (status.isGranted) {
      try {
        var imageId = await ImageDownloader.downloadImage(imageUrl);
        if (imageId == null) {
          print('Failed to download image.');
          return;
        }

        ImageSaveDialog.showCompleteDialog(context);
      } catch (error) {
        print('Failed to save image: $error');
      }
    } else {
      print('Storage permission denied');
    }
  }

  static Future<void> show(BuildContext context, Function(String) onTap,
      bool isOwn, String imageUrl, int postId) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          alignment: Alignment.bottomCenter,
          insetPadding: EdgeInsets.only(
              bottom: ScreenUtil().setHeight(35.0),
              left: ScreenUtil().setWidth(12.0),
              right: ScreenUtil().setWidth(12.0)),
          child: Container(
            width: double.infinity,
            height: isOwn
                ? ScreenUtil().setHeight(239.0)
                : ScreenUtil().setHeight(177.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(ScreenUtil().radius(10.0)),
            ),
            child: Padding(
              padding: EdgeInsets.only(
                  top: ScreenUtil().setHeight(12.0),
                  bottom: ScreenUtil().setHeight(12.0),
                  left: ScreenUtil().setWidth(12.0),
                  right: ScreenUtil().setWidth(12.0)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSMIndicator(),
                  Column(
                    children: [
                      _contentsWidget(
                          context, Strings.saveImage, onTap, imageUrl, postId),
                      if (isOwn) ...[
                        SizedBox(height: ScreenUtil().setHeight(12.0)),
                        _contentsWidget(
                            context, Strings.edit, onTap, imageUrl, postId),
                        SizedBox(height: ScreenUtil().setHeight(12.0)),
                        _contentsWidget(
                            context, Strings.delete, onTap, imageUrl, postId),
                      ] else ...[
                        SizedBox(height: ScreenUtil().setHeight(12.0)),
                        _contentsWidget(
                            context, Strings.report, onTap, imageUrl, postId),
                      ]
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
