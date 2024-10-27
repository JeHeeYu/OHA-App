import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:oha/view/pages/location/location_setting_page.dart';
import 'package:oha/view/widgets/button_icon.dart';
import 'package:oha/view/widgets/loading_widget.dart';
import 'package:oha/view_model/upload_view_model.dart';
import 'package:oha/view/pages/upload/add_keyword_dialog.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';

import '../../../app.dart';
import '../../../models/upload/upload_get_model.dart';
import '../../../statics/Colors.dart';
import '../../../statics/strings.dart';
import '../../../view_model/location_view_model.dart';
import '../../widgets/complete_dialog.dart';
import '../../widgets/infinity_button.dart';
import '../../widgets/location_info_dialog.dart';
import 'package:http/http.dart' as http;

class UploadWritePage extends StatefulWidget {
  final AssetEntity? selectMedia;
  final bool isEdit;
  final UploadData? uploadData;

  const UploadWritePage({
    Key? key,
    this.selectMedia,
    this.isEdit = false,
    this.uploadData,
  }) : super(key: key);

  @override
  State<UploadWritePage> createState() => _UploadWritePageState();
}

class _UploadWritePageState extends State<UploadWritePage> {
  int _categorySelectIndex = 0;
  final _textController = TextEditingController();
  late UploadViewModel _uploadViewModel;
  late LocationViewModel _locationViewModel;
  bool _isLoading = false;
  List<String> _keywordList = [];

  @override
  void initState() {
    super.initState();

    _uploadViewModel = Provider.of<UploadViewModel>(context, listen: false);
    _locationViewModel = Provider.of<LocationViewModel>(context, listen: false);

    Future.delayed(Duration.zero, () {
      _uploadViewModel.getKetwordList.clear();
      _uploadViewModel.setUploadLocation("");

      setState(() {});
    });

    if (widget.isEdit == true && widget.uploadData != null) {
      _textController.text = widget.uploadData!.content;

      _categorySelectIndex = Strings.categoryMap.entries
          .firstWhere((entry) => entry.value == widget.uploadData!.categoryCode,
              orElse: () => const MapEntry(0, "CTGR_CLOUD"))
          .key;

      String locationCode = widget.uploadData!.regionCode.toString();
      List<String> selectedKeywords = widget.uploadData!.keywords;

      _keywordList = selectedKeywords;
      _uploadViewModel.setUploadLocation(locationCode);
    }
  }

  Widget _buildCategoryWidget(int index) {
    String text = "";

    switch (index) {
      case 0:
        text = Strings.cloud;
        break;
      case 1:
        text = Strings.moon;
        break;
      case 2:
        text = Strings.rainbow;
        break;
      case 3:
        text = Strings.sunsetSunrise;
        break;
      case 4:
        text = Strings.nightSky;
        break;
      case 5:
        text = Strings.sunnySky;
        break;
      default:
        break;
    }

    final textSize = _getTextWidth(
      text: text,
      style: const TextStyle(
        fontFamily: "Pretendard",
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    );

    return GestureDetector(
      onTap: () {
        setState(() {
          _categorySelectIndex = index;
        });
      },
      child: Padding(
        padding: EdgeInsets.only(right: ScreenUtil().setWidth(8.0)),
        child: Container(
          height: ScreenUtil().setHeight(35.0),
          width: textSize.width + ScreenUtil().setWidth(35.0),
          decoration: BoxDecoration(
            color: (_categorySelectIndex == index)
                ? const Color(UserColors.primaryColor)
                : Colors.white,
            borderRadius: BorderRadius.circular(ScreenUtil().radius(22.0)),
            border: (_categorySelectIndex == index)
                ? null
                : Border.all(color: const Color(UserColors.ui08)),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              fontFamily: "Pretendard",
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: (_categorySelectIndex == index)
                  ? Colors.white
                  : const Color(UserColors.ui01),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> showKeyDialog() async {
    final result = await showDialog<List<String>>(
      context: context,
      builder: (BuildContext context) {
        return const AddKeywordDialog();
      },
    );

    if (result != null) {
      setState(() {
        _keywordList = result;
      });
    }
  }

  void getLocationInfo() async {
    Map<String, String?>? result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => const LocationSettingPage(isWrite: true)),
    );

    if (result != null) {
      String fullAddress = result['fullAddress'] ?? "";

      _uploadViewModel.setUploadLocation(fullAddress);
    } else {
      return;
    }

    showLocationInfoDialog();
  }

  void showLocationInfoDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return LocationInfoDialog();
      },
    );

    setState(() {});
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

  Widget _buildKeywordDefaultWidget() {
    String text = Strings.keywordDefault;

    return GestureDetector(
      onTap: () {
        showKeyDialog();
      },
      child: Padding(
        padding: EdgeInsets.only(right: ScreenUtil().setWidth(8.0)),
        child: Container(
          height: ScreenUtil().setHeight(35.0),
          width: ScreenUtil().setWidth(115.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(ScreenUtil().radius(22.0)),
            border: Border.all(color: const Color(UserColors.ui08)),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: "Pretendard",
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(UserColors.ui06),
            ),
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
        showKeyDialog();
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
                  _keywordList.removeAt(index);
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

  Widget _buildLocationDefaultWidget() {
    return GestureDetector(
      onTap: () async {
        getLocationInfo();
      },
      child: Container(
        height: ScreenUtil().setHeight(35.0),
        width: ScreenUtil().setWidth(105.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(ScreenUtil().radius(22.0)),
          border: Border.all(color: const Color(UserColors.ui08)),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ButtonIcon(
              icon: Icons.add,
              iconColor: const Color(UserColors.ui04),
              callback: () {},
            ),
            SizedBox(width: ScreenUtil().setWidth(5.0)),
            const Text(
              Strings.add,
              style: TextStyle(
                fontFamily: "Pretendard",
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(UserColors.ui06),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationWidget(String text) {
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
        getLocationInfo();
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
            GestureDetector(
              onTap: () {
                setState(() {
                  _uploadViewModel.setUploadLocation("");
                });
              },
              child: const Icon(Icons.cancel, color: Color(UserColors.ui07)),
            ),
          ],
        ),
      ),
    );
  }

  bool isVideo(AssetEntity? media) {
    if (media?.type == AssetType.video) {
    } else if (media?.type == AssetType.image) {}
    return media != null && media.type == AssetType.video;
  }

  Future<void> upload() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    String content = _textController.text;
    String selectCategory = Strings.categoryMap[_categorySelectIndex] ?? "";
    List<String> keyword = _keywordList;
    String selectLocationCode =
        _locationViewModel.getCodeByAddress(_uploadViewModel.getUploadLocation);

    List<String> selectedKeywords = [];
    for (int i = 0; i < min(keyword.length, 3); i++) {
      selectedKeywords.add(keyword[i]);
    }

    Map<String, dynamic> sendData = {
      "content": content,
      "categoryCode": selectCategory,
      "keywords": selectedKeywords,
      "regionCode": selectLocationCode,
      "locationDetail": _uploadViewModel.getUploadLocation,
    };

    try {
      Uint8List? thumbnailData;
      bool video = false;

      if (widget.selectMedia != null) {
        if (isVideo(widget.selectMedia)) {
          video = true;
        } else {
          video = false;
        }

        thumbnailData = await widget.selectMedia?.thumbnailData;
      }

      final result =
          await _uploadViewModel.posting(sendData, thumbnailData, video);

      if (!mounted) return;

      if (result == 201) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const App()),
        );
        showCompleteDialog();
      }
    } catch (error) {
      print('Error uploading: $error');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> edit() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    String content = _textController.text;
    String selectCategory = Strings.categoryMap[_categorySelectIndex] ?? "";
    List<String> keyword = _keywordList;

    List<String> selectedKeywords = [];
    for (int i = 0; i < min(keyword.length, 3); i++) {
      selectedKeywords.add(keyword[i]);
    }

    Map<String, dynamic> sendData = {
      Strings.postIdKey: widget.uploadData?.postId.toString(),
      Strings.contentKey: content,
      Strings.categoryCodeKey: selectCategory,
      Strings.keywordsKey: selectedKeywords,
      Strings.regionCodeKey: '1111051500',
      Strings.locationDetailKey: _uploadViewModel.getUploadLocation,
      Strings.updateItemKey: "content,keywords,regionCode"
    };

    try {
      Uint8List? thumbnailData;
      bool video = false;

      if (widget.selectMedia != null) {
        if (widget.selectMedia != null) {
          if (isVideo(widget.selectMedia)) {
            video = true;
          } else {
            video = false;
          }

          thumbnailData = await widget.selectMedia?.thumbnailData;
        }
      } else if (widget.uploadData?.files.isNotEmpty ?? false) {
        String fileUrl = widget.uploadData!.files[0].url;
        final response = await http.get(Uri.parse(fileUrl));
        if (response.statusCode == 200) {
          thumbnailData = response.bodyBytes;
        }
      }

      final result =
          await _uploadViewModel.edit(sendData, thumbnailData, video);

      if (!mounted) return;

      if (result == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const App()),
        );
        showCompleteDialog();
      }
    } catch (error) {
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void showCompleteDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return const CompleteDialog(title: Strings.uploadComplete);
      },
    );
  }

  Widget _buildPhotoArea() {
    return GestureDetector(
      onTap: () {
        return;
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(46.0)),
        child: SizedBox(
          width: double.infinity,
          height: ScreenUtil().setHeight(298.0),
          child: widget.selectMedia != null
              ? FutureBuilder<Uint8List?>(
                  future: widget.selectMedia?.thumbnailData,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done &&
                        snapshot.data != null) {
                      return Image.memory(
                        snapshot.data!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      );
                    } else {
                      return const Center(child: LoadingWidget());
                    }
                  },
                )
              : (widget.uploadData?.files.isNotEmpty ?? false)
                  ? Image.network(widget.uploadData!.files[0].url,
                      fit: BoxFit.cover)
                  : Container(),
        ),
      ),
    );
  }

  Widget _buildContentsWidget() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(22.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            Strings.write,
            style: TextStyle(
              color: Colors.black,
              fontFamily: "Pretendard",
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          SizedBox(height: ScreenUtil().setHeight(12.0)),
          SizedBox(
            height: ScreenUtil().setHeight(136.0),
            child: TextField(
              maxLines: null,
              minLines: null,
              expands: true,
              controller: _textController,
              textAlign: TextAlign.start,
              textAlignVertical: TextAlignVertical.top,
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryArea() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(22.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            Strings.category,
            style: TextStyle(
              color: Colors.black,
              fontFamily: "Pretendard",
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          SizedBox(height: ScreenUtil().setHeight(24.0)),
          SizedBox(
            height: ScreenUtil().setHeight(35.0),
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: Strings.categoryMap.length,
                itemBuilder: (BuildContext context, int index) {
                  return _buildCategoryWidget(index);
                }),
          ),
        ],
      ),
    );
  }

  Widget _buildKeywordArea() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(22.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                Strings.keyword,
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: "Pretendard",
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              Text(
                _keywordList.length.toString() + Strings.keywordCount,
                style: const TextStyle(
                  color: Colors.black,
                  fontFamily: "Pretendard",
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          SizedBox(height: ScreenUtil().setHeight(12.0)),
          (_keywordList.isEmpty)
              ? _buildKeywordDefaultWidget()
              : SizedBox(
                  height: ScreenUtil().setHeight(35.0),
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _keywordList.length,
                    separatorBuilder: (BuildContext context, int index) {
                      return SizedBox(width: ScreenUtil().setWidth(8.0));
                    },
                    itemBuilder: (BuildContext context, int index) {
                      String keyword = _keywordList[index];
                      return _buildKeywordWidget(keyword, index);
                    },
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildLocationArea() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(22.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                Strings.location,
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: "Pretendard",
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          SizedBox(height: ScreenUtil().setHeight(12.0)),
          (_uploadViewModel.getUploadLocation.isEmpty)
              ? _buildLocationDefaultWidget()
              : _buildLocationWidget(widget.uploadData?.locationDetail ??
                  _uploadViewModel.getUploadLocation),
        ],
      ),
    );
  }

  Widget _bottomButtonArea() {
    bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Container(
      width: double.infinity,
      height: isKeyboardOpen
          ? ScreenUtil().setHeight(70.0)
          : ScreenUtil().setHeight(104.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: const Color(UserColors.ui10),
          width: 1.0,
        ),
      ),
      child: Align(
        alignment: isKeyboardOpen ? Alignment.center : Alignment.topCenter,
        child: Padding(
          padding: EdgeInsets.only(
            top: isKeyboardOpen ? 0.0 : ScreenUtil().setHeight(10.0),
            left: ScreenUtil().setWidth(22.0),
            right: ScreenUtil().setWidth(22.0),
          ),
          child: InfinityButton(
            height: ScreenUtil().setHeight(50.0),
            radius: ScreenUtil().radius(8.0),
            backgroundColor: (_textController.text.isNotEmpty &&
                    _uploadViewModel.getUploadLocation.isNotEmpty)
                ? const Color(UserColors.primaryColor)
                : const Color(UserColors.ui10),
            text: Strings.upload,
            textSize: 16,
            textWeight: FontWeight.w600,
            textColor: (_textController.text.isNotEmpty &&
                    _uploadViewModel.getUploadLocation.isNotEmpty)
                ? Colors.white
                : const Color(UserColors.ui06),
            callback: (widget.isEdit) ? edit : upload,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        elevation: 0,
        titleSpacing: ScreenUtil().setWidth(22.0),
        automaticallyImplyLeading: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: const Color(UserColors.ui10),
            height: 1.0,
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              color: Colors.black,
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            const Text(
              Strings.write,
              style: TextStyle(
                color: Colors.black,
                fontFamily: "Pretendard",
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              color: Colors.black,
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const App()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: ScreenUtil().setHeight(24.0)),
                    _buildPhotoArea(),
                    SizedBox(height: ScreenUtil().setHeight(22.0)),
                    _buildContentsWidget(),
                    SizedBox(height: ScreenUtil().setHeight(49.0)),
                    _buildCategoryArea(),
                    SizedBox(height: ScreenUtil().setHeight(28.0)),
                    _buildKeywordArea(),
                    SizedBox(height: ScreenUtil().setHeight(22.0)),
                    _buildLocationArea(),
                    SizedBox(height: ScreenUtil().setHeight(25.0)),
                  ],
                ),
              ),
            ),
            _bottomButtonArea(),
          ],
        ),
      ),
    );
  }
}
