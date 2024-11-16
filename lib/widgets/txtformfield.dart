import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/colors.dart';

class Txtformfield extends StatelessWidget {
  const Txtformfield({
    super.key,
    this.text,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.onPressed,
    this.validator,
    this.controller,
    this.readOnly = false,
    this.onChanged,
    this.maxLines=1,
  });

  final String? text;
  final IconData? suffixIcon;
  final IconData? prefixIcon;
  final bool? obscureText;
  final TextInputType? keyboardType;
  final void Function()? onPressed;
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final bool readOnly;
  final void Function(String)? onChanged;
  final int? maxLines;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      readOnly: readOnly,
      validator: validator,
      obscureText: obscureText!,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: GoogleFonts.inter(
          color: cGreen, fontSize: 13.sp, fontWeight: FontWeight.w400),
      decoration: InputDecoration(
        errorMaxLines: 999,
        hintText: text!,
        labelStyle: GoogleFonts.inter(
            color: cGrey, fontSize: 13.sp, fontWeight: FontWeight.w400),
        prefixIcon: prefixIcon == null ? null : Icon(prefixIcon, color: cGrey),
        suffixIcon: suffixIcon == null
            ? null
            : IconButton(
                onPressed: onPressed, icon: Icon(suffixIcon, color: cGrey)),
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
    );
  }
}
