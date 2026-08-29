import 'package:flutter/material.dart';
import 'package:right_routes/utils/colors.dart';
import 'package:right_routes/utils/responsive_ext.dart';

class EmailInputField extends StatefulWidget {
  final TextEditingController controller;
  final String? hintText;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;

  const EmailInputField({
    super.key,
    required this.controller,
    this.hintText = "Email",
    this.onChanged,
    this.validator,
  });

  @override
  State<EmailInputField> createState() => _EmailInputFieldState();
}

class _EmailInputFieldState extends State<EmailInputField> {
  @override
  void dispose() {
    // Note: Controller dispose parent widget-এ করতে হবে
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: context.h(57), // 🔥 shortestSide based — portrait/landscape same
      decoration: BoxDecoration(
        color: AppColors.medGray,
        borderRadius: BorderRadius.circular(context.r(10)),
      ),
      child: TextFormField(
        controller: widget.controller,
        style: TextStyle(
          color: Colors.white,
          fontSize: context.sp(16),
          fontFamily: 'Lato',
          fontWeight: FontWeight.w400,
          letterSpacing: 0.2,
        ),
        cursorColor: const Color(0xFFFFFFFF),
        cursorHeight: context.h(22),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(
            color: const Color(0xFFBFBFBF),
            fontSize: context.sp(16),
            fontFamily: 'Lato',
            fontWeight: FontWeight.w400,
          ),
          isDense: true,
          contentPadding: EdgeInsets.symmetric(
            vertical: context.h(14),
            horizontal: context.w(15),
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
        keyboardType: TextInputType.emailAddress,
        onChanged: widget.onChanged,
        validator: widget.validator,
      ),
    );
  }
}
