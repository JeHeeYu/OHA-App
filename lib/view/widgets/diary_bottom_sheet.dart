import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:oha/view/pages/diary/diary_register_page.dart';
import 'package:oha/view/widgets/delete_dialog.dart';
import 'package:oha/view/widgets/complete_dialog.dart';
import 'package:oha/view/widgets/diary_feed_widget.dart';
import 'package:oha/view/widgets/four_more_dialog.dart';
import 'package:oha/view/widgets/more_dialog.dart';
import 'package:provider/provider.dart';
import '../../../models/diary/my_diary_model.dart';
import '../../../view_model/diary_view_model.dart';
import '../../../statics/strings.dart';

class DiaryBottomSheet {
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

  static void show(BuildContext context, MyDiaryData diaryData, int? userId) {
    final DiaryViewModel _diaryViewModel =
        Provider.of<DiaryViewModel>(context, listen: false);

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
                    itemCount: diaryData.diaries?.length ?? 0,
                    itemBuilder: (context, index) {
                      final diary = diaryData.diaries![index];
                      return Padding(
                        padding:
                            EdgeInsets.only(top: ScreenUtil().setHeight(12.0)),
                        child: DiaryFeedWidget(
                            diaryData: diary,
                            writerData: diaryData.writer!,
                            onLikePressed: () => _onLikePressed(
                                  context,
                                  diary.diaryId,
                                  diary.likes,
                                  _diaryViewModel,
                                ),
                            showLine: index < (diaryData.diaries!.length - 1),
                            onMorePressed: () => {
                                  if (userId != null)
                                    {
                                      MoreDialog.show(
                                        context,
                                        (diary.fileRelation != null &&
                                                diary.fileRelation!.isNotEmpty)
                                            ? diary.fileRelation![0].fileUrl
                                            : '',
                                        diary.diaryId,
                                      )
                                    }
                                  else
                                    {
                                      FourMoreDialog.show(
                                        context,
                                        (action) => _onMorePressed(
                                          context,
                                          diary.diaryId,
                                          action,
                                          diary,
                                          _diaryViewModel,
                                        ),
                                        true,
                                        (diary.fileRelation != null &&
                                                diary.fileRelation!.isNotEmpty)
                                            ? diary.fileRelation![0].fileUrl
                                            : '',
                                        diary.diaryId,
                                      ),
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

  static void _onLikePressed(BuildContext context, int diaryId, String likes,
      DiaryViewModel diaryViewModel) async {
    Map<String, dynamic> data = {
      "diaryId": diaryId,
      "type": int.parse(likes) > 0 ? "U" : "L"
    };

    // final statusCode = await diaryViewModel.like(data);

    // if (statusCode == 201 || statusCode == 200) {
    // }
  }

  static void _onMorePressed(BuildContext context, int diaryId, String action,
      MyDiary diary, DiaryViewModel diaryViewModel) {
    switch (action) {
      case Strings.saveImage:
        // Save Image Logic
        break;
      case Strings.edit:
        final dateTime = DateTime.parse(
          '${diary.setDate.substring(0, 4)}-${diary.setDate.substring(4, 6)}-${diary.setDate.substring(6, 8)}',
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DiaryRegisterPage(
              selectDate: dateTime,
              isEdit: true,
              diaryData: diary,
            ),
          ),
        );
        break;
      case Strings.delete:
        _showYesNoDialog(context, diaryId, diaryViewModel);
        break;
      default:
        break;
    }
  }

  static void _showYesNoDialog(
      BuildContext context, int diaryId, DiaryViewModel diaryViewModel) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return YesNoDialog(
          height: ScreenUtil().setHeight(178.0),
          titleText: Strings.diaryDeleteTitle,
          guideText: Strings.diaryDeleteContent,
          yesCallback: () => _onDeleteYes(context, diaryId, diaryViewModel),
          noCallback: () => Navigator.pop(context),
        );
      },
    );
  }

  static void _onDeleteYes(
      BuildContext context, int diaryId, DiaryViewModel diaryViewModel) async {
    final response = await diaryViewModel.diaryDelete(diaryId.toString());

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
        return const CompleteDialog(title: Strings.diaryDeleteComplete);
      },
    );
  }
}
