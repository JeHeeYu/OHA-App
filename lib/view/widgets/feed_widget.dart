import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:oha/view/widgets/button_image.dart';
import 'package:video_player/video_player.dart';

import '../../statics/Colors.dart';
import '../../statics/images.dart';
import '../../statics/strings.dart';
import 'button_icon.dart';
import 'comment_sheet.dart';
import '../../../../models/upload/upload_get_model.dart';

class FeedWidget extends StatefulWidget {
  final UploadData uploadData;
  final VoidCallback? onLikePressed;
  final VoidCallback? onMorePressed;
  final VoidCallback? onProfilePressed;

  const FeedWidget({
    Key? key,
    required this.uploadData,
    this.onLikePressed,
    this.onMorePressed,
    this.onProfilePressed,
  }) : super(key: key);

  @override
  State<FeedWidget> createState() => _FeedWidgetState();
}

class _FeedWidgetState extends State<FeedWidget> {
  late int _likesCount;
  late bool _isLike;
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    _likesCount = widget.uploadData.likeCount;
    _isLike = widget.uploadData.isLike;

    if (widget.uploadData.mediaType == '동영상' &&
        widget.uploadData.files.isNotEmpty) {
      _videoController =
          VideoPlayerController.network(widget.uploadData.files[0].url)
            ..initialize().then((_) {
              setState(() {});
            })
            ..setLooping(true)
            ..play();
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  void _toggleLike() {
    setState(() {
      _isLike = !_isLike;
      _likesCount += _isLike ? 1 : -1;
    });
    if (widget.onLikePressed != null) {
      widget.onLikePressed!();
    }
  }

  TextSpan _buildTextSpan(String text) {
    return TextSpan(
      text: text,
    );
  }

  TextPainter _getTextPainter(TextSpan textSpan) {
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    return textPainter;
  }

  String formatDate(String dateTime) {
    String datePart = dateTime.substring(0, 10);
    List<String> parts = datePart.split('-');
    String year = parts[0];
    String month = parts[1];
    String day = parts[2];

    return '$year년 $month월 $day일';
  }

  Widget _buildHashTagWidget(String text) {
    final textSpan = _buildTextSpan(text);
    final textPainter = _getTextPainter(textSpan);

    return Container(
      height: ScreenUtil().setHeight(20.0),
      width: ScreenUtil()
          .setWidth(textPainter.width * 1 + ScreenUtil().setWidth(16.0)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ScreenUtil().radius(5.0)),
        color: const Color(UserColors.tint01),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: "Pretendard",
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(UserColors.primaryColor),
        ),
      ),
    );
  }

  Widget _buildProfileWidget() {
    bool isProfileUrlValid = widget.uploadData.profileUrl.isNotEmpty;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(22.0)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: ScreenUtil().setWidth(28.0),
                height: ScreenUtil().setHeight(28.0),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: GestureDetector(
                  onTap: widget.onProfilePressed,
                  child: ClipOval(
                    child: isProfileUrlValid
                        ? Image.network(widget.uploadData.profileUrl,
                            fit: BoxFit.cover)
                        : SvgPicture.asset(Images.defaultProfile),
                  ),
                ),
              ),
              SizedBox(width: ScreenUtil().setWidth(8.0)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.uploadData.userName,
                    style: const TextStyle(
                      fontFamily: "Pretendard",
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(UserColors.ui01),
                    ),
                  ),
                  Text(
                      "${formatDate(widget.uploadData.regDtm)} ${widget.uploadData.locationDetail}",
                      style: const TextStyle(
                        fontFamily: "Pretendard",
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Color(UserColors.ui04),
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1),
                ],
              ),
            ],
          ),
          ButtonIcon(
            icon: Icons.more_horiz,
            iconColor: const Color(UserColors.ui06),
            callback: widget.onMorePressed ?? () {},
          ),
        ],
      ),
    );
  }

  Widget _buildLikesWidget() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(22.0)),
      child: Row(
        children: [
          ButtonIcon(
            icon: _isLike ? Icons.favorite : Icons.favorite_border,
            iconColor: _isLike ? Colors.red : const Color(UserColors.ui01),
            callback: () => _toggleLike(),
          ),
          Text(
            ' ${_likesCount}${Strings.likes}',
            style: const TextStyle(
              fontFamily: "Pretendard",
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(UserColors.ui01),
            ),
          ),
          SizedBox(width: ScreenUtil().setWidth(8.0)),
          ButtonImage(
            imagePath: Images.comment,
            callback: () => _showCommentSheet(context),
          ),
          Text(
            ' ${widget.uploadData.commentCount}${Strings.comments}',
            style: const TextStyle(
              fontFamily: "Pretendard",
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(UserColors.ui01),
            ),
          ),
        ],
      ),
    );
  }

  void _showCommentSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.9,
        child: CommentSheet(postId: widget.uploadData.postId),
      ),
    );
  }

  Widget _buildDescriptionTextWidget() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(22.0)),
      child: Text(
        widget.uploadData.content,
        style: const TextStyle(
          fontFamily: "Pretendard",
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Color(UserColors.ui01),
        ),
      ),
    );
  }

  Widget _buildMediaWidget() {
    if (widget.uploadData.mediaType == '사진') {
      return Image.network(
        widget.uploadData.files.isNotEmpty
            ? widget.uploadData.files[0].url
            : '',
        fit: BoxFit.cover,
        width: double.infinity,
        height: ScreenUtil().setHeight(390.0),
      );
    } else if (widget.uploadData.mediaType == '동영상' &&
        _videoController != null) {
      return _videoController!.value.isInitialized
          ? AspectRatio(
              aspectRatio: _videoController!.value.aspectRatio,
              child: VideoPlayer(_videoController!),
            )
          : Container(
              height: ScreenUtil().setHeight(390.0),
              color: Colors.black,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
    } else {
      return Container(
        height: ScreenUtil().setHeight(390.0),
        color: Colors.black,
        child: Center(
          child: Text(
            '미디어를 불러올 수 없습니다.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildProfileWidget(),
        SizedBox(height: ScreenUtil().setHeight(16.0)),
        _buildMediaWidget(),
        SizedBox(height: ScreenUtil().setHeight(12.0)),
        _buildLikesWidget(),
        SizedBox(height: ScreenUtil().setHeight(15.5)),
        _buildDescriptionTextWidget(),
        SizedBox(height: ScreenUtil().setHeight(12.0)),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: ScreenUtil().setWidth(22.0),
          ),
          child: Wrap(
            spacing: ScreenUtil().setWidth(6.0),
            runSpacing: ScreenUtil().setHeight(6.0),
            children: widget.uploadData.keywords.map((hashTag) {
              return _buildHashTagWidget(hashTag);
            }).toList(),
          ),
        ),
        SizedBox(height: ScreenUtil().setHeight(24.0)),
      ],
    );
  }
}
