// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ignore: must_be_immutable
class Page3 extends StatelessWidget {
  Page3({super.key,required this.onpress});

  VoidCallback? onpress;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
            children:[
              Image.asset("assets/images/Welcome Screen (3).png",fit: BoxFit.cover,width: double.infinity.w,),
              Padding(padding: EdgeInsets.only(top: 660,left: 270),child:
              MaterialButton(
                minWidth: 70,
                height: 70,
                color:Color(0xff242849),
                onPressed:onpress,
                child: Image.asset("assets/images/Vector Stroke.png"),
              )
                ,),
        Padding(padding: EdgeInsets.only(left: 30.r,top: 70.r),child:Column(
          children: [
            Text("Your doctor’s inbox, always open.",style: TextStyle(
              fontSize:30.r,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),),
            SizedBox(
              height: 15.h,
            ),
            Text("Continue your care between visits. Message your doctor directly for personalized follow-ups.",
              style: TextStyle(
                fontSize:20.r,
                fontWeight: FontWeight.w400,
                color: Colors.black38,
              ),
            )
          ],
        ) ,
        )
            ]
        )
    );
  }
}
