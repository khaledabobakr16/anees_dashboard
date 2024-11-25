import 'package:anees_dashboard/utils/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class DeleteBooksScreen extends StatefulWidget {
  const DeleteBooksScreen({super.key});

  @override
  State<DeleteBooksScreen> createState() => _DeleteBooksScreenState();
}

class _DeleteBooksScreenState extends State<DeleteBooksScreen> {
  deleteBooks({required QueryDocumentSnapshot<Object?> bookMap}) async {
    if (FirebaseAuth.instance.currentUser!.uid == bookMap['authorid']) {
      FirebaseFirestore.instance
          .collection('books')
          .doc(bookMap['bookid'])
          .delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: cWhite,
        body: Column(
          children: [
            Center(
              child: Text("Delete Books",
                  style: GoogleFonts.poly(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: cGreen,
                    letterSpacing: 1.5,
                  )),
            ),
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('books')
                      .where('authorid',
                          isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                          child: CircularProgressIndicator(
                        color: cGreen,
                      ));
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Expanded(
                          child: Center(child: Text("No books found")));
                    }

                    var books = snapshot.data!.docs;

                    return GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10.0,
                        mainAxisSpacing: 10.0,
                        childAspectRatio: 0.6,
                      ),
                      itemCount: books.length,
                      itemBuilder: (context, index) {
                        var book = books[index];

                        return Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: cGreen4,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    height: 135.h,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      image: DecorationImage(
                                        image:
                                            NetworkImage(book['urlBookCover']),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 5.h),
                                  Center(
                                    child: Text(
                                      book['title'],
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: GoogleFonts.inter(
                                        color: cGreen,
                                        fontSize: 9.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton.filledTonal(
                              style: const ButtonStyle(
                                  backgroundColor:
                                      WidgetStatePropertyAll(cGreen4)),
                              onPressed: () {
                                deleteBooks(bookMap: book);
                              },
                              icon: Icon(
                                Icons.delete,
                                color: Colors.red,
                                size: 18.sp,
                              ),
                            )
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ));
  }
}
