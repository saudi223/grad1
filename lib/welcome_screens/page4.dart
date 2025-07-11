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
                ,),
              Padding(padding: EdgeInsets.only(left: 20.r,top: 350.r),
              child: Image.asset("assets/images/R.png",width: 320.w,height: 250.h,),
              ),
        Padding(padding: EdgeInsets.only(left: 30.r,top: 70.r),child:Column(
          children: [
            Text("Stay informed, stay healthy",style: TextStyle(
              fontSize:30.r,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),),
            SizedBox(
              height: 15.h,
            ),
            Text("Your daily dose of medical updates and doctor insights—all in one place.",
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
