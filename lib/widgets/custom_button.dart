// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CustomButton extends StatelessWidget {
  CustomButton({super.key, required this.on_tap,required this.the_text,required this.width,required this.height});

  String the_text;
  VoidCallback? on_tap;
  double? width,height;


  @override
  Widget build(BuildContext context) {
    return
      InkWell(
    onTap: on_tap,
      child:
      Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Color(0xff0F67FE),
        borderRadius: BorderRadius.circular(15)
      ),
        child:Center(child:Text(the_text,style: TextStyle(
          fontSize: 20,
          color: Colors.white,
          fontWeight: FontWeight.w600
        ),textAlign: TextAlign.center,)
      )
      )
    );
  }
}
