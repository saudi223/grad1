// ignore_for_file: prefer_const_constructors

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ignore: must_be_immutable
class Buttons extends StatefulWidget {
  Buttons({super.key,required this.onpress,required this.image_path});
  VoidCallback? onpress;
  String image_path;
  @override
  State<Buttons> createState() => _ButtonsState();
}

class _ButtonsState extends State<Buttons> {
  @override
  Widget build(BuildContext context) {
    return
      InkWell(
          onTap: widget.onpress,
          child:
          Container(
            width: 70.w,
            height: 70.h,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.r),
                border:Border.all(width:1.w,color:Color(0xff5D6A85))
            ),
            child: Image.asset(widget.image_path),
          ));
  }
}
