import 'package:anees_dashboard/screens/home.dart';

import 'package:anees_dashboard/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../utils/colors.dart';
import '../../utils/image_util.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  @override
  Widget build(BuildContext context) {
    handlrData(context);
    return Stack(
      children: [
        Scaffold(
          backgroundColor: cGreen,
          body: Center(
              child: ImageAsset(
            imagePath: "assets/images/Anees.png",
            width: 150.w,
          )),
        ),
        Positioned(
          top: 120.h,
          right: 40.w,
          child: SvgPicture.asset(
            'assets/images/Ellipse-16.svg',
            fit: BoxFit.fill,
            height: 60.h,
          ),
        ),
        Positioned(
          top: -10.h,
          left: 0.w,
          child: SvgPicture.asset(
            'assets/images/Ellipse-15.svg',
            fit: BoxFit.fill,
            height: 200.h,
          ),
        ),
        Positioned(
          bottom: 40.h,
          left: 40.w,
          child: SvgPicture.asset(
            'assets/images/Ellipse-14.svg',
            fit: BoxFit.fill,
            height: 60.h,
          ),
        ),
        Positioned(
          bottom: -10.h,
          right: 0.w,
          child: SvgPicture.asset(
            'assets/images/Ellipse-13.svg',
            fit: BoxFit.fill,
            height: 200.h,
          ),
        ),
      ],
    );
  }

  Future<void> handlrData(BuildContext context) async {
    await Future.delayed(const Duration(seconds: 5));
    User? user =
        FirebaseAuth.instance.currentUser; 
    if (user != null) {
    
      Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(
            builder: (context) =>
                const Home()),
      );
    } else {
     
      Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(
            builder: (context) =>
                const LoginScreen()), 
      );
    }
  }
}
