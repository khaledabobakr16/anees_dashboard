// // ignore_for_file: duplicate_import, unused_import

import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../utils/colors.dart';
import '../utils/image_util.dart';
import '../widgets/txtformfield.dart';

class AddBook extends StatefulWidget {
  const AddBook({super.key});

  @override
  State<AddBook> createState() => _AddBookState();
}

class _AddBookState extends State<AddBook> {
  final _formKey = GlobalKey<FormState>();
  bool btnIsLoading = false;
  File? pickedImage;
  String? _selectedCategory;

  TextEditingController bookTitle = TextEditingController();
  TextEditingController numberOfPages = TextEditingController();
  TextEditingController bookWritten = TextEditingController();
  TextEditingController bookStore = TextEditingController();
  TextEditingController description = TextEditingController();
  TextEditingController authorName = TextEditingController();

  Future<void> uploadPDFToFirebase({
    required String bookTitle,
    required String numberOfPages,
    required String bookDescription,
    required String written,
    required String authorName,
    required String category,
    required String bookstoreAddress,
  }) async {
    setState(() {
      btnIsLoading = true;
    });
    try {
      final uuid = const Uuid().v4();
      String? imageUrl = '';
      if (pickedImage != null) {
        final rref = FirebaseStorage.instance
            .ref()
            .child('books/')
            .child('$uuid/${uuid}jpg');
        await rref.putFile(pickedImage!);
        imageUrl = await rref.getDownloadURL();
      }

      await FirebaseFirestore.instance.collection('books').doc(uuid).set({
        'bookid': uuid,
        'title': bookTitle,
        'description': bookDescription,
        'numOfPages': numberOfPages,
        'written': written,
        'urlBookCover': imageUrl,
        'authorid': FirebaseAuth.instance.currentUser!.uid,
        'authorName': authorName,
        'category': category,
        'bookstoreAddress': bookstoreAddress,
        'uploadDate': Timestamp.now(),
      });

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: cGreen,
          content: Text(
            'The book has been added successfully',
            style: GoogleFonts.inter(
              color: cWhite,
              fontWeight: FontWeight.bold,
              fontSize: 13.sp,
            ),
          )));
      setState(() {
        btnIsLoading = false;
      });
    } catch (e) {
      log("Error uploading file: $e");
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              'Something went wrong, please try again',
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

  final List<String> _bookCategories = [
    "Poetry",
    "Fantacy",
    "Business",
    "Detective",
    "English",
    "Arabic",
    "History",
    "Technology",
  ];
  void selectimage() async {
    var image = await ImagePicker().pickImage(source: ImageSource.gallery);
    var selectedImage = File(image!.path);
    // ignore: unnecessary_null_comparison
    if (image != null) {
      setState(() {
        pickedImage = selectedImage;
      });
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cWhite,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text("Add Books",
                      style: GoogleFonts.poly(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: cGreen,
                        letterSpacing: 1.5,
                      )),
                ),
                Text(
                  "  Book cover",
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w500, fontSize: 13.sp),
                ),
                SizedBox(
                  height: 4.h,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: selectimage,
                      child: Container(
                        height: 100.h,
                        width: 100.w,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Center(
                          child: pickedImage != null
                              ? Image.file(
                                  pickedImage!,
                                  fit: BoxFit.fill,
                                )
                              : Text(
                                  "select a cover",
                                  style: GoogleFonts.inter(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade500,
                                      fontSize: 12.sp),
                                ),
                        ),
                      ),
                    ),
                    pickedImage == null
                        ? const SizedBox.shrink()
                        : TextButton(
                            onPressed: () {
                              setState(() {
                                pickedImage = null;
                              });
                            },
                            child: Text(
                              "Delete",
                              style: GoogleFonts.inter(color: Colors.red),
                            ))
                  ],
                ),
                SizedBox(
                  height: 4.h,
                ),
                Text(
                  "  Book Title",
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w500, fontSize: 13.sp),
                ),
                SizedBox(
                  height: 4.h,
                ),
                Txtformfield(
                  controller: bookTitle,
                  text: "Enter the book title",
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "This field must not be empty";
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: 4.h,
                ),
                SizedBox(
                  height: 4.h,
                ),
                Text(
                  "  Author Name",
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w500, fontSize: 13.sp),
                ),
                SizedBox(
                  height: 4.h,
                ),
                Txtformfield(
                  controller: authorName,
                  text: "Enter the author's name",
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "This field must not be empty";
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: 4.h,
                ),
                Text(
                  "  Number of Pages",
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w500, fontSize: 13.sp),
                ),
                SizedBox(
                  height: 4.h,
                ),
                Txtformfield(
                  controller: numberOfPages,
                  text: "Enter the number of pages",
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "This field must not be empty";
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: 4.h,
                ),
                Text(
                  "  Book Written",
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w500, fontSize: 13.sp),
                ),
                SizedBox(
                  height: 4.h,
                ),
                Txtformfield(
                  controller: bookWritten,
                  text: " e.g. 1987 (Eng. 2007)",
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "This field must not be empty";
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: 4.h,
                ),
                Text(
                  "  Bookstore address",
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w500, fontSize: 13.sp),
                ),
                SizedBox(
                  height: 4.h,
                ),
                Txtformfield(
                  controller: bookStore,
                  text: " Enter the address of the bookstore",
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "This field must not be empty";
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: 4.h,
                ),
                Text(
                  "  Category",
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w500, fontSize: 13.sp),
                ),
                SizedBox(
                  height: 4.h,
                ),
                DropdownButtonFormField<String>(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "This field must not be empty";
                    }
                    return null;
                  },
                  value: _selectedCategory,
                  hint: const Text("Select a category"),
                  dropdownColor: cWhite,
                  style: GoogleFonts.inter(
                      color: cGreen,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w400),
                  items: _bookCategories.map((city) {
                    return DropdownMenuItem(
                      value: city,
                      child: Text(city),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(36.0),
                      borderSide: const BorderSide(
                        color: cGrey,
                        width: 1.5,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(36.0),
                      borderSide: const BorderSide(
                        color: cGrey,
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(36.0),
                      borderSide: const BorderSide(
                        color: cGreen,
                        width: 2.0,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 4.h,
                ),
                Text(
                  "  Description",
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w500, fontSize: 13.sp),
                ),
                SizedBox(
                  height: 4.h,
                ),
                TextFormField(
                  controller: description,
                  maxLines: 10,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "This field must not be empty";
                    }
                    return null;
                  },
                  style: GoogleFonts.inter(
                      color: cGreen,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w400),
                  decoration: InputDecoration(
                    errorMaxLines: 999,
                    hintText: "Enter the book description...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide: const BorderSide(
                        color: cGrey,
                        width: 1.5,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide: const BorderSide(
                        color: cGrey,
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide: const BorderSide(
                        color: cGreen,
                        width: 2.0,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 4.h,
                ),
                SizedBox(
                  height: 10.h,
                ),
                Center(
                    child: Container(
                  height: 40.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: cGreen,
                    borderRadius: BorderRadius.circular(36.0),
                  ),
                  child: TextButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        if (pickedImage == null) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              backgroundColor: Colors.red,
                              content: Text(
                                'You must choose a book cover',
                                style: GoogleFonts.inter(
                                  color: cWhite,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.sp,
                                ),
                              )));
                        } else {
                          uploadPDFToFirebase(
                            bookTitle: bookTitle.text.trim(),
                            authorName: authorName.text.trim(),
                            bookDescription: description.text.trim(),
                            category: _selectedCategory!.trim(),
                            numberOfPages: numberOfPages.text.trim(),
                            bookstoreAddress: bookStore.text.trim(),
                            written: bookWritten.text.trim(),
                          );
                        }
                      }
                    },
                    child: btnIsLoading
                        ? ImageAsset(
                            imagePath: "assets/images/loading.gif",
                            height: 50.h,
                            width: 50.w,
                          )
                        : Text(
                            "Add Book",
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
        ),
      ),
    );
  }
}
