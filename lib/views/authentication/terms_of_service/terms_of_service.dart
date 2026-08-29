import 'package:flutter/material.dart';
import 'package:right_routes/utils/responsive_ext.dart';
import 'package:get/get.dart';
import 'package:right_routes/utils/colors.dart';
import 'package:flutter_svg/svg.dart';

class TermsModal extends StatelessWidget {
  const TermsModal({super.key});

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
                      "Terms of Service",
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
                                      text:
                                          "Leavitt & Davis LLC - Right Route™ Terms of Service\n\n",
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
                                      text: "Important Notice\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: context.sp(19))),
                                  TextSpan(
                                      text:
                                          "PLEASE READ THESE TERMS OF SERVICE CAREFULLY BEFORE ACCESSING OR USING THE SERVICES. THIS AGREEMENT CONTAINS IMPORTANT LIMITATIONS OF LIABILITY, INDEMNITY OBLIGATIONS, A BINDING ARBITRATION CLAUSE, AND A DECISION-SUPPORT DISCLAIMER THAT AFFECT YOUR LEGAL RIGHTS. BY ACCESSING OR USING THE SERVICES, YOU AGREE TO BE BOUND BY THIS AGREEMENT. IF YOU DO NOT AGREE, DO NOT ACCESS OR USE THE SERVICES.\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text: "1. Definitions\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: context.sp(19))),
                                  TextSpan(
                                      text:
                                          "The following capitalized terms have the meanings set forth below:\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "“Agreement” means these Terms of Service, together with any applicable order forms, schedules, or addenda, and the Right Route Privacy Policy, all of which are incorporated herein by reference.\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "“Services” means the Right Route software-as-a-service platform and related cloud services, APIs, integrations, and customer support made available by Leavitt & Davis LLC at htps://getrightroute.app, as further described in applicable documentation.\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "“Route Data” means origin, destination, waypoint, road segment, bridge clearance and rating, weight and height restriction, permit, load specification, and related operational data entered into, processed by, or generated by the Services.\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "“Personal Data” means any information relating to an identified or identifiable natural person processed through the Services.\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "“Third-Party Data” means data sourced from state departments of transportation, federal highway databases, bridge inspection records, GIS mapping providers, weather services, and other external sources integrated with the Services.\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "“Derived Data” means analytics, models, benchmarks, and other outputs generated by Leavitt & Davis LLC from Route Data, Personal Data, or Third-Party Data.\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "“User” means any carrier, trucking company, broker, dispatcher, or other person or entity who accesses or uses the Services under this Agreement, including any person granted access by you.\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "“L&D” means Leavitt & Davis LLC and its affiliates, directors, officers, employees, agents, subcontractors, successors, and assigns.\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text: "2. License and Access\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: context.sp(19))),
                                  TextSpan(
                                      text:
                                          "L&D grants you a limited, non-exclusive, non-transferable, non-sublicensable license to access and use the Services during the term of this Agreement solely for your internal business purposes in connection with planning, coordinating, and executing oversized and overweight load moves, and only in jurisdictions where your use complies with applicable law, including export control and sanctions laws.\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "This license does not include the right to: (a) copy, modify, reverse engineer, decompile, disassemble, or attempt to extract source code from the Services; (b) bypass or interfere with any security, authentication, or access control mechanism; (c) use the Services to build or train a competing product or service; (d) resell, sublicense, or otherwise provide the Services to any third party except as expressly permitted in writing by L&D; (e) access the Services through automated means except through documented APIs; or (f) use the Services in violation of applicable law or this Agreement.\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "You are responsible for all activity that occurs under your account and for maintaining the confidentiality of your login credentials. You must notify L&D immediately of any unauthorized use of your account or any other security breach.\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "3. Decision-Support Disclaimer\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: context.sp(19))),
                                  TextSpan(
                                      text:
                                          "THE SERVICES, INCLUDING ALL ROUTE PLANS, CLEARANCE ANALYSES, PERMIT CHECKLISTS, HEIGHT AND WEIGHT RECOMMENDATIONS, AND OTHER OUTPUTS, ARE DECISION-SUPPORT TOOLS ONLY. THEY DO NOT CONSTITUTE LEGAL ADVICE, ENGINEERING ANALYSIS, OR A GUARANTEE OF ROUTE SAFETY OR REGULATORY COMPLIANCE.\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "THIRD-PARTY DATA INCORPORATED INTO THE SERVICES — INCLUDING STATE DOT PERMIT DATABASES, BRIDGE RATING AND INSPECTION RECORDS, FHWA RESTRICTION DATA, AND MAPPING INFORMATION — IS PROVIDED “AS IS.” [SHORT NAME] DOES NOT INDEPENDENTLY VERIFY THE ACCURACY, COMPLETENESS, OR CURRENCY OF THIRD-PARTY DATA. BRIDGE RATINGS, CLEARANCE MEASUREMENTS, AND ROAD RESTRICTION DATA ARE SUBJECT TO CHANGE WITHOUT NOTICE.\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "YOU REMAIN SOLELY RESPONSIBLE FOR: (A) INDEPENDENTLY VERIFYING ALL ROUTE OUTPUTS AGAINST CURRENT PERMIT CONDITIONS, APPLICABLE FEDERAL AND STATE REGULATIONS (INCLUDING 23 U.S.C. § 127 (VEHICLE WEIGHT LIMITATIONS), 23 C.F.R. PART 658, AND APPLICABLE STATE OVERSIZE/OVERWEIGHT STATUTES AND REGULATIONS), AND ACTUAL ROAD AND BRIDGE CONDITIONS; (B) OBTAINING ALL REQUIRED OVERSIZE/OVERWEIGHT PERMITS FROM APPLICABLE JURISDICTIONS BEFORE COMMENCING ANY MOVE; (C) ENSURING COMPLIANCE WITH ESCORT AND PILOT VEHICLE REQUIREMENTS UNDER APPLICABLE LAW; (D) MAKING ALL FINAL ROUTING, LOAD, AND OPERATIONAL DECISIONS; AND (E) COMPLYING WITH ALL APPLICABLE FEDERAL, STATE, AND LOCAL LAWS AND REGULATIONS GOVERNING THE MOVEMENT OF OVERSIZED AND OVERWEIGHT LOADS.\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "You agree that you will not use the Services as the sole basis for any move, permit application, load clearance decision, insurance underwriting determination, or mandatory regulatory filing.\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text: "4. User Obligations\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: context.sp(19))),
                                  TextSpan(
                                      text: "4.1 Regulatory Compliance\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "You represent and warrant that: (a) you hold all licenses, permits, and authorizations required by applicable federal, state, and local law to transport oversized and overweight loads in the jurisdictions where you operate; (b) you will obtain all required oversize/overweight permits before commencing any move planned using the Services; (c) you will comply with all applicable federal motor carrier safety regulations (49 C.F.R. Parts 382–399), FHWA bridge formula requirements (23 U.S.C. § 127), and applicable state permitting and routing requirements; and (d) you will not operate a vehicle in violation of applicable weight, height, width, or length limits based solely on a route output from the Services without independent verification.\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text: "4.2 Insurance Requirements\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "As a condition of accessing and using the Services, you must maintain, at your sole cost and expense, the following insurance coverages at all times during the term of this Agreement:\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "Commercial Auto Liability: minimum limits of _______________ [MinimumLimit, e.g., \$1,000,000 per occurrence] for bodily injury and property damagearising from the operation of any vehicle used in connection with oversized oroverweight load moves planned using the Services. This minimum is in additionto, and not in lieu of, any higher minimum required by federal law (see 49 C.F.R.§ 387.9) or applicable state law.\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "Commercial General Liability: minimum limits of _______________ [MinimumLimit, e.g., \$1,000,000 per occurrence / \$2,000,000 aggregate].\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "Cargo Insurance: minimum limits of _______________ [Minimum Limit]covering the full replacement value of loads transported using routes plannedthrough the Services.\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "All policies must be issued by insurers authorized to do business in the applicable jurisdiction and rated no less than A-/VII by A.M. Best. You agree to provide [Short Name] with certificates of insurance evidencing the required coverages upon request and to name Leavitt & Davis LLC as an additional insured on the commercial auto and general liability policies where permitted by your insurer. You must notify [Short Name] promptly if any required coverage lapses, is cancelled, or is materially reduced.\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "THE FOREGOING MINIMUM INSURANCE REQUIREMENTS DO NOT LIMIT YOUR INDEMNIFICATION OBLIGATIONS UNDER SECTION 9 OF THIS AGREEMENT OR YOUR LIABILITY TO THIRD PARTIES.\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text: "4.3 Data Accuracy\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "You are responsible for the accuracy and completeness of Route Data and other information you submit to the Services. If you submit Route Data pertaining to loads or routes that are not owned by you, you represent that you have authority to submit such data and to authorize its processing by L&D.\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "5. Data Ownership and Permissions\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: context.sp(19))),
                                  TextSpan(
                                      text:
                                          "Unless otherwise agreed in writing, Route Data and Personal Data you submit to the Services remain your property. You grant L&D a non-exclusive, worldwide, royalty-free license to process, store, and use Route Data and Personal Data to: (a) provide, operate, and maintain the Services; (b) comply with applicable law; and (c) as further described in the Right Route Privacy Policy.\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "L&D owns all Derived Data and all rights in and to the Services, platform, software, algorithms, models, and documentation. You may use outputs and reports made available to you through the Services for your internal business purposes in connection with oversized load moves.\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "L&D may use Route Data in aggregated or anonymized form that does not identify you, your organization, or any individual for benchmarking, research, and product improvement purposes.\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "Each party’s obligations with respect to Personal Data are further described in the Right Route Privacy Policy, which is incorporated by reference.\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "6. Updates and Service Changes\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: context.sp(19))),
                                  TextSpan(
                                      text:
                                          "L&D may update, modify, or improve the Services (including routing algorithms, Third-Party Data feeds, and decision-support models) from time to time. You consent to automatic updates to the Services. If you fail to install required updates, your access to the Services may be suspended or terminated.\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "L&D will not materially degrade the core functionality of the Services during your current subscription term, unless required for security, legal, or technical reasons, or as the result of changes to Third-Party Data availability. L&D may discontinue specific features or Third-Party Data integrations with reasonable prior notice.\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text: "7. Payment\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: context.sp(19))),
                                  TextSpan(
                                      text:
                                          "Fees for the Services are set forth in your applicable order form or subscription plan. All fees are due in advance. Fees may be structured based on subscription tier, number of users, volume of routes processed, or other metrics as described in your order form.\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "All fees are exclusive of applicable taxes, duties, and similar government charges, which you are responsible for paying. You must dispute any invoice in writing within seven (7) days of the invoice date; after that period, the invoice is deemed accepted.\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "If any payment is declined or not received when due, L&D may, in its sole discretion, suspend access to the Services after ten (10) days’ written notice. Continued failure to pay may result in termination of this Agreement. There are no termination fees.\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text: "8. Term and Termination\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: context.sp(19))),
                                  TextSpan(
                                      text:
                                          "This Agreement continues until terminated by either party. Either party may terminate this Agreement for any reason upon written notice to the other party. Termination for non-payment or material breach by you is effective immediately upon notice.\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "Upon termination: (a) your license to access and use the Services terminates; (b) you must pay all outstanding amounts due; and (c) L&D will retain and delete your Route Data and Personal Data in accordance with the Privacy Policy and applicable law. L&D will refund any prepaid, unearned subscription fees for full calendar months following the effective date of termination; no refund will be made for any partial calendar month.\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "Sections 3 (Decision-Support Disclaimer), 4.2 (Insurance Requirements), 5 (Data Ownership), 9 (Indemnification), 10 (Limitations of Liability), 11 (Disclaimers), 12 (Dispute Resolution), and 13 (General) survive termination of this Agreement.\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text: "9. Indemnification\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: context.sp(19))),
                                  TextSpan(
                                      text: "9.1 Indemnification by User\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "You agree to indemnify, defend, and hold harmless L&D from and against any and all claims, actions, demands, losses, damages, liabilities, costs, and expenses (including reasonable attorneys’ fees) arising out of or relating to: (a) your access to or use of the Services; (b) your violation of this Agreement or applicable law, including any failure to obtain required permits or comply with federal or state oversize/overweight regulations; (c) any accident, injury, death, or property damage occurring in connection with an oversized or overweight load move where the Services were used in the planning or execution of the move; (d) your failure to independently verify route outputs before reliance; (e) Route Data or other information you submit to the Services; or (f) any claim by a third party (including a carrier, shipper, broker, insurer, or government authority) arising from your use of the Services.\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text: "9.2 Indemnification by L&D\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "L&D agrees to indemnify, defend, and hold harmless you from and against any third-party claims alleging that the Services, as provided by L&D and used in accordance with this Agreement, infringe any valid United States patent, copyright, or trade secret. This indemnification does not apply to claims arising from: (a) your modification of the Services; (b) your use of the Services in combination with products or services not provided or approved by L&D; (c) your continued use after L&D has provided a non-infringing alternative; or (d) Third-Party Data.\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text: "10. Limitations of Liability\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: context.sp(19))),
                                  TextSpan(
                                      text: "10.1 Cap on Liability\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "L&D’S TOTAL CUMULATIVE LIABILITY TO YOU ARISING OUT OF OR IN CONNECTION WITH THIS AGREEMENT OR THE SERVICES, REGARDLESS OF THE FORM OF ACTION AND WHETHER IN CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY, OR OTHERWISE, SHALL NOT EXCEED THE GREATER OF (A) THE TOTAL FEES PAID OR PAYABLE BY YOU TO [SHORT NAME] DURING THE TWELVE (12) MONTHS IMMEDIATELY PRECEDING THE EVENT GIVING RISE TO THE CLAIM, OR (B) ONE THOUSAND DOLLARS (\$1,000.00).\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "10.2 Exclusion of Consequential Damages\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "IN NO EVENT SHALL EITHER PARTY BE LIABLE TO THE OTHER FOR ANY INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, PUNITIVE, OR CONSEQUENTIAL DAMAGES, INCLUDING LOST PROFITS, LOST REVENUE, LOSS OF DATA, LOSS OF GOODWILL, BUSINESS INTERRUPTION, OR THE COST OF SUBSTITUTE SERVICES, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGES AND REGARDLESS OF WHETHER SUCH DAMAGES ARISE UNDER CONTRACT, TORT, STATUTE, OR ANY OTHER THEORY OF LIABILITY.\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "THE FOREGOING LIMITATIONS SHALL NOT APPLY TO: (A) EITHER PARTY’S INDEMNIFICATION OBLIGATIONS UNDER SECTION 9; (B) YOUR OBLIGATION TO PAY FEES; (C) DAMAGES ARISING FROM YOUR BREACH OF THE LICENSE RESTRICTIONS IN SECTION 2; OR (D) A PARTY’S FRAUD OR WILLFUL MISCONDUCT.\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text: "10.3 Essential Basis\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "THE PARTIES ACKNOWLEDGE THAT THE LIMITATIONS OF LIABILITY IN THIS SECTION 10 REFLECT A REASONABLE ALLOCATION OF RISK AND ARE AN ESSENTIAL ELEMENT OF THE BASIS OF THE BARGAIN BETWEEN THE PARTIES. L&D WOULD NOT PROVIDE THE SERVICES WITHOUT THESE LIMITATIONS.\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text: "11. Disclaimers\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: context.sp(19))),
                                  TextSpan(
                                      text:
                                          "THE SERVICES ARE PROVIDED “AS IS” AND “AS AVAILABLE.” L&D AND ITS LICENSORS AND THIRD-PARTY DATA PROVIDERS EXPRESSLY DISCLAIM ALL WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, ACCURACY, NON- INFRINGEMENT, AND ANY WARRANTY THAT THE SERVICES WILL BE UNINTERRUPTED, ERROR-FREE, OR FREE OF HARMFUL COMPONENTS. [SHORT NAME] DOES NOT WARRANT THAT ROUTE OUTPUTS ACCURATELY REFLECT CURRENT ROAD CONDITIONS, BRIDGE RATINGS, PERMIT REQUIREMENTS, OR APPLICABLE LEGAL RESTRICTIONS IN ANY JURISDICTION. YOU ASSUME ALL RISK ARISING FROM YOUR USE OF THE SERVICES AND RELIANCE ON ROUTE OUTPUTS.\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text: "12. Dispute Resolution\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: context.sp(19))),
                                  TextSpan(
                                      text: "12.1 Governing Law\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "This Agreement is governed by and construed in accordance with the laws of the State of North Dakota, without reference to its conflict of laws principles. The interpretation of this Agreement shall not be construed against the drafter.\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text: "12.2 Binding Arbitration\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "Any dispute, controversy, or claim arising out of or relating to this Agreement or the Services, including any question regarding the existence, validity, or termination of this Agreement, shall be resolved by binding arbitration administered by the American Arbitration Association (“AAA”) under its Commercial Arbitration Rules, except as provided in Section 12.4 below.\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "The arbitration shall be conducted by a single arbitrator in Fargo, North Dakota, or remotely if the parties agree. The language of the arbitration shall beEnglish. The arbitrator’s award shall be final and binding and may be entered as ajudgment in any court of competent jurisdiction. The costs of arbitration (excluding eachparty’s attorneys’ fees) shall be borne equally by the parties, except as otherwiserequired by the AAA’s fee schedule for consumer-initiated disputes, if applicable.EACH\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "PARTY WAIVES ITS RIGHT TO A JURY TRIAL WITH RESPECT TO ANYDISPUTE ARISING OUT OF OR RELATING TO THIS AGREEMENT.\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text: "12.3 Class Action Waiver\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "All disputes must be brought on an individual basis only. Neither party may bring or participate in any class action, class arbitration, consolidated proceeding, or representative action in connection with this Agreement. This class action waiver is an essential term of this Agreement; if it is found unenforceable, the entire arbitration provision shall be null and void.\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text: "12.4 Injunctive Relief\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "Notwithstanding the foregoing, either party may seek emergency injunctive or other equitable relief from a court of competent jurisdiction in North Dakota to prevent irreparable harm pending the resolution of a dispute by arbitration.\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text: "13. General\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: context.sp(19))),
                                  TextSpan(
                                      text: "13.1 Assignment\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "You may not assign or transfer this Agreement or any rights or obligations hereunder without L&D’s prior written consent. L&D may assign this Agreement, in whole or in part, without your consent in connection with a merger, acquisition, reorganization, or sale of all or substantially all of its assets. Any purported assignment in violation of this section is void.\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text: "13.2 Subcontractors\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "L&D may engage subcontractors to perform portions of the Services. [Short Name] remains responsible for subcontractors’ performance. You authorize [Short Name] to share your information with subcontractors as necessary to provide the Services, in accordance with the Privacy Policy.\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text: "13.3 Modifications\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "L&D may modify this Agreement by providing you with at least thirty (30) days’ prior written notice via email or a prominent notice within the Services. If you do not agree to the modified terms, you must notify L&D in writing within thirty (30) days and may terminate this Agreement without penalty. Your continued use of the Services after the effective date of the modified Agreement constitutes acceptance.\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text: "13.4 Severability\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "If any provision of this Agreement is held to be invalid, illegal, or unenforceable, that provision shall be modified to the minimum extent necessary to make it enforceable, or severed if modification is not possible, without affecting the validity of the remaining provisions.\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text: "13.5 Waiver\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "No waiver of any provision of this Agreement shall be effective unless in writing. A waiver of any breach shall not constitute a waiver of any subsequent breach or of the underlying obligation.\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text: "13.6 Entire Agreement\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "This Agreement, together with any applicable order forms and the Privacy Policy, constitutes the entire agreement between the parties with respect to the subject matter hereof and supersedes all prior or contemporaneous agreements, representations, or understandings. No oral representations or warranties shall be binding. No amendment shall be effective unless in writing and signed by authorized representatives of both parties.\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text: "13.7 Notices\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "Notices under this Agreement must be in writing and will be deemed delivered: (a) upon delivery if sent by United States certified mail, return receipt requested; or (b) upon confirmed delivery if sent by email to the address on record for the receiving party. Notices to L&D should be directed to:\n\n",
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

                            /// =========== (Optional Dynamic Version - commented out) ===========
                            ///
                            /// EXAMPLE dynamic title:
                            /// Obx(() => Text(controller.dialogTitle.value, style: ...))
                            ///
                            /// EXAMPLE dynamic content:
                            /// Obx(() => Text(controller.dialogContent.value, style: ...))
                            ///
                            /// ================================================================
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
