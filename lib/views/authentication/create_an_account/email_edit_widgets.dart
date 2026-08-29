import 'package:flutter/material.dart';
import 'package:right_routes/utils/responsive_ext.dart';

class EmailEditWidgets extends StatelessWidget {
  final String email;
  final VoidCallback onEditTap;

  const EmailEditWidgets({
    super.key,
    required this.email,
    required this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // IMPORTANT FIX ✔
        mainAxisAlignment: MainAxisAlignment.start, // FIX ✔
        children: [
          /// TOP TEXT
          Text(
            "Create your account using",
            style: TextStyle(
              color: Colors.white,
              fontSize: context.sp(18),
              fontFamily: 'Lato',
              fontWeight: FontWeight.w500,
              // NO context.h — lineHeight is a multiplier
              height: 1.44,
            ),
          ),

          SizedBox(height: context.h(6)),

          /// INLINE ROW (email + edit)
          Row(
            mainAxisSize: MainAxisSize.min, // FIX ✔ keeps row tight
            children: [
              Text(
                email,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: context.sp(18),
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w900,
                  // NO context.h
                  height: 1.44,
                ),
              ),
              SizedBox(width: context.w(6)),
              GestureDetector(
                onTap: onEditTap,
                child: Text(
                  "edit",
                  style: TextStyle(
                    color: const Color(0xFF9DACF5),
                    fontSize: context.sp(18),
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w600,
                    // NO context.h
                    height: 1.44,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
