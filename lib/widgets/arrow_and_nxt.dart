// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ignore: must_be_immutable
class ArrowAndNxt extends StatelessWidget {
  ArrowAndNxt({super.key, required this.the_widget, required this.on_tap});

  Widget? the_widget;
  VoidCallback? on_tap;

  @override
  Widget build(BuildContext context) {
    return MaterialButton(onPressed: on_tap,
      child: the_widget,
      color: Color(242849),
      minWidth: 30.w,
      height: 30.h,);
  }
}
