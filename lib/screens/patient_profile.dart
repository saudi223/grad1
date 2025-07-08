// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:graduate/screens/patient_home.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:graduate/widgets/Custom_button.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;

class PatientProfile extends StatefulWidget {
  PatientProfile({super.key});

  @override
  State<PatientProfile> createState() => _PatientProfileState();
}

class _PatientProfileState extends State<PatientProfile> {
  GlobalKey<FormState> _formkey = GlobalKey();
  final nameController = TextEditingController();
  final bloodTypeController = TextEditingController();
  final weightController = TextEditingController();
  final heightController = TextEditingController();
  final phone1Controller = TextEditingController();
  final phone2Controller = TextEditingController();
  final cameraIpController = TextEditingController();

  File? _imageFile;
  final picker = ImagePicker();
  bool _isSaving = false;

  Future<void> pickImage() async {
    try {
      final source = await showModalBottomSheet<ImageSource>(
        context: context,
        builder: (context) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Take Photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Choose from Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      );

      if (source == null) return;

      final permission = source == ImageSource.camera
          ? Permission.camera
          : Permission.photos;

      final status = await permission.request();
      if (!status.isGranted) {
        throw Exception('Permission denied');
      }

      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } on Exception catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<String?> uploadProfileImage(File imageFile) async {
    try {
      String fileName =
          'profile_${DateTime.now().millisecondsSinceEpoch}${path.extension(imageFile.path)}';

      Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child(fileName);

      await storageRef.putFile(imageFile);
      return await storageRef.getDownloadURL();
    } catch (e) {
      print('Failed to upload image: $e');
      return null;
    }
  }

  Future<void> saveProfile(BuildContext context) async {
    if (!_formkey.currentState!.validate()) return;

    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    try {
      String? imageUrl;

      if (_imageFile != null) {
        imageUrl = await uploadProfileImage(_imageFile!);
      }

      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception("User not authenticated");
      }

      final profileData = {
        'name': nameController.text.trim(),
        'blood_type': bloodTypeController.text.trim(),
        'weight': weightController.text.trim(),
        'height': heightController.text.trim(),
        'phone_number1': phone1Controller.text.trim(),
        'phone_number2': phone2Controller.text.trim(),
        'camera_ip': cameraIpController.text.trim(),
        'updated_at': FieldValue.serverTimestamp(),
        'created_at': FieldValue.serverTimestamp(),
      };

      if (imageUrl != null) {
        profileData['profile_image'] = imageUrl;
      }

      // Save to Firestore and wait for completion
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .set(profileData, SetOptions(merge: true));

      // Verify the data was saved
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (doc.exists) {
        Navigator.pop(context); // Close loading dialog
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => PatientHome()),
        );
      } else {
        throw Exception("Failed to save user data");
      }
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving profile: ${e.toString()}")),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity.w,
        height: double.infinity.h,
        child: SingleChildScrollView(
          child: Form(
            key: _formkey,
            child: Stack(
              children: [
                Container(
                  width: double.infinity.w,
                  height: 190.h,
                  decoration: BoxDecoration(
                    color: Color(0xff242E49),
                    borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(15.r),
                        bottomLeft: Radius.circular(15.r)),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 150.r, top: 120.r),
                  child: GestureDetector(
                    onTap: pickImage,
                    child: CircleAvatar(
                      radius: 50.r,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: _imageFile != null
                          ? FileImage(_imageFile!)
                          : null,
                      child: _imageFile == null
                          ? Icon(Icons.camera_alt,
                          size: 40.r, color: Colors.grey[600])
                          : null,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      top: 240.r, left: 30.r, right: 25.r),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: nameController,
                        keyboardType: TextInputType.name,
                        textDirection: TextDirection.ltr,
                        decoration: InputDecoration(
                          labelText: "Name",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.r)),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(
                        height: 25.h,
                      ),
                      TextFormField(
                        keyboardType: TextInputType.text,
                        textDirection: TextDirection.ltr,
                        controller: bloodTypeController,
                        decoration: InputDecoration(
                          labelText: "Blood Type",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.r)),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your blood type';
                          }
                          return null;
                        },
                      ),
                      SizedBox(
                        height: 25.h,
                      ),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        textDirection: TextDirection.ltr,
                        controller: weightController,
                        decoration: InputDecoration(
                          labelText: "Weight",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.r)),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your weight';
                          }
                          return null;
                        },
                      ),
                      SizedBox(
                        height: 25.h,
                      ),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        textDirection: TextDirection.ltr,
                        controller: heightController,
                        decoration: InputDecoration(
                          labelText: "Height",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.r)),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your height';
                          }
                          return null;
                        },
                      ),
                      SizedBox(
                        height: 25.h,
                      ),
                      TextFormField(
                        keyboardType: TextInputType.phone,
                        textDirection: TextDirection.ltr,
                        controller: phone1Controller,
                        decoration: InputDecoration(
                          labelText: "Phone Num1",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.r)),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a phone number';
                          }
                          return null;
                        },
                      ),
                      SizedBox(
                        height: 25.h,
                      ),
                      TextFormField(
                        keyboardType: TextInputType.phone,
                        textDirection: TextDirection.ltr,
                        controller: phone2Controller,
                        decoration: InputDecoration(
                          labelText: "Phone Num2",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.r)),
                        ),
                      ),
                      SizedBox(
                        height: 25.h,
                      ),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        textDirection: TextDirection.ltr,
                        controller: cameraIpController,
                        decoration: InputDecoration(
                          labelText: "CAM IP",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.r)),
                        ),
                      ),
                      SizedBox(
                        height: 25.h,
                      ),
                      CustomButton(
                        on_tap: () async {
                          if (_formkey.currentState!.validate()) {
                            await saveProfile(context);
                          }
                        },
                        the_text: "Continue",
                        width: 340.w,
                        height: 70.h,
                      ),
                      SizedBox(
                        height: 25.h,
                      ),
                    ],
                  ),
                ),
                Padding(padding: EdgeInsets.only(left: 100.r,top: 50.r),child:
                Text("Doctor_Profile",style: TextStyle(
                    fontSize: 30.r,color: Colors.white
                ),))
              ],
            ),
          ),
        ),
      ),
    );
  }
}