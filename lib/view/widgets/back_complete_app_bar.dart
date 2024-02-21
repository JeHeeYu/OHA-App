import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:oha/view/widgets/button_icon.dart';

class BackCompleteAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;

  const BackCompleteAppBar({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Padding(
        padding: EdgeInsets.only(
            left: ScreenUtil().setWidth(30.0),
            right: ScreenUtil().setWidth(22.0)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ButtonIcon(
                icon: Icons.arrow_back_ios,
                iconColor: Colors.black,
                callback: () {
                  Navigator.pop(context);
                }),
            Text(
              title,
              style: const TextStyle(
                  color: Colors.black,
                  fontFamily: "Pretendard",
                  fontWeight: FontWeight.w600,
                  fontSize: 18),
            ),
            ButtonIcon(
                icon: Icons.done, iconColor: Colors.black, callback: () {}),
          ],
        ),
      ),
      centerTitle: true,
      titleSpacing: 0,
      backgroundColor: Colors.white,
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
