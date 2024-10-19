import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:oha/view/widgets/delete_dialog.dart';
import 'package:oha/view/pages/upload/upload_write_page.dart';
import 'package:oha/view/widgets/complete_dialog.dart';
import 'package:oha/view/widgets/feed_widget.dart';
import 'package:oha/view/widgets/four_more_dialog.dart';
import 'package:oha/view/widgets/more_dialog.dart';
import 'package:provider/provider.dart';
import '../../../models/upload/upload_get_model.dart';
import '../../../view_model/upload_view_model.dart';
import '../../../statics/strings.dart';

class PostingBottomSheet {
  static Widget _buildSMIndicator() {
    return Padding(
      padding: EdgeInsets.only(bottom: ScreenUtil().setHeight(16.0)),
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

  static void show(BuildContext context, List<UploadData> uploads) {
    final UploadViewModel _uploadViewModel =
        Provider.of<UploadViewModel>(context, listen: false);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25.0),
        ),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.9,
          minChildSize: 0.9,
          maxChildSize: 0.9,
          builder: (BuildContext context, ScrollController scrollController) {
            return Column(
              children: [
                SizedBox(height: ScreenUtil().setHeight(19.0)),
                _buildSMIndicator(),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: uploads.length,
                    itemBuilder: (context, index) {
                      final data = uploads[index];
                      return Padding(
                        padding:
                            EdgeInsets.only(top: ScreenUtil().setHeight(12.0)),
                        child: FeedWidget(
                            uploadData: data,
                            onLikePressed: () => _onLikePressed(context,
                                data.postId, data.isLike, _uploadViewModel),
                            onMorePressed: () {
                              if (data.isOwn) {
                                FourMoreDialog.show(
                                  context,
                                  (action) => _onMorePressed(
                                      context,
                                      data.postId,
                                      action,
                                      data,
                                      _uploadViewModel),
                                  data.isOwn,
                                  data.files.isNotEmpty
                                      ? data.files[0].url
                                      : '',
                                  data.postId,
                                );
                              } else {
                                MoreDialog.show(
                                  context,
                                  data.files.isNotEmpty
                                      ? data.files[0].url
                                      : '',
                                  data.postId,
                                );
                              }
                            }),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  static void _onLikePressed(BuildContext context, int postId,
      bool isCurrentlyLiked, UploadViewModel uploadViewModel) async {
    Map<String, dynamic> data = {
      "postId": postId,
      "type": isCurrentlyLiked ? "U" : "L"
    };

    final statusCode = await uploadViewModel.like(data);

    if (statusCode == 201 || statusCode == 200) {}
  }

  static void _onMorePressed(BuildContext context, int postId, String action,
      UploadData data, UploadViewModel uploadViewModel) {
    switch (action) {
      case Strings.saveImage:
        break;
      case Strings.edit:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UploadWritePage(
              isEdit: true,
              uploadData: data,
            ),
          ),
        );
        break;
      case Strings.delete:
        _showYesNoDialog(context, postId, uploadViewModel);
        break;
      default:
        break;
    }
  }

  static void _showYesNoDialog(
      BuildContext context, int postId, UploadViewModel uploadViewModel) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return YesNoDialog(
          height: ScreenUtil().setHeight(178.0),
          titleText: Strings.postDeleteTitle,
          guideText: Strings.postDeleteContent,
          yesCallback: () => _onDeleteYes(context, postId, uploadViewModel),
          noCallback: () => Navigator.pop(context),
        );
      },
    );
  }

  static void _onDeleteYes(
      BuildContext context, int postId, UploadViewModel uploadViewModel) async {
    final response = await uploadViewModel.delete(postId.toString());

    if (response == 201) {
      Navigator.pop(context);
      _showCompleteDialog(context);
    } else {
      Navigator.pop(context);
    }
  }

  static void _showCompleteDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return const CompleteDialog(title: Strings.postDeleteComplete);
      },
    );
  }
}
