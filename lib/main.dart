// ignore_for_file: unnecessary_set_literal, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:graduate/my_binding.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:graduate/welcome_screens/Page1.dart';
import 'firebase_options.dart';
import 'package:get/get.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

runApp(MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375,812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_ , child) {
        return GetMaterialApp(
          initialBinding: MyBinding(),
          debugShowCheckedModeBanner: false,
          home: child,
        );
      },
      child:Page1()
    );
  }
}
