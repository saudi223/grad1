// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, unnecessary_set_literal

import 'package:flutter/gestures.dart';
import'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:graduate/screens/patient_home.dart';
import 'package:graduate/screens/sign_in.dart';
import 'package:graduate/welcome_screens/pages.dart';
import 'package:graduate/widgets/custom_button.dart';
import 'package:firebase_auth/firebase_auth.dart';


class Page1 extends StatelessWidget {
  const Page1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body:
        Stack(
          children: [
            Image.asset("assets/images/Welcome Screen.png",fit: BoxFit.cover,width: double.infinity.w),
            Padding(
              padding: EdgeInsets.only(left: 110.sp, top: 600.sp),
              child:CustomButton(the_text: "Get Started", on_tap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>StreamBuilder(
                  stream: FirebaseAuth.instance.authStateChanges(),
                  builder: (context,snapshot){
                    //user is logged in
                    if(snapshot.hasData){
                      return PatientHome();
                    }else{
                      return Pages();
                    }
                  },
                ),));
              }, width: 150.w, height: 55.h,),),
            Padding(padding: EdgeInsets.only(left: 80.sp,top: 700.sp),child:
            Text.rich(TextSpan(
                children: [
                  TextSpan(text: "Already have an account? ",style: TextStyle(
                      color: Colors.black
                  )),
                  TextSpan(text: "Sign in",style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
                  ),
                      recognizer: TapGestureRecognizer()..onTap = () =>{
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>StreamBuilder(
                          stream: FirebaseAuth.instance.authStateChanges(),
                          builder: (context,snapshot){
                            //user is logged in
                            if(snapshot.hasData){
                              return PatientHome();
                            }else{
                              return SignIn();
                            }
                          },
                        ),))
                      }
                  ),
                ]
            ))
              ,)

          ],
        )

    );
  }
}