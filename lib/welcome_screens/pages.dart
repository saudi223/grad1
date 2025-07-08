// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:graduate/auth/auth_gate.dart';
import 'package:graduate/welcome_screens/Page2.dart';
import 'package:graduate/welcome_screens/Page3.dart';
import 'package:graduate/welcome_screens/Page4.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class Pages extends StatefulWidget {
  const Pages({super.key});

  @override
  State<Pages> createState() => _PagesState();
}

class _PagesState extends State<Pages> {
  final PageController _controller =PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body:Stack(
            children:[

              PageView(
                  controller:_controller,
                  children: [
                    Page2(
                      onpress: (){
                        _controller.nextPage(duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
                      },
                    ),
                    Page3(onpress: (){
                      _controller.nextPage(duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
                    },),
                    Page4(onpress: (){
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>AuthGate()));
                    }),
                  ]
              ),Padding(padding: EdgeInsets.only(top: 47,left: 40),child:Container(

                child: SmoothPageIndicator(
                  controller: _controller,
                  count: 3,
                  effect: WormEffect(
                    spacing: 0,
                    paintStyle: PaintingStyle.fill,
                    radius: 3.sp,
                    dotColor: Colors.grey,
                    dotHeight: 10.h,
                    dotWidth: 45.w,
                    type: WormType.thinUnderground,
                  ),
                ),
              ),
              ),
            ]
        )
    );
  }
}