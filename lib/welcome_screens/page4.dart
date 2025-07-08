// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ignore: must_be_immutable
class Page4 extends StatelessWidget {
  Page4({super.key,required this.onpress});

  VoidCallback? onpress;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
            children:[
              Image.asset("assets/images/Welcome Screen (2).png",fit: BoxFit.cover,width: double.infinity.w,),
              Padding(padding: EdgeInsets.only(top: 660,left: 270),child:
              MaterialButton(
                minWidth: 70,
                height: 70,
                color:Color(0xff242849),
                onPressed:onpress,
                child: Image.asset("assets/images/Vector Stroke.png"),
              )
                ,)
            ]
        )
    );
  }
}
