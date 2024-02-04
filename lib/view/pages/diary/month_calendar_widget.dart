import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:oha/statics/Colors.dart';
import 'package:oha/statics/images.dart';
import 'package:oha/statics/strings.dart';

class MonthCalendarWidget extends StatelessWidget {
  final DateTime currentDate;

  const MonthCalendarWidget({Key? key, required this.currentDate}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DateTime firstDayOfMonth = DateTime(currentDate.year, currentDate.month, 1);
    int firstWeekday = firstDayOfMonth.weekday;

    int daysInMonth = DateTime(currentDate.year, currentDate.month + 1, 0).day;

    final List<int> daysList =
        List<int>.generate(daysInMonth, (index) => index + 1);

    List<String> weekDays = [
      Strings.monday,
      Strings.tuesday,
      Strings.wednesday,
      Strings.thursday,
      Strings.friday,
      Strings.saturday,
      Strings.sunday
    ];

    Widget _buildDayWidget(int day, bool recorded) {
      return Column(
        children: [
          (recorded)
              ? SvgPicture.asset(Images.recordEnable)
              : SvgPicture.asset(Images.recordDisable),
          SizedBox(
            height: ScreenUtil().setHeight(4.0),
          ),
          Text(
            day.toString(),
            style: const TextStyle(
              color: Color(UserColors.ui01),
              fontFamily: "Pretendard",
              fontWeight: FontWeight.w400,
              fontSize: 13,
            ),
          ),
          SizedBox(
            height: ScreenUtil().setHeight(5.0),
          ),
        ],
      );
    }

    return Container(
      width: double.infinity,
      height: ScreenUtil().setHeight(389.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ScreenUtil().radius(10.0)),
        color: Colors.white,
        border: Border.all(color: const Color(UserColors.ui11)),
      ),
      child: Padding(
        padding: EdgeInsets.only(top: ScreenUtil().setHeight(20.0)),
        child: Column(
          children: [
            Row(
              children: weekDays
                  .map((day) => Expanded(
                        child: Center(
                          child: Text(
                            day,
                            style: const TextStyle(
                              color: Color(UserColors.ui01),
                              fontFamily: "Pretendard",
                              fontWeight: FontWeight.w400,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
            Expanded(
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7, childAspectRatio: 0.9),
                itemCount: daysList.length + firstWeekday - 1,
                itemBuilder: (context, index) {
                  if (index < firstWeekday - 1) {
                    return Container();
                  } else {
                    int day = index - firstWeekday + 2;
                    return _buildDayWidget(day, true);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}