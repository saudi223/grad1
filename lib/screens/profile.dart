// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:graduate/screens/home.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:graduate/widgets/Custom_button.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;
import 'package:get/get.dart';


class Profile extends StatefulWidget {
   Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  GlobalKey<FormState>_formkey=GlobalKey();
  final nameController = TextEditingController();
  final bloodTypeController = TextEditingController();
  final weightController = TextEditingController();
  final heightController = TextEditingController();
  final phone1Controller = TextEditingController();
  final phone2Controller = TextEditingController();
  final cameraIpController = TextEditingController();

  File? _imageFile;
  final picker = ImagePicker();

  final CollectionReference users = FirebaseFirestore.instance.collection('users');

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

      // Request permission based on source
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

  Future<String> uploadProfileImage(File imageFile) async {
    try {
      // Create a unique filename
      String fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}${path.extension(imageFile.path)}';

      // Get reference to storage location
      Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child(fileName);

      // Upload the file
      await storageRef.putFile(imageFile);

      // Get the download URL
      return await storageRef.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<void> saveProfile(BuildContext context) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    try {
      String? imageUrl;

      // Only try to upload if image was selected
      if (_imageFile != null) {
        try {
          imageUrl = await uploadProfileImage(_imageFile!);
        } catch (e) {
          Navigator.pop(context); // Close loading dialog
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to upload image: ${e.toString()}")),
          );
          return; // Exit the function if image upload fails
        }
      }

      // Get current user ID
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("You must be logged in to save profile")),
        );
        return;
      }

      // Prepare profile data
      final profileData = {
        'name': nameController.text.trim(),
        'blood_type': bloodTypeController.text.trim(),
        'weight': weightController.text.trim(),
        'height': heightController.text.trim(),
        'phone_number1': phone1Controller.text.trim(),
        'phone_number2': phone2Controller.text.trim(),
        'camera_ip': cameraIpController.text.trim(),
        'updated_at': FieldValue.serverTimestamp(),
      };

      // Add image URL if available
      if (imageUrl != null) {
        profileData['profile_image'] = imageUrl;
      }

      // Save to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .set(profileData, SetOptions(merge: true));

      // Close loading dialog
      Navigator.pop(context);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Profile saved successfully!")),
      );

      // Navigate to next page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Home()),
      );

    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving profile: ${e.toString()}")),
      );

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:Container(
        width: double.infinity.w,
        height: double.infinity.h,
        child: SingleChildScrollView(
          child: Form(
            key:_formkey ,
            child: Stack(
              children: [
                Container(
                  width: double.infinity.w,
                  height: 190.h,
                  decoration: BoxDecoration(
                    color: Color(0xff242E49),
                    borderRadius: BorderRadius.only(bottomRight:Radius.circular(15.r),bottomLeft: Radius.circular(15.r)),
                  ),
                ),
                Padding(padding: EdgeInsets.only(left: 150.r,top:120.r),
                child: GestureDetector(
                    onTap: pickImage,
                    child: CircleAvatar(
                      radius: 50.r,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
                      child: _imageFile == null
                          ? Icon(Icons.camera_alt, size: 40.r, color: Colors.grey[600])
                          : null,
                    ),
                ),
                ),
                Padding(padding: EdgeInsets.only(top: 240.r,left: 30.r,right: 25.r),child:
                  Column(
                    children: [
                    TextFormField(
                    controller: nameController,
                    keyboardType: TextInputType.name,
                    textDirection: TextDirection.ltr,
                    decoration: InputDecoration(
                      labelText: "Name",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.r)
                      ),
                    ),
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
                              borderRadius: BorderRadius.circular(15.r)
                          ),
                        ),
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
                              borderRadius: BorderRadius.circular(15.r)
                          ),
                        ),
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
                              borderRadius: BorderRadius.circular(15.r)
                          ),
                        ),
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
                              borderRadius: BorderRadius.circular(15.r)
                          ),
                        ),
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
                              borderRadius: BorderRadius.circular(15.r)
                          ),
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
                              borderRadius: BorderRadius.circular(15.r)
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 25.h,
                      ),
                      CustomButton(on_tap: (){
                        if (_formkey.currentState!.validate()){
                          saveProfile(context);
                        }
                      }, the_text: "Continue", width: 340.w, height: 70.h),
                      SizedBox(
                        height: 25.h,
                      ),
                    ],
                  )
                  ,)
              ],
            ),
          ),
        ),
      )
    );
  }
}
