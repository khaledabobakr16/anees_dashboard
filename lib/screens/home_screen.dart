import 'dart:developer';
import 'dart:io';

import 'package:anees_dashboard/screens/login_screen.dart';
import 'package:anees_dashboard/utils/colors.dart';
import 'package:anees_dashboard/utils/image_util.dart';
import 'package:anees_dashboard/widgets/txtformfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  bool btnIsLoading = false;
  DateTime? _selectedDate;
  String? _selectedCity;
  String? _selectedRegion;

  TextEditingController institutionName = TextEditingController();
  TextEditingController eventTitle = TextEditingController();
  TextEditingController eventDetails = TextEditingController();
  TextEditingController langauge = TextEditingController();
  TextEditingController address = TextEditingController();
  File? pickedImage;
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: cGreen,
            colorScheme: const ColorScheme.light(
              primary: cGreen,
              onSurface: Colors.black,
            ),
            buttonTheme: const ButtonThemeData(
              textTheme: ButtonTextTheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  final List<String> _cities = [
    "Riyadh",
    "Jeddah",
    "Dammam",
    "Mecca",
    "Medina"
  ];

  final Map<String, List<String>> _regions = {
    "Riyadh": ["Al Olaya", "Al Malaz", "Al Murabba"],
    "Jeddah": ["Al Hamra", "Al Rawdah", "Al Shate'a"],
    "Dammam": ["Al Faisaliah", "Al Shati Al Gharbi", "Al Mazrouia"],
    "Mecca": ["Al Aziziyah", "Al Mansoor", "Al Shoqiyah"],
    "Medina": ["Al Uyun", "Al Khalidiyah", "Al Qiblatayn"],
  };

  Future<void> sendEvent({
    String? city,
    String? region,
    String? institutionName,
    String? eventTitle,
    String? eventDetails,
    String? eventDate,
    String? langauge,
    String? address,
  }) async {
    setState(() {
      btnIsLoading = true;
    });
    try {
      final notificationId = const Uuid().v4();

      final usersQuery = await FirebaseFirestore.instance
          .collection("users")
          .where("city", isEqualTo: city)
          .where("region", isEqualTo: region)
          .get();
      if (usersQuery.docs.isNotEmpty) {
        final uuid = const Uuid().v4();
        String? imageUrl = '';
        if (pickedImage != null) {
          final rref = FirebaseStorage.instance
              .ref()
              .child('eventsImages')
              .child('${uuid}jpg');
          await rref.putFile(pickedImage!);
          imageUrl = await rref.getDownloadURL();
        }
        for (var userDoc in usersQuery.docs) {
          final userId = userDoc.id;

          await FirebaseFirestore.instance
              .collection("eventsNotifications")
              .doc(userId)
              .collection("notifications")
              .doc(notificationId)
              .set({
            'institutionName': institutionName,
            'institutionImage': imageUrl,
            'eventTitle': eventTitle,
            'eventDetails': eventDetails,
            'eventDate': eventDate,
            'notifiactionTitle': "is holding a new event",
            'date': Timestamp.now(),
            'newNotification': true,
            'notificationId': notificationId,
            'city': city,
            'region': region,
            'langauge': langauge,
            'address': address,
          });
        }
        setState(() {
          btnIsLoading = false;
        });
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: cGreen,
            content: Text(
              'Sent successfully',
              style: GoogleFonts.inter(
                color: cWhite,
                fontWeight: FontWeight.bold,
                fontSize: 13.sp,
              ),
            )));
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              backgroundColor: Colors.red,
              content: Text(
                'There are no users in this area',
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
    } on Exception catch (e) {
      log(e.toString());
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cWhite,
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
                    child: Text(
                  "Add Events",
                  style: GoogleFonts.poly(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: cGreen,
                    letterSpacing: 1.5,
                  ),
                )),
                SizedBox(
                  height: 10.h,
                ),
                Text(
                  "  City",
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
                  value: _selectedCity,
                  hint: const Text("Select city"),
                  dropdownColor: cWhite,
                  style: GoogleFonts.inter(
                      color: cGreen,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w400),
                  items: _cities.map((city) {
                    return DropdownMenuItem(
                      value: city,
                      child: Text(city),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCity = value;
                      _selectedRegion = null;
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
                  "  Region",
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w500, fontSize: 13.sp),
                ),
                SizedBox(
                  height: 4.h,
                ),
                DropdownButtonFormField<String>(
                  value: _selectedRegion,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "This field must not be empty";
                    }
                    return null;
                  },
                  hint: const Text("Select region"),
                  style: GoogleFonts.inter(
                      color: cGreen,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w400),
                  dropdownColor: cWhite,
                  items: _selectedCity != null
                      ? _regions[_selectedCity]!.map((region) {
                          return DropdownMenuItem(
                            value: region,
                            child: Text(region),
                          );
                        }).toList()
                      : [],
                  onChanged: (value) {
                    setState(() {
                      _selectedRegion = value;
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
                  "  Langauge",
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w500, fontSize: 13.sp),
                ),
                SizedBox(
                  height: 4.h,
                ),
                Txtformfield(
                  controller: langauge,
                  text: "langauge",
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
                  "  Address",
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w500, fontSize: 13.sp),
                ),
                SizedBox(
                  height: 4.h,
                ),
                Txtformfield(
                  controller: address,
                  text: "Enter the event address",
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
                  "  Institution Name",
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w500, fontSize: 13.sp),
                ),
                SizedBox(
                  height: 4.h,
                ),
                Txtformfield(
                  controller: institutionName,
                  text: "Name of the institution",
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
                  "  Institution Logo",
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
                                  "select a logo",
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
                  "  Event Title",
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w500, fontSize: 13.sp),
                ),
                SizedBox(
                  height: 4.h,
                ),
                Txtformfield(
                  controller: eventTitle,
                  text: "Enter an appropriate title for the event",
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
                  "  Event Details",
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w500, fontSize: 13.sp),
                ),
                SizedBox(
                  height: 4.h,
                ),
                TextFormField(
                  controller: eventDetails,
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
                    hintText: "Enter event details...",
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
                Text(
                  "  Event Date",
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w500, fontSize: 13.sp),
                ),
                SizedBox(
                  height: 4.h,
                ),
                TextFormField(
                    readOnly: true,
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
                      hintText: "Set an event date",
                      suffixIcon: const Icon(Icons.calendar_today),
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
                    onTap: () => _selectDate(context),
                    controller: TextEditingController(
                      text: _selectedDate != null
                          ? "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}"
                          : "",
                    )),
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
                        if (pickedImage != null) {
                          sendEvent(
                            city: _selectedCity!.trim(),
                            region: _selectedRegion!.trim(),
                            institutionName: institutionName.text.trim(),
                            eventTitle: eventTitle.text.trim(),
                            eventDate: _selectedDate.toString().trim(),
                            eventDetails: eventDetails.text.trim(),
                            address: address.text.trim(),
                            langauge: langauge.text.trim(),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              backgroundColor: Colors.red,
                              content: Text(
                                'You must choose a logo',
                                style: GoogleFonts.inter(
                                  color: cWhite,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.sp,
                                ),
                              )));
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
                            "Send",
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
