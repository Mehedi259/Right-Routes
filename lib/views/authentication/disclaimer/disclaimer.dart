import 'package:flutter/material.dart';
import 'package:right_routes/utils/responsive_ext.dart';
import 'package:get/get.dart';
import 'package:right_routes/utils/colors.dart';
import 'package:flutter_svg/svg.dart';

class DisclaimerModal extends StatelessWidget {
  const DisclaimerModal({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Material(
        color: AppColors.darkGray,

        // Fullscreen Grey Overlay
        child: Stack(
          children: [
            SizedBox(height: context.h(80)),

            Positioned(
              right: context.w(12),
              top: context.h(40),
              child: GestureDetector(
                onTap: () => Get.back(),
                child: IconButton(
                  padding: EdgeInsets.zero, // removes extra padding
                  onPressed: () => Get.back(),

                  icon: SvgPicture.asset(
                    "assets/icons/Close-X-Circle.svg",
                    width: context.w(30),
                    height: context.h(30),
                  ),
                ),
              ),
            ),

            /// FOREGROUND CONTENT (LEFT SIDE)
            Positioned(
              left: context.w(0),
              right: context.w(0),
              top: context.h(72),
              bottom: context.h(0),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: context.w(15)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Title
                    Text(
                      "Disclaimer",
                      style: TextStyle(
                        fontSize: context.sp(21),
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w700,
                        height: context.h(1.17),
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: context.h(10)),

                    /// Divider
                    Divider(thickness: 1, color: AppColors.dividerColor),

                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: context.h(12)),

                            /// Static Terms Content (Pixel-Perfect)
                            RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Lato',
                                  height: 1.4,
                                ),
                                children: [
                                  TextSpan(
                                      text: "Right Route™ Legal Disclaimer\n\n",
                                      style: TextStyle(
                                          color: AppColors.orange,
                                          fontWeight: FontWeight.bold,
                                          fontSize: context.sp(19))),
                                  TextSpan(
                                      text: "Last updated: 5/23/2026\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "This disclaimer applies to all visitors to this website and to all users of the Right Route platform and related services (collectively, the “Services”) provided by Leavitt & Davis LLC (“L&D,” “we,” “us,” or “our”). By accessing this website or using the Services, you acknowledge that you have read, understood, and agree to the terms of this disclaimer. If you do not agree, do not access this website or use the Services. This disclaimer supplements and is incorporated into the Right Route Terms of Service and Privacy Policy. In the event of any conflict between this disclaimer and the Terms of Service, the Terms of Service govern.\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "1. Decision-Support Tool — Not a Compliance Guarantee\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: context.sp(19))),
                                  TextSpan(
                                      text:
                                          "Right Route is a software platform designed to assist carriers, trucking companies, brokers, and dispatchers in planning routes for oversized and overweight load moves. The route plans, clearance analyses, permit checklists, height and weight recommendations, bridge assessments, and all other outputs generated by the Services (collectively, “Route Outputs”) are decision-support tools only.\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "Route Outputs do not constitute:\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "•  A guarantee that any proposed route is safe, physically passable, or legally compliant;\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "•  A legal opinion or engineering assessment regarding route suitability;\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "•  A substitute for obtaining required oversize/overweight permits from applicable state and local authorities;\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "•  A substitute for compliance with applicable federal regulations, including vehicle weight limitations under 23 U.S.C. § 127 and Federal Highway Administration routing requirements under 23 C.F.R. Part 658; or\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "•  A substitute for compliance with applicable state oversize/overweight statutes, permitting requirements, and escort or pilot vehicle requirements.\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "You remain solely responsible for independently verifying all Route Outputs, obtaining all required permits, and making all final routing and operational decisions before commencing any move.\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "2. Third-Party Data — Accuracy Not Guaranteed\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: context.sp(19))),
                                  TextSpan(
                                      text:
                                          "The Services incorporate data sourced from third parties, including state departments of transportation, the Federal Highway Administration, bridge inspection and rating databases, GIS mapping providers, weather services, and other external sources (“Third-Party Data”). L&D does not independently verify, warrant, or guarantee the accuracy, completeness, timeliness, or fitness for any particular purpose of Third- Party Data.\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "Third-Party Data is subject to change without notice. Bridge ratings, clearance measurements, road restriction data, permit route designations, and other operational data may not reflect current physical or legal conditions at the time you use the Services. Road construction, emergency restrictions, seasonal closures, and inspection updates may not be captured in the data available to the Services.\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "You must independently verify all bridge clearances, weight limits, road restrictions, and permit conditions against current information from applicable state and local authorities before commencing any move.\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "3. Carrier and Operator Responsibility\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: context.sp(19))),
                                  TextSpan(
                                      text:
                                          "The carrier, trucking company, broker, dispatcher, or other person or entity using the Services to plan or coordinate a move (“Operator”) bears sole responsibility for:\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "•  Verifying that the proposed route complies with all applicable federal, state, and local laws and regulations governing the movement of oversized and overweight loads;\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "•  Obtaining all required oversize/overweight permits from applicable jurisdictions before commencing any move;\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "•  Ensuring compliance with all applicable escort and pilot vehicle requirements;\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "•  Maintaining all required insurance coverages, including minimum liability coverage required by federal law (49 C.F.R. § 387.9) and applicable state law;\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "•  Verifying actual physical clearances, road conditions, and bridge conditions along the proposed route before and during the move; and\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "•  Complying with all applicable Federal Motor Carrier Safety Regulations (49 C.F.R. Parts 382–399) and any other applicable law.\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "Right Route is a planning aid. The Operator, not L&D, is responsible for the safety and legality of every move.\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text: "4. Limitation of Liability\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: context.sp(19))),
                                  TextSpan(
                                      text:
                                          "L&D and its affiliates, directors, officers, employees, agents, and subcontractors shall not be liable for any loss, damage, injury, death, property damage, regulatory fine or penalty, permit violation, or other harm arising out of or in connection with:\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "•  Any Route Output generated by the Services, including any routing recommendation, clearance analysis, or permit checklist;\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "•  Any inaccuracy, incompleteness, or untimeliness in Third-Party Data incorporated into the Services;\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "•  Any failure by an Operator to independently verify Route Outputs or comply with applicable law;\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "•  Any accident, incident, bridge strike, overhead contact, load shift, or other event occurring in connection with a move planned or coordinated using the Services; or\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "•  Any interruption, unavailability, or error in the Services.\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "TO THE FULLEST EXTENT PERMITTED BY APPLICABLE LAW, L&D’S TOTAL LIABILITY ARISING OUT OF OR IN CONNECTION WITH THIS DISCLAIMER OR THE SERVICES SHALL NOT EXCEED THE FEES PAID BY YOU FOR THE SERVICES IN THE TWELVE (12) MONTHS PRECEDING THE CLAIM, OR ONE THOUSAND DOLLARS (\$1,000.00), WHICHEVER IS GREATER. IN NO EVENT SHALL L&D BE LIABLE FOR ANY INDIRECT, INCIDENTAL, SPECIAL, CONSEQUENTIAL, OR PUNITIVE DAMAGES.\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "Nothing in this disclaimer limits liability for fraud or willful misconduct, or as otherwise required by applicable law.\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text: "5. No Warranty\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: context.sp(19))),
                                  TextSpan(
                                      text:
                                          "THE SERVICES AND ALL ROUTE OUTPUTS ARE PROVIDED “AS IS” AND “AS AVAILABLE” WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED. L&D EXPRESSLY DISCLAIMS ALL WARRANTIES, INCLUDING WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, ACCURACY, AND NON-INFRINGEMENT. L&D DOES NOT WARRANT THAT THE SERVICES WILL BE UNINTERRUPTED, ERROR-FREE, OR THAT ROUTE OUTPUTS WILL ACCURATELY REFLECT CURRENT ROAD CONDITIONS, BRIDGE RATINGS, PERMIT REQUIREMENTS, OR LEGAL RESTRICTIONS IN ANY JURISDICTION.\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text: "6. Governing Terms\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: context.sp(19))),
                                  TextSpan(
                                      text:
                                          "This disclaimer is governed by the laws of the State of North Dakota. Your access to and use of the Services is subject to the Right Route Terms of Service and Privacy Policy, which are incorporated herein by reference. In the event of any conflict between this disclaimer and the Terms of Service, the Terms of Service govern.\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "Questions about this disclaimer may be directed to:\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text: "Leavitt & Davis LLC\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text: "7909 Lost River Road\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text: "Horace, ND 58047\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text: "legal@getrightroute.app\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                ],
                              ),
                            ),

                            SizedBox(height: context.h(40)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
