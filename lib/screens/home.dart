import 'package:anees_dashboard/screens/login_screen.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/colors.dart';
import 'add_book.dart';
import 'delete_books_screen.dart';
import 'home_screen.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int? globalIndex = 0;
  List pages = [
    const HomeScreen(),
    const AddBook(),
    const DeleteBooksScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: cGreen,
        title: Text(
          "Dashboard",
          style: GoogleFonts.aclonica(
              color: cWhite, fontWeight: FontWeight.bold, fontSize: 20.sp),
        ),
        actions: [
          IconButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushAndRemoveUntil(
                  // ignore: use_build_context_synchronously
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                  (route) => false,
                );
              },
              icon: const Icon(
                Icons.logout,
                color: cWhite,
              ))
        ],
      ),
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: cWhite,
        buttonBackgroundColor: cGreen4,
        color: cGreen,
        height: 55.h,
        items: <Widget>[
          Icon(
            Icons.home,
            color: globalIndex == 0 ? Colors.black : Colors.white,
            size: 28.sp,
          ),
          Icon(
            Icons.add,
            color: globalIndex == 1 ? Colors.black : Colors.white,
            size: 28.sp,
          ),
          Icon(
            Icons.delete,
            color: globalIndex == 2 ? Colors.black : Colors.white,
            size: 28.sp,
          ),
        ],
        onTap: (index) {
          setState(() {
            globalIndex = index;
          });
        },
      ),
      body: pages[globalIndex!],
    );
  }
}
