import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:oha/statics/colors.dart';
import 'package:oha/statics/images.dart';
import 'package:oha/statics/strings.dart';
import 'package:oha/view/pages/upload/upload_write_page.dart';
import 'package:oha/view/widgets/diary_bottom_sheet.dart';
import 'package:oha/view/widgets/more_dialog.dart';
import 'package:oha/view/widgets/posting_bottom_sheet.dart';
import 'package:oha/view_model/diary_view_model.dart';
import 'package:oha/view_model/upload_view_model.dart';
import 'package:oha/view/pages/diary/month_calendar_widget.dart';
import 'package:oha/view/pages/diary/week_calendar_widget.dart';
import 'package:oha/view/widgets/button_icon.dart';
import 'package:oha/view/widgets/notification_app_bar.dart';
import 'package:provider/provider.dart';
import '../../../models/diary/my_diary_model.dart';
import '../../../models/upload/upload_get_model.dart';
import '../../widgets/complete_dialog.dart';
import '../../widgets/feed_widget.dart';
import '../../widgets/four_more_dialog.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/delete_dialog.dart';
import 'diary_register_page.dart';

class DiaryPage extends StatefulWidget {
  final int? userId;

  const DiaryPage({super.key, this.userId});

  @override
  State<DiaryPage> createState() => _DiaryPageState();
}

class _DiaryPageState extends State<DiaryPage> {
  DateTime currentTime = DateTime.now();
  bool viewMonth = true;
  bool showFeed = false;
  VoidCallback? retryCallback;
  late DiaryViewModel _diaryViewModel;
  late UploadViewModel _uploadViewModel;
  DateTime selectedDate = DateTime.now();
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  bool _isLoading = false;
  bool _didLoadData = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 100 &&
          !_isLoadingMore) {
        _loadMoreData();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();

    if (widget.userId != null) {
      Future.microtask(() {
        _uploadViewModel.clearUserUploadGetData();
        if (mounted) {
          setState(() {});
        }
      });
    }

    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didLoadData) {
      _didLoadData = true;
      _diaryViewModel = Provider.of<DiaryViewModel>(context, listen: false);
      _uploadViewModel = Provider.of<UploadViewModel>(context, listen: false);

      if (widget.userId != null) {
        _fetchUserPosts(widget.userId!);
        _isLoading = true;
      } else {
        _fetchData();
      }
    }
  }

  Future<void> _fetchData() async {
    try {
      await _diaryViewModel.fetchMyDiary().then((_) {
        retryCallback = null;
      }).catchError((error) {
        retryCallback = () => _diaryViewModel.fetchMyDiary();
      });

      await _uploadViewModel.myPosts().then((_) {
        retryCallback = null;
      }).catchError((error) {
        retryCallback = () => _uploadViewModel.myPosts();
      });
      _uploadViewModel.clearMyUploadGetData();
    } catch (error) {
      retryCallback = () {
        _diaryViewModel.fetchMyDiary();
        _uploadViewModel.myPosts();
      };
    }
  }

  Future<void> _fetchUserPosts(int userId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _diaryViewModel.fetchUserDiary(userId);
      await _uploadViewModel.userPosts(userId).then((_) {
        retryCallback = null;
      }).catchError((error) {
        retryCallback = () => _uploadViewModel.userPosts(userId);
      });
    } catch (error) {
      retryCallback = () {
        _uploadViewModel.userPosts(userId);
      };
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreData() async {
    setState(() {
      _isLoadingMore = true;
    });

    try {
      if (widget.userId != null) {
        await _uploadViewModel.userPosts(widget.userId!);
      } else {
        await _uploadViewModel.myPosts();
      }
    } catch (error) {
    } finally {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  String getCurrentTime() {
    return DateFormat('yyyy년 MM월', 'ko_KR').format(currentTime);
  }

  void addCurrentTime() {
    setState(() {
      if (viewMonth) {
        currentTime =
            DateTime(currentTime.year, currentTime.month + 1, currentTime.day);
      } else {
        currentTime = currentTime.add(Duration(days: 7));
      }
    });
  }

  void subCurrentTime() {
    setState(() {
      if (viewMonth) {
        currentTime =
            DateTime(currentTime.year, currentTime.month - 1, currentTime.day);
      } else {
        currentTime = currentTime.subtract(Duration(days: 7));
      }
    });
  }

  void onDateSelected(DateTime date) {
    setState(() {
      selectedDate = date;
      print("Selected Date: $selectedDate");
      print(
          "Diaries on Selected Date: ${_diaryViewModel.getDiariesByDate(selectedDate)}");
    });
  }

  void _showDiaryBottomSheet(BuildContext context, DateTime selectedDate) {
    final diariesOnSelectedDate = _diaryViewModel.getDiariesByDate(
      selectedDate,
      isUserDiary: widget.userId != null,
    );

    if (diariesOnSelectedDate.isNotEmpty) {
      DiaryBottomSheet.show(
          context,
          MyDiaryData(
            writer: widget.userId == null
                ? _diaryViewModel.getMyDiary.data?.data?.writer
                : _diaryViewModel.getUserDiary.data?.data?.writer,
            diaries: diariesOnSelectedDate,
          ),
          widget.userId);
    }
  }

  Widget _buildCalendarTypeWidget(bool month, String type) {
    return Container(
      width: ScreenUtil().setWidth(46.0),
      height: ScreenUtil().setHeight(35.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ScreenUtil().radius(22.0)),
        color: (month)
            ? const Color(UserColors.primaryColor)
            : const Color(UserColors.ui10),
      ),
      child: Center(
        child: Text(
          type,
          style: TextStyle(
            color: (month) ? Colors.white : const Color(UserColors.ui06),
            fontFamily: "Pretendard",
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildPostingImageWidget(String? fileUrl) {
    return Container(
      width: ScreenUtil().setWidth(92.0),
      height: ScreenUtil().setHeight(100.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ScreenUtil().radius(5.0)),
        color: Colors.white,
        border: Border.all(color: const Color(UserColors.ui11)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: fileUrl != null && fileUrl.isNotEmpty
          ? Container(
              margin: EdgeInsets.only(
                  top: ScreenUtil().setHeight(6.0),
                  bottom: ScreenUtil().setHeight(14.0),
                  left: ScreenUtil().setWidth(6.0),
                  right: ScreenUtil().setWidth(6.0)),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(ScreenUtil().radius(5.0)),
                image: DecorationImage(
                  image: NetworkImage(fileUrl),
                  fit: BoxFit.cover,
                ),
              ),
            )
          : Container(
              margin: EdgeInsets.only(
                  top: ScreenUtil().setHeight(6.0),
                  bottom: ScreenUtil().setHeight(14.0),
                  left: ScreenUtil().setWidth(6.0),
                  right: ScreenUtil().setWidth(6.0)),
              decoration: BoxDecoration(
                color: const Color(UserColors.ui10),
                borderRadius: BorderRadius.circular(ScreenUtil().radius(5.0)),
              ),
            ),
    );
  }

  Widget _buildProfileWidget() {
    String profileUrl = '';

    if (widget.userId == null) {
      profileUrl =
          _diaryViewModel.getMyDiary.data?.data?.writer?.profileUrl ?? '';
    } else {
      profileUrl =
          _diaryViewModel.getUserDiary.data?.data?.writer?.profileUrl ?? '';
    }

    if (profileUrl.isEmpty) {
      return SvgPicture.asset(
        Images.defaultProfile,
        fit: BoxFit.cover,
      );
    } else {
      return Image.network(
        profileUrl,
        fit: BoxFit.cover,
      );
    }
  }

  Widget _buildUserInfoWidget() {
    return Consumer<DiaryViewModel>(
      builder: (context, viewModel, child) {
        MyDiaryModel? model;
        if (widget.userId == null) {
          model = viewModel.getMyDiary.data;
        } else {
          model = viewModel.getUserDiary.data;
        }

        final userName = model?.data?.writer?.name ?? '';
        final diaryCount = model?.data?.diaries?.length;
        final totalLikes = _getTotalLikes(viewModel);
        return Row(
          children: [
            Container(
              width: ScreenUtil().setWidth(44.0),
              height: ScreenUtil().setHeight(44.0),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: _buildProfileWidget(),
              ),
            ),
            SizedBox(width: ScreenUtil().setWidth(14.0)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: "Pretendard",
                    fontWeight: FontWeight.w600,
                    fontSize: ScreenUtil().setSp(14.0),
                  ),
                ),
                Text(
                  Strings.diaryInfoText(diaryCount ?? 0, totalLikes),
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: "Pretendard",
                    fontWeight: FontWeight.w300,
                    fontSize: ScreenUtil().setSp(12.0),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  int _getTotalLikes(DiaryViewModel viewModel) {
    int totalLikes = 0;
    for (var diary in viewModel.getMyDiary.data?.data?.diaries ?? []) {
      totalLikes += int.tryParse(diary.likes) ?? 0;
    }
    return totalLikes;
  }

  Widget _buildMonthChangeWidget() {
    return Container(
      width: double.infinity,
      height: ScreenUtil().setHeight(53.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ScreenUtil().radius(10.0)),
        color: Colors.white,
        border: Border.all(
          color: const Color(UserColors.ui10),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.05),
            offset: const Offset(0, 0),
            blurRadius: 5,
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              ButtonIcon(
                icon: Icons.chevron_left,
                iconColor: Colors.black,
                callback: () => subCurrentTime(),
              ),
              SizedBox(width: ScreenUtil().setWidth(10.0)),
              Text(
                getCurrentTime(),
                style: const TextStyle(
                  color: Colors.black,
                  fontFamily: "Pretendard",
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              SizedBox(width: ScreenUtil().setWidth(10.0)),
              ButtonIcon(
                icon: Icons.chevron_right,
                iconColor: Colors.black,
                callback: () => addCurrentTime(),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(right: ScreenUtil().setWidth(15.0)),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      showFeed = false;
                    });
                  },
                  child: SvgPicture.asset(
                    showFeed
                        ? Images.diaryCalendarDisable
                        : Images.diaryCalendarEnable,
                  ),
                ),
                SizedBox(width: ScreenUtil().setWidth(9.0)),
                Container(
                  width: ScreenUtil().setWidth(1.0),
                  height: ScreenUtil().setHeight(14.0),
                  color: const Color(UserColors.ui09),
                ),
                SizedBox(width: ScreenUtil().setWidth(9.0)),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      showFeed = true;
                    });
                  },
                  child: SvgPicture.asset(
                    showFeed ? Images.diaryFeedEnable : Images.diaryFeedDisable,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarTypeContainerWidget() {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              viewMonth = true;
            });
          },
          child: _buildCalendarTypeWidget(viewMonth, Strings.month),
        ),
        SizedBox(width: ScreenUtil().setWidth(6.0)),
        GestureDetector(
          onTap: () {
            setState(() {
              viewMonth = false;
            });
          },
          child: _buildCalendarTypeWidget(!viewMonth, Strings.week),
        ),
      ],
    );
  }

  Widget _buildPostingText() {
    return const Text(
      Strings.posting,
      style: TextStyle(
        color: Colors.black,
        fontFamily: "Pretendard",
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
    );
  }

  Widget _buildPostingWidget() {
    final myUploads = widget.userId != null
        ? _uploadViewModel.userUploadGetData.data?.data ?? []
        : _uploadViewModel.myUploadGetData.data?.data ?? [];
    final selectedDateUploads = myUploads.where((upload) {
      final uploadDate = DateTime.parse(upload.regDtm);
      return uploadDate.year == selectedDate.year &&
          uploadDate.month == selectedDate.month &&
          uploadDate.day == selectedDate.day;
    }).toList();

    if (selectedDateUploads.isEmpty) {
      return Row(
        children: [
          _buildPostingImageWidget(null),
          SizedBox(width: ScreenUtil().setWidth(12.0)),
          Text(
            Strings.postEmpty,
            style: TextStyle(
              color: const Color(UserColors.ui06),
              fontFamily: "Pretendard",
              fontWeight: FontWeight.w500,
              fontSize: ScreenUtil().setSp(14.0),
            ),
          ),
        ],
      );
    }

    final upload = selectedDateUploads.first;

    return GestureDetector(
      onTap: () {
        PostingBottomSheet.show(context, selectedDateUploads);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPostingImageWidget(upload.thumbnailUrl),
              SizedBox(width: ScreenUtil().setWidth(12.0)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: ScreenUtil().setWidth(180.0),
                    child: Text(
                      upload.content,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: const TextStyle(
                        color: Colors.black,
                        fontFamily: "Pretendard",
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      SvgPicture.asset(Images.location),
                      SizedBox(width: ScreenUtil().setWidth(3.0)),
                      SizedBox(
                        width: ScreenUtil().setWidth(150.0),
                        child: Text(
                          "${upload.firstAddress} ${upload.secondAddress} ${upload.thirdAddress}",
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: const TextStyle(
                            color: Colors.black,
                            fontFamily: "Pretendard",
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      SvgPicture.asset(Images.heart),
                      SizedBox(width: ScreenUtil().setWidth(3.0)),
                      Text(
                        "${upload.likeCount}",
                        style: const TextStyle(
                          color: Colors.black,
                          fontFamily: "Pretendard",
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(width: ScreenUtil().setWidth(3.0)),
                      SvgPicture.asset(Images.views),
                      SizedBox(width: ScreenUtil().setWidth(3.0)),
                      Text(
                        "${upload.commentCount}",
                        style: const TextStyle(
                          color: Colors.black,
                          fontFamily: "Pretendard",
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(right: ScreenUtil().setWidth(25.0)),
            child: ButtonIcon(
              icon: Icons.more_horiz,
              iconColor: const Color(UserColors.ui06),
              callback: () {
                if (widget.userId != null) {
                  MoreDialog.show(
                    context,
                    upload.thumbnailUrl,
                    upload.postId,
                  );
                } else {
                  FourMoreDialog.show(
                    context,
                    (action) =>
                        _onMorePressed(upload.postId, action, null, upload),
                    true,
                    upload.thumbnailUrl,
                    upload.postId,
                  );
                }
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDiaryText() {
    return Row(
      children: [
        const Text(
          Strings.diary,
          style: TextStyle(
            color: Colors.black,
            fontFamily: "Pretendard",
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        (widget.userId == null)
            ? ButtonIcon(
                icon: Icons.add,
                iconColor: const Color(UserColors.ui04),
                callback: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          DiaryRegisterPage(selectDate: selectedDate),
                    ),
                  );
                })
            : Container(),
      ],
    );
  }

  Widget _buildDiaryWidget(MyDiary? diary) {
    return GestureDetector(
      onTap: () {
        if (diary != null) {
          print("JEhee ${diary}");
          _showDiaryBottomSheet(context, selectedDate);
        }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              _buildPostingImageWidget(diary?.fileRelation?.isNotEmpty == true
                  ? (diary?.fileRelation?[0].fileUrl)
                  : null),
              SizedBox(width: ScreenUtil().setWidth(12.0)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    diary?.title ?? Strings.diaryEmpty,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                      color: const Color(UserColors.ui06),
                      fontFamily: "Pretendard",
                      fontWeight: FontWeight.w500,
                      fontSize: ScreenUtil().setSp(14.0),
                    ),
                  ),
                  if (diary != null) ...[
                    Row(
                      children: [
                        SvgPicture.asset(Images.location),
                        SizedBox(width: ScreenUtil().setWidth(3.0)),
                        SizedBox(
                          width: ScreenUtil().setWidth(150.0),
                          child: Text(
                            diary.location,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: const TextStyle(
                              color: Colors.black,
                              fontFamily: "Pretendard",
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        SvgPicture.asset(Images.heart),
                        SizedBox(width: ScreenUtil().setWidth(3.0)),
                        Text(
                          diary.likes,
                          style: const TextStyle(
                            color: Colors.black,
                            fontFamily: "Pretendard",
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(width: ScreenUtil().setWidth(3.0)),
                        SvgPicture.asset(Images.views),
                        SizedBox(width: ScreenUtil().setWidth(3.0)),
                        Text(
                          diary.views,
                          style: const TextStyle(
                            color: Colors.black,
                            fontFamily: "Pretendard",
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ],
          ),
          if (diary != null)
            Padding(
              padding: EdgeInsets.only(right: ScreenUtil().setWidth(25.0)),
              child: ButtonIcon(
                icon: Icons.more_horiz,
                iconColor: const Color(UserColors.ui06),
                callback: () => FourMoreDialog.show(
                  context,
                  (action) =>
                      _onMorePressed(diary.diaryId, action, diary, null),
                  true,
                  diary.fileRelation?.isNotEmpty == true
                      ? diary.fileRelation![0].fileUrl
                      : '',
                  diary.diaryId,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFeedWidget() {
    final myUploads = widget.userId != null
        ? _uploadViewModel.userUploadGetData.data?.data ?? []
        : _uploadViewModel.myUploadGetData.data?.data ?? [];
    final filteredUploads = myUploads.where((upload) {
      final uploadDate = DateTime.parse(upload.regDtm);
      if (viewMonth) {
        return uploadDate.year == currentTime.year &&
            uploadDate.month == currentTime.month;
      } else {
        return uploadDate
                .isAfter(currentTime.subtract(const Duration(days: 7))) &&
            uploadDate.isBefore(currentTime.add(const Duration(days: 7)));
      }
    }).toList();

    if (filteredUploads.isEmpty) {
      return _buildPostEmptyWidget();
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      controller: _scrollController,
      itemCount: filteredUploads.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == filteredUploads.length) {
          return _buildLoadingWidget();
        }

        var data = filteredUploads[index];
        return Padding(
          padding: EdgeInsets.only(top: ScreenUtil().setHeight(12.0)),
          child: FeedWidget(
            uploadData: data,
            onLikePressed: () => _onLikePressed(data.postId, data.isLike),
            onMorePressed: () => FourMoreDialog.show(
                context,
                (action) => _onMorePressed(data.postId, action, null, data),
                data.isOwn,
                data.files.isNotEmpty ? data.files[0].url : '',
                data.postId),
            onProfilePressed: () => _onProfilePressed(data.userId, data.isOwn),
          ),
        );
      },
    );
  }

  void _onLikePressed(int postId, bool isCurrentlyLiked) async {
    print("Like pressed for postId: $postId");

    Map<String, dynamic> data = {
      "postId": postId,
      "type": isCurrentlyLiked ? "U" : "L"
    };

    final statusCode = await _uploadViewModel.like(data);

    if (statusCode == 201 || statusCode == 200) {
      setState(() {});
    }
  }

  void _onMorePressed(
      int id, String action, MyDiary? diary, UploadData? upload) {
    switch (action) {
      case Strings.saveImage:
        print('Save Image $id');
        break;
      case Strings.edit:
        if (upload != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UploadWritePage(
                isEdit: true,
                uploadData: upload,
              ),
            ),
          );
        } else if (diary != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DiaryRegisterPage(
                selectDate: selectedDate,
                isEdit: true,
                diaryData: diary,
              ),
            ),
          );
        }
        break;
      case Strings.delete:
        print('Post ID to delete: $id');
        bool result;
        if (upload != null) {
          result = true;
        } else {
          result = false;
        }
        showYesNoDialog(id, result);
        break;
      default:
        break;
    }
  }

  void _onProfilePressed(int userId, bool isOwn) {
    if (isOwn == true) {
      return;
    }

    print("Profile Pressed");
  }

  void showYesNoDialog(int postId, bool isUpload) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return YesNoDialog(
          height: ScreenUtil().setHeight(178.0),
          titleText: Strings.postDeleteTitle,
          guideText: Strings.postDeleteContent,
          yesCallback: () => onPostingDeleteYes(context, postId, isUpload),
          noCallback: () => onPostingDeleteNo(context),
        );
      },
    );
  }

  void onPostingDeleteYes(
      BuildContext context, int postId, bool isUpload) async {
    final response;
    if (isUpload) {
      response = await _uploadViewModel.delete(postId.toString());
    } else {
      response = await _diaryViewModel.diaryDelete(postId.toString());
    }

    if (response == 201 || response == 200) {
      if (mounted) {
        Navigator.pop(context);
        showCompleteDialog();
        _fetchData();
      }
    } else {
      if (mounted) {
        Navigator.pop(context);
      }
      print('삭제 실패: $response');
    }
  }

  void onPostingDeleteNo(BuildContext context) {
    Navigator.pop(context);
  }

  void showCompleteDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return const CompleteDialog(title: Strings.postDeleteComplete);
      },
    );
  }

  Widget _buildPostEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: ScreenUtil().setHeight(50.0)),
          SvgPicture.asset(Images.postEmpty),
          SizedBox(height: ScreenUtil().setHeight(19.0)),
          Text(
            Strings.postEmptyGuide,
            style: TextStyle(
              color: const Color(UserColors.ui06),
              fontFamily: "Pretendard",
              fontWeight: FontWeight.w400,
              fontSize: ScreenUtil().setSp(16.0),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return const LoadingWidget();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const NotificationAppBar(
        title: Strings.diary,
        isUnderLine: true,
      ),
      backgroundColor: Colors.white,
      body: _isLoading
          ? _buildLoadingWidget()
          : Consumer<DiaryViewModel>(
              builder: (context, diaryViewModel, child) {
                final diaries = diaryViewModel.getDiariesByDate(
                  selectedDate,
                  isUserDiary: widget.userId != null,
                );
                final myDiary = diaries.isNotEmpty ? diaries.first : null;
                return SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: ScreenUtil().setWidth(22.0)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: ScreenUtil().setHeight(21.0)),
                        _buildUserInfoWidget(),
                        SizedBox(height: ScreenUtil().setHeight(14.0)),
                        _buildMonthChangeWidget(),
                        SizedBox(height: ScreenUtil().setHeight(14.0)),
                        _buildCalendarTypeContainerWidget(),
                        if (!showFeed) ...[
                          SizedBox(height: ScreenUtil().setHeight(18.0)),
                          (viewMonth)
                              ? MonthCalendarWidget(
                                  currentDate: currentTime,
                                  onDateSelected: onDateSelected,
                                  userId: widget.userId,
                                )
                              : WeekCalendarWidget(
                                  currentDate: currentTime,
                                  onDateSelected: onDateSelected,
                                  userId: widget.userId,
                                ),
                          SizedBox(height: ScreenUtil().setHeight(22.0)),
                          _buildPostingText(),
                          SizedBox(height: ScreenUtil().setHeight(19.0)),
                          _buildPostingWidget(),
                          SizedBox(height: ScreenUtil().setHeight(37.0)),
                          _buildDiaryText(),
                          SizedBox(height: ScreenUtil().setHeight(19.0)),
                          _buildDiaryWidget(myDiary),
                        ] else ...[
                          _buildFeedWidget(),
                        ],
                        SizedBox(height: ScreenUtil().setHeight(150.0)),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
