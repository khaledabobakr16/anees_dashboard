// ignore_for_file: prefer_final_fields

import 'package:anees_dashboard/screens/home.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:google_fonts/google_fonts.dart';

import '../utils/colors.dart';
import '../utils/image_util.dart';
import '../widgets/txtformfield.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool obscurePassword = true;
  bool btnIsLoading = false;
  TextEditingController _email = TextEditingController();
  TextEditingController _password = TextEditingController();

  Future<void> loginUser(String email, String password) async {
    setState(() {
      btnIsLoading = true;
    });
    if (email != "workro055@gmail.com") {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              'Email or password is incorrect',
              style: GoogleFonts.inter(
                color: cWhite,
                fontWeight: FontWeight.bold,
                fontSize: 13.sp,
              ),
            )),
      );
      setState(() {
        btnIsLoading = false;
      });
      return;
    }
    try {
      // ignore: unused_local_variable
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      Navigator.pushAndRemoveUntil(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(
          builder: (context) => const Home(),
        ),
        (route) => false,
      );
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              'Email or password is incorrect',
              style: GoogleFonts.inter(
                color: cWhite,
                fontWeight: FontWeight.bold,
                fontSize: 13.sp,
              ),
            )),
      );
      setState(() {
        btnIsLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: btnIsLoading,
      child: Scaffold(
        backgroundColor: cWhite,
        body: SafeArea(
            child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 60.h,
                ),
                Center(
                  child: Text(
                    "Log In",
                    style: GoogleFonts.aclonica(
                      color: cGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 30.sp,
                    ),
                  ),
                ),
                SizedBox(height: 15.h),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Text(
                    "Enter your credential to Login.",
                    style: GoogleFonts.inter(
                      color: Colors.black,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 4,
                      fontStyle: FontStyle.italic,
                      fontSize: 15.sp,
                    ),
                  ),
                ),
                SizedBox(
                  height: 10.h,
                ),
                Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "  Email",
                        style: GoogleFonts.inter(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 13.sp),
                      ),
                      SizedBox(
                        height: 4.h,
                      ),
                      Txtformfield(
                        controller: _email,
                        text: "Email address",
                        prefixIcon: Icons.email,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email cannot be empty.';
                          }
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                            return 'Enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      SizedBox(
                        height: 5.h,
                      ),
                      Text(
                        "  Password",
                        style: GoogleFonts.inter(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 13.sp),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Txtformfield(
                        controller: _password,
                        maxLines: 1,
                        text: "Enter your password",
                        prefixIcon: Icons.person,
                        suffixIcon: obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                        obscureText: obscurePassword,
                        onPressed: () {
                          if (obscurePassword) {
                            setState(() {
                              obscurePassword = false;
                            });
                          } else {
                            setState(() {
                              obscurePassword = true;
                            });
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password cannot be empty.';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 25.h),
                      Center(
                          child: Container(
                        height: 40.h,
                        width: 235.w,
                        decoration: BoxDecoration(
                          color: cGreen,
                          borderRadius: BorderRadius.circular(36.0),
                        ),
                        child: TextButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              loginUser(_email.text.trim(), _password.text);
                            }
                          },
                          child: btnIsLoading
                              ? ImageAsset(
                                  imagePath: "assets/images/loading.gif",
                                  height: 50.h,
                                  width: 50.w,
                                )
                              : Text(
                                  "Log In",
                                  style: GoogleFonts.inter(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w700,
                                      color: cWhite),
                                ),
                        ),
                      )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )),
      ),
    );
  }
}
