import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../statics/Colors.dart';
import '../../statics/strings.dart';
import 'infinity_button.dart';

class DatePicker extends StatefulWidget {
  const DatePicker({Key? key}) : super(key: key);

  @override
  DatePickerState createState() => DatePickerState();

  static Future<String?> show(BuildContext context) async {
    return await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return Align(
          alignment: Alignment.topCenter,
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: EdgeInsets.only(
                  top: ScreenUtil().setHeight(53.0),
                  left: ScreenUtil().setWidth(22.0),
                  right: ScreenUtil().setWidth(22.0)),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const DatePicker(),
            ),
          ),
        );
      },
    );
  }
}

class DatePickerState extends State<DatePicker> {
  final List<String> _dateList = [];
  late FixedExtentScrollController _scrollController;
  int _selectedIndex = 0;
  final DateTime _today = DateTime.now();

  @override
  void initState() {
    super.initState();
    _generateDateList();
    _selectedIndex = _dateList.indexOf(_formatDate(_today));
    _scrollController =
        FixedExtentScrollController(initialItem: _selectedIndex);
  }

  void _generateDateList() {
    final startDate = DateTime(_today.year - 10, _today.month, _today.day);
    final endDate = DateTime(_today.year + 10, _today.month, _today.day);

    DateTime currentDate = startDate;
    while (currentDate.isBefore(endDate) ||
        currentDate.isAtSameMomentAs(endDate)) {
      _dateList.add(_formatDate(currentDate));
      currentDate = currentDate.add(const Duration(days: 1));
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}년 ${date.month}월 ${date.day}일';
  }

  void _selectDateAndScroll(int index) {
    setState(() {
      _selectedIndex = index;
      _scrollController.animateToItem(
        _selectedIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: SizedBox(
        height: ScreenUtil().setHeight(220.0),
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: ScreenUtil().setWidth(12.0),
              vertical: ScreenUtil().setHeight(20.0)),
          child: Column(
            children: [
              SizedBox(height: ScreenUtil().setHeight(16.0)),
              Expanded(
                child: ListWheelScrollView.useDelegate(
                  controller: _scrollController,
                  itemExtent: 26,
                  onSelectedItemChanged: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  physics: const FixedExtentScrollPhysics(),
                  childDelegate: ListWheelChildBuilderDelegate(
                    builder: (context, index) {
                      if (index < 0 || index >= _dateList.length) {
                        return null;
                      }
                      final isSelected = index == _selectedIndex;
                      return GestureDetector(
                        onTap: () => _selectDateAndScroll(index),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: ScreenUtil().setWidth(10.0)),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(UserColors.ui11)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Center(
                              child: Text(
                                _dateList[index],
                                style: TextStyle(
                                  fontSize: isSelected
                                      ? ScreenUtil().setSp(20.0)
                                      : ScreenUtil().setSp(16.0),
                                  fontFamily: "Pretendard",
                                  fontWeight: FontWeight.w500,
                                  color: isSelected
                                      ? Colors.black
                                      : const Color(UserColors.ui04),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: _dateList.length,
                  ),
                ),
              ),
              SizedBox(height: ScreenUtil().setHeight(29.0)),
              InfinityButton(
                height: ScreenUtil().setHeight(50.0),
                radius: ScreenUtil().radius(8.0),
                backgroundColor: const Color(UserColors.primaryColor),
                text: Strings.complete,
                textSize: ScreenUtil().setSp(16.0),
                textWeight: FontWeight.w600,
                textColor: Colors.white,
                callback: () {
                  final selectedDate = _dateList[_selectedIndex];
                  Navigator.of(context).pop(selectedDate);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
