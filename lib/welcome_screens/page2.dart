// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// ignore: must_be_immutable
class Page2 extends StatelessWidget {
  Page2({super.key,required this.onpress});

  VoidCallback? onpress;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
            children:[
              Image.asset("assets/images/Welcome Screen (1).png",fit: BoxFit.cover,width: double.infinity.w,),
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
                  Text("Doctors checking. Patients healing.",style: TextStyle(
                    fontSize:30.r,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),),
                  SizedBox(
                    height: 15.h,
                  ),
                  Text("Your doctor checked your records. Reply to continue the conversation about your care plan",
                  style: TextStyle(
                    fontSize:20.r,
                    fontWeight: FontWeight.w400,
                    color: Colors.black38,
                  ),
                  )
                ],
              ) ,)

            ]
        )
    );
  }
}
