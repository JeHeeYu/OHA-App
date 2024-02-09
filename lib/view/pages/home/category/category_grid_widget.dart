import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CategoryGridWidget extends StatelessWidget {
  final List<String> imageList;

  const CategoryGridWidget({Key? key, required this.imageList})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GridView.builder(
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: ScreenUtil().setHeight(8.0),
          crossAxisSpacing: ScreenUtil().setWidth(8.0),
          childAspectRatio: 1,
        ),
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(ScreenUtil().radius(8.0)),
            child: Image.network(imageList[index], fit: BoxFit.cover),
          );
        },
        itemCount: imageList.length,
      ),
    );
  }
}