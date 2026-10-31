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
        child: Stack(
          children: [
            SizedBox(height: context.h(80)),

            Positioned(
              right: context.w(12),
              top: context.h(40),
              child: GestureDetector(
                onTap: () => Get.back(),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => Get.back(),
                  icon: SvgPicture.asset(
                    "assets/icons/Close-X-Circle.svg",
                    width: context.w(30),
                    height: context.h(30),
                  ),
                ),
              ),
            ),

            /// FOREGROUND CONTENT
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

                            RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Lato',
                                  height: 1.4,
                                ),
                                children: [
                                  TextSpan(
                                    text: "Leavitt & Davis LLC\nRightRoute™ Software\nTerms of Service\n\n",
                                    style: TextStyle(
                                      color: AppColors.orange,
                                      fontWeight: FontWeight.bold,
                                      fontSize: context.sp(19),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "Last updated: 8/11/2026\n\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: context.sp(17),
                                    ),
                                  ),

                                  // Important Notice
                                  TextSpan(
                                    text: "Important Notice\n\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: context.sp(19),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "PLEASE READ THESE TERMS OF SERVICE CAREFULLY BEFORE ACCESSING OR USING THE SERVICES. THIS AGREEMENT CONTAINS IMPORTANT LIMITATIONS OF LIABILITY, INDEMNITY OBLIGATIONS, A BINDING ARBITRATION CLAUSE, AND A DECISION-SUPPORT DISCLAIMER THAT AFFECT YOUR LEGAL RIGHTS. BY ACCESSING OR USING THE SERVICES, YOU AGREE TO BE BOUND BY THIS AGREEMENT. IF YOU DO NOT AGREE, DO NOT ACCESS OR USE THE SERVICES.\n\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: context.sp(17),
                                    ),
                                  ),

                                  // 1. Definitions
                                  TextSpan(
                                    text: "1. Definitions\n\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: context.sp(19),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "The following capitalized terms have the meanings set forth below:\n\n"
                                        "“Agreement” means these Terms of Service, together with any applicable order forms, schedules, or addenda, and the RightRoute Software Privacy Policy, all of which are incorporated herein by reference.\n\n"
                                        "“Services” means the RightRoute Software software-as-a-service platform and related cloud services, APIs, integrations, and customer support made available by Leavitt & Davis LLC at https://getrightroute.app, as further described in applicable documentation.\n\n"
                                        "“Route Data” means origin, destination, waypoint, road segment, bridge clearance and rating, weight and height restriction, permit, load specification, and related operational data entered into, processed by, or generated by the Services.\n\n"
                                        "“Personal Data” means any information relating to an identified or identifiable natural person processed through the Services.\n\n"
                                        "“Third-Party Data” means data sourced from state departments of transportation, federal highway databases, bridge inspection records, GIS mapping providers, weather services, and other external sources integrated with the Services.\n\n"
                                        "“Derived Data” means analytics, models, benchmarks, and other outputs generated by Leavitt & Davis LLC from Route Data, Personal Data, or Third-Party Data.\n\n"
                                        "“AI-Processed Data” means any output generated by artificial intelligence or machine learning tools used within the Services to extract, summarize, classify, score, or otherwise analyze permit documents, Route Data, or other content submitted by a User, including any associated confidence scores.\n\n"
                                        "“SMS/Text Communications” means any text, SMS, or MMS message sent by or on behalf of RightRoute, including through a third-party SMS/text messaging service provider, to a mobile telephone number in connection with the Services, including one-time passcodes, account verification codes, and Team invitation notices.\n\n"
                                        "“User” means any carrier, trucking company, broker, dispatcher, or other person or entity who accesses or uses the Services under this Agreement, including any person granted access by you.\n\n"
                                        "“Personnel” means your drivers, employees, contractors, dispatchers, and other individuals who use the Services on your behalf, or whose location, route, or activity data is collected through the Services in connection with your use.\n\n"
                                        "“RightRoute” means Leavitt & Davis LLC and its affiliates, directors, officers, employees, agents, subcontractors, successors, and assigns.\n\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: context.sp(17),
                                    ),
                                  ),

                                  // 2. License and Access
                                  TextSpan(
                                    text: "2. License and Access\n\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: context.sp(19),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "RightRoute grants you a limited, non-exclusive, non-transferable, non-sublicensable license to access and use the Services during the term of this Agreement solely for your internal business purposes in connection with planning, coordinating, and executing oversized and overweight load moves, and only in jurisdictions where your use complies with applicable law, including export control and sanctions laws.\n\n"
                                        "This license does not include the right to: (a) copy, modify, reverse engineer, decompile, disassemble, or attempt to extract source code from the Services; (b) bypass or interfere with any security, authentication, or access control mechanism; (c) use the Services to build or train a competing product or service; (d) resell, sublicense, or otherwise provide the Services to any third party except as expressly permitted in writing by RightRoute; (e) access the Services through automated means except through documented APIs; or (f) use the Services in violation of applicable law or this Agreement.\n\n"
                                        "You are responsible for all activity that occurs under your account and for maintaining the confidentiality of your login credentials. You must notify RightRoute immediately of any unauthorized use of your account or any other security breach.\n\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: context.sp(17),
                                    ),
                                  ),

                                  // 3. Decision-Support Disclaimer
                                  TextSpan(
                                    text: "3. Decision-Support Disclaimer\n\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: context.sp(19),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "THE SERVICES, INCLUDING ALL ROUTE PLANS, CLEARANCE ANALYSES, PERMIT CHECKLISTS, HEIGHT AND WEIGHT RECOMMENDATIONS, AND OTHER OUTPUTS, ARE DECISION-SUPPORT TOOLS ONLY. THEY DO NOT CONSTITUTE LEGAL ADVICE, ENGINEERING ANALYSIS, OR A GUARANTEE OF ROUTE SAFETY OR REGULATORY COMPLIANCE.\n\n"
                                        "THIRD-PARTY DATA INCORPORATED INTO THE SERVICES — INCLUDING STATE DOT PERMIT DATABASES, BRIDGE RATING AND INSPECTION RECORDS, FHWA RESTRICTION DATA, AND MAPPING INFORMATION — IS PROVIDED “AS IS.” RIGHTROUTE DOES NOT INDEPENDENTLY VERIFY THE ACCURACY, COMPLETENESS, OR CURRENCY OF THIRD-PARTY DATA. BRIDGE RATINGS, CLEARANCE MEASUREMENTS, AND ROAD RESTRICTION DATA ARE SUBJECT TO CHANGE WITHOUT NOTICE.\n\n"
                                        "THE SERVICES MAY ALSO USE ARTIFICIAL INTELLIGENCE OR MACHINE LEARNING TOOLS TO EXTRACT, SUMMARIZE, OR ANALYZE PERMIT DOCUMENTS AND OTHER USER-SUBMITTED CONTENT, PRODUCING AI-PROCESSED DATA, INCLUDING ASSOCIATED CONFIDENCE SCORES. AI-PROCESSED DATA IS A DECISION-SUPPORT OUTPUT ONLY, MAY CONTAIN ERRORS, OMISSIONS, OR MISCLASSIFICATIONS, AND IS NOT A VERIFIED OR AUTHORITATIVE READING OF ANY PERMIT, REGULATION, OR OTHER DOCUMENT. YOU REMAIN SOLELY RESPONSIBLE FOR INDEPENDENTLY REVIEWING THE UNDERLYING DOCUMENT AND CONFIRMING ITS ACTUAL TERMS BEFORE RELYING ON ANY AI-PROCESSED DATA.\n\n"
                                        "YOU REMAIN SOLELY RESPONSIBLE FOR: (A) INDEPENDENTLY VERIFYING ALL ROUTE OUTPUTS AGAINST CURRENT PERMIT CONDITIONS, APPLICABLE FEDERAL AND STATE REGULATIONS (INCLUDING 23 U.S.C. § 127 (VEHICLE WEIGHT LIMITATIONS), 23 C.F.R. PART 658, AND APPLICABLE STATE OVERSIZE/OVERWEIGHT STATUTES AND REGULATIONS), AND ACTUAL ROAD AND BRIDGE CONDITIONS; (B) OBTAINING ALL REQUIRED OVERSIZE/OVERWEIGHT PERMITS FROM APPLICABLE JURISDICTIONS BEFORE COMMENCING ANY MOVE; (C) ENSURING COMPLIANCE WITH ESCORT AND PILOT VEHICLE REQUIREMENTS UNDER APPLICABLE LAW; (D) MAKING ALL FINAL ROUTING, LOAD, AND OPERATIONAL DECISIONS; AND (E) COMPLYING WITH ALL APPLICABLE FEDERAL, STATE, AND LOCAL LAWS AND REGULATIONS GOVERNING THE MOVEMENT OF OVERSIZED AND OVERWEIGHT LOADS.\n\n"
                                        "You agree that you will not use the Services as the sole basis for any move, permit application, load clearance decision, insurance underwriting determination, or mandatory regulatory filing.\n\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: context.sp(17),
                                    ),
                                  ),

                                  // 4. User Obligations
                                  TextSpan(
                                    text: "4. User Obligations\n\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: context.sp(19),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "4.1 Regulatory Compliance\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: context.sp(17),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "You represent and warrant that: (a) you hold all licenses, permits, and authorizations required by applicable federal, state, and local law to transport oversized and overweight loads in the jurisdictions where you operate; (b) you will obtain all required oversize/overweight permits before commencing any move planned using the Services; (c) you will comply with all applicable federal motor carrier safety regulations (49 C.F.R. Parts 382–399), FHWA bridge formula requirements (23 U.S.C. § 127), and applicable state permitting and routing requirements; and (d) you will not operate a vehicle in violation of applicable weight, height, width, or length limits based solely on a route output from the Services without independent verification.\n\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: context.sp(17),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "4.2 Insurance Requirements\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: context.sp(17),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "As a condition of accessing and using the Services, you must maintain, at your sole cost and expense, the following insurance coverages at all times during the term of this Agreement:\n\n"
                                        "• Commercial Auto Liability covering bodily injury and property damage arising from the operation of any vehicle used in connection with oversized or overweight load moves planned using the Services. Coverage must satisfy the standard set forth below in this Section 4.2.\n\n"
                                        "• Commercial General Liability, covering liability arising in connection with your use of the Services and your oversized or overweight load moves, satisfying the standard set forth below in this Section 4.2.\n\n"
                                        "• Cargo Insurance covering the full replacement value of loads transported using routes planned through the Services, satisfying the standard set forth below in this Section 4.2.\n\n"
                                        "You represent, warrant, and covenant that, at all times during the term of this Agreement, the insurance coverages described above will comply with, and be maintained in amounts and on terms no less protective than, the greater of: (a) all applicable legal and regulatory requirements governing your operations and the cargo you transport, including the minimum financial-responsibility requirements under 49 C.F.R. § 387.9 and any applicable state-law minimums; and (b) reasonable industry standards for transporting the type of cargo and conducting the type of oversized or overweight load moves at issue. Where clauses (a) and (b) prescribe different amounts or terms, the more protective applies. You are solely responsible for determining the coverage necessary to satisfy this standard for each move.\n\n"
                                        "All policies must be issued by insurers authorized to do business in the applicable jurisdiction and rated no less than A-/VII by A.M. Best. You agree to provide RightRoute with certificates of insurance evidencing the required coverages upon request and to name Leavitt & Davis LLC as an additional insured on the commercial auto and general liability policies where permitted by your insurer. You must notify RightRoute promptly if any required coverage lapses, is cancelled, or is materially reduced.\n\n"
                                        "THE FOREGOING MINIMUM INSURANCE REQUIREMENTS DO NOT LIMIT YOUR INDEMNIFICATION OBLIGATIONS UNDER SECTION 9 OF THIS AGREEMENT OR YOUR LIABILITY TO THIRD PARTIES, AND YOUR INDEMNIFICATION AND DEFENSE OBLIGATIONS UNDER SECTION 9 APPLY REGARDLESS OF THE EXISTENCE, ADEQUACY, OR COLLECTABILITY OF ANY INSURANCE, AS PROVIDED IN SECTION 9.3.\n\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: context.sp(17),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "4.3 Data Accuracy\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: context.sp(17),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "You are responsible for the accuracy and completeness of Route Data and other information you submit to the Services. If you submit Route Data pertaining to loads or routes that are not owned by you, you represent that you have authority to submit such data and to authorize its processing by RightRoute.\n\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: context.sp(17),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "4.4 Driver and Employee Notice and Consent\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: context.sp(17),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "If you permit any Personnel to use the Services, or if the location, route, or activity data of any Personnel is collected through the Services in connection with your use, you represent and warrant that: (a) you have provided any written or other notice required by applicable federal, state, or local law before collecting, or permitting the collection of, GPS, location, or other Personal Data regarding your Personnel, including any notice required under state GPS-tracking, electronic-monitoring, or similar employee-notice statutes; (b) you have obtained any consent from your Personnel required by applicable law before submitting their Personal Data to the Services; and (c) you will maintain records sufficient to demonstrate compliance with clauses (a) and (b) and will provide such records to RightRoute or a governmental authority upon reasonable request.\n\n"
                                        "You are solely responsible for satisfying the notice and consent obligations described in this Section 4.4. RightRoute has no obligation to provide notice to, or obtain consent from, your Personnel on your behalf, and RightRoute's provision of the Services to you is not a representation that your use complies with any notice or consent requirement applicable to your Personnel.\n\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: context.sp(17),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "4.5 SMS/Text Communications Consent\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: context.sp(17),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "The Services use SMS/Text Communications — including through a third-party SMS/text messaging service provider — to deliver one-time passcodes, account verification, and Team invitation notices to mobile telephone numbers submitted through your account. You represent and warrant that: (a) any mobile telephone number you submit to the Services belongs to, or has been submitted with the express consent of, the individual associated with that number; (b) you have obtained any consent required under the Telephone Consumer Protection Act, 47 U.S.C. § 227, and applicable state law before causing RightRoute or its SMS/text messaging service provider to send SMS/Text Communications to that number; and (c) you will promptly notify RightRoute if any individual withdraws consent to receive SMS/Text Communications.\n\n"
                                        "Message and data rates may apply. Message frequency varies based on your account activity. An individual may reply STOP to any SMS/Text Communication to opt out of future messages, or may contact RightRoute using the details in Section 13.7. RightRoute's handling of information collected through SMS/Text Communications is further described in the Privacy Policy.\n\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: context.sp(17),
                                    ),
                                  ),

                                  // 5. Data Ownership and Permissions
                                  TextSpan(
                                    text: "5. Data Ownership and Permissions\n\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: context.sp(19),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "Unless otherwise agreed in writing, Route Data and Personal Data you submit to the Services remain your property. You grant RightRoute a non-exclusive, worldwide, royalty-free license to process, store, and use Route Data and Personal Data to: (a) provide, operate, and maintain the Services; (b) comply with applicable law; and (c) as further described in the RightRoute Software Privacy Policy.\n\n"
                                        "RightRoute owns all Derived Data and all rights in and to the Services, platform, software, algorithms, models, and documentation. You may use outputs and reports made available to you through the Services for your internal business purposes in connection with oversized load moves.\n\n"
                                        "RightRoute may use Route Data in aggregated or anonymized form that does not identify you, your organization, or any individual for benchmarking, research, and product improvement purposes.\n\n"
                                        "Team and Multi-User Accounts. If you create or participate in a Team within the Services, you acknowledge that a Team Owner or Team Admin may be able to view, manage, and export Route Data, Personal Data, and other information associated with Team Members under that Team, consistent with the access permissions described in the Privacy Policy. Removal of a Team Member from a Team does not automatically delete that individual's Personal Data; retention and deletion following removal are governed by Section 8 (Term and Termination) of this Agreement and the Privacy Policy.\n\n"
                                        "Each party’s obligations with respect to Personal Data are further described in the RightRoute Software Privacy Policy, which is incorporated by reference.\n\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: context.sp(17),
                                    ),
                                  ),

                                  // 6. Updates and Service Changes
                                  TextSpan(
                                    text: "6. Updates and Service Changes\n\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: context.sp(19),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "RightRoute may update, modify, or improve the Services (including routing algorithms, Third-Party Data feeds, and decision-support models) from time to time. You consent to automatic updates to the Services. If you fail to install required updates, your access to the Services may be suspended or terminated.\n\n"
                                        "RightRoute will not materially degrade the core functionality of the Services during your current subscription term, unless required for security, legal, or technical reasons, or as the result of changes to Third-Party Data availability. RightRoute may discontinue specific features or Third-Party Data integrations with reasonable prior notice.\n\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: context.sp(17),
                                    ),
                                  ),

                                  // 7. Payment
                                  TextSpan(
                                    text: "7. Payment\n\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: context.sp(19),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "Fees for the Services are set forth in your applicable order form or subscription plan. All fees are due in advance. Fees may be structured based on subscription tier, number of users, volume of routes processed, or other metrics as described in your order form.\n\n"
                                        "Automatic Renewal. UNLESS YOU CANCEL YOUR SUBSCRIPTION OR OTHERWISE NOTIFY RIGHTROUTE IN ACCORDANCE WITH THIS SECTION, YOUR SUBSCRIPTION WILL AUTOMATICALLY RENEW AT THE END OF EACH SUBSCRIPTION TERM FOR AN ADDITIONAL TERM OF THE SAME LENGTH, AT THE THEN-CURRENT FEES, UNTIL CANCELLED. Where required by applicable law, RightRoute will provide notice of an upcoming automatic renewal, and of any related fee increase, a reasonable period before the renewal date. You may cancel automatic renewal at any time before the renewal date using the cancellation mechanism made available in your account settings, or by contacting RightRoute using the details in Section 13.7; cancellation is effective at the end of the then-current subscription term unless you request earlier termination in accordance with Section 8. If you accepted this Agreement as an individual consumer rather than on behalf of a commercial entity, additional cancellation, reminder-notice, or free-trial-conversion disclosures may apply under the law of your state of residence, and nothing in this Section limits any non-waivable right you may have under such law.\n\n"
                                        "All fees are exclusive of applicable taxes, duties, and similar government charges, which you are responsible for paying. You must dispute any invoice in writing within seven (7) days of the invoice date; after that period, the invoice is deemed accepted.\n\n"
                                        "If any payment is declined or not received when due, RightRoute may, in its sole discretion, suspend access to the Services after ten (10) days’ written notice. Continued failure to pay may result in termination of this Agreement. There are no termination fees.\n\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: context.sp(17),
                                    ),
                                  ),

                                  // 8. Term and Termination
                                  TextSpan(
                                    text: "8. Term and Termination\n\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: context.sp(19),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "This Agreement continues until terminated by either party. Either party may terminate this Agreement for any reason upon written notice to the other party. Termination for non-payment or material breach by you is effective immediately upon notice.\n\n"
                                        "Upon termination: (a) your license to access and use the Services terminates; (b) you must pay all outstanding amounts due; and (c) RightRoute will retain and delete your Route Data and Personal Data in accordance with the Privacy Policy and applicable law. RightRoute will refund any prepaid, unearned subscription fees for full calendar months following the effective date of termination; no refund will be made for any partial calendar month.\n\n"
                                        "Sections 3 (Decision-Support Disclaimer), 4.2 (Insurance Requirements), 4.4 (Driver and Employee Notice and Consent), 4.5 (SMS/Text Communications Consent), 5 (Data Ownership), 9 (Indemnification), 10 (Limitations of Liability), 11 (Disclaimers), 12 (Dispute Resolution), and 13 (General) survive termination of this Agreement.\n\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: context.sp(17),
                                    ),
                                  ),

                                  // 9. Indemnification
                                  TextSpan(
                                    text: "9. Indemnification\n\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: context.sp(19),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "9.1 Indemnification by User\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: context.sp(17),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "You agree to indemnify, defend, and hold harmless RightRoute from and against any and all claims, actions, demands, losses, damages, liabilities, costs, and expenses (including reasonable attorneys’ fees) arising out of or relating to: (a) your access to or use of the Services; (b) your violation of this Agreement or applicable law, including any failure to obtain required permits or comply with federal or state oversize/overweight regulations; (c) any accident, injury, death, or property damage occurring in connection with an oversized or overweight load move where the Services were used in the planning or execution of the move; (d) your failure to independently verify route outputs before reliance; (e) Route Data or other information you submit to the Services; (f) any claim by a third party (including a carrier, shipper, broker, insurer, or government authority) arising from your use of the Services;\n\n"
                                        "(g) your failure to satisfy any notice, consent, or recordkeeping obligation under Section 4.4 (Driver and Employee Notice and Consent), including any claim brought by or on behalf of your Personnel relating to the collection of their location or other Personal Data through the Services; or (h) your failure to satisfy any consent obligation under Section 4.5 (SMS/Text Communications Consent), including any claim asserted under the Telephone Consumer Protection Act or similar state law arising from an SMS/Text Communication sent to a number you submitted;\n\n"
                                        "(i) your failure to obtain or maintain insurance meeting the standard set forth in Section 4.2, or any insufficiency, lapse, cancellation, denial, exhaustion, or non-collectability of your insurance, including any claim, liability, or expense that would have been covered had you maintained the insurance required by Section 4.2.\n\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: context.sp(17),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "9.2 Indemnification by RightRoute\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: context.sp(17),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "RightRoute agrees to indemnify, defend, and hold harmless you from and against any third-party claims alleging that the Services, as provided by RightRoute and used in accordance with this Agreement, infringe any valid United States patent, copyright, or trade secret. This indemnification does not apply to claims arising from: (a) your modification of the Services; (b) your use of the Services in combination with products or services not provided or approved by RightRoute; (c) your continued use after RightRoute has provided a non-infringing alternative; or (d) Third-Party Data.\n\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: context.sp(17),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "9.3 Independence of Insurance; Defense\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: context.sp(17),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "Your indemnification and defense obligations under Section 9.1 are independent of, and are not limited or satisfied by, any insurance you maintain or are required to maintain. Those obligations apply in full regardless of the existence, availability, adequacy, applicability, amount, lapse, cancellation, denial, exhaustion, or collectability of any insurance policy, and are not capped at or measured by any available insurance proceeds. The existence of insurance coverage does not relieve you of, or reduce, your obligations under Section 9.1, and RightRoute is not required to exhaust or pursue any insurance before enforcing those obligations.\n\n"
                                        "With respect to any claim subject to indemnification under Section 9.1, you will, at your expense, defend RightRoute with counsel reasonably acceptable to RightRoute, or, at RightRoute's election, reimburse RightRoute's reasonable costs and attorneys’ fees of defending the claim. RightRoute will notify you promptly of any claim for which it seeks indemnification (provided that a delay in notice does not relieve you of your obligations except to the extent you are materially prejudiced), and you will not settle any claim in a manner that imposes any liability or obligation on, or requires any admission by, RightRoute without RightRoute's prior written consent. RightRoute may participate in the defense of any such claim with its own counsel at its own expense.\n\n"
                                        "Nothing in this Section 9 requires you to indemnify or defend RightRoute against liability to the extent that liability is finally determined to have been caused by RightRoute's own negligence, willful misconduct, or violation of law; this Section is intended to make you responsible for claims arising from your acts, omissions, breaches, and failures, and is to be construed and applied accordingly and only to the fullest extent permitted by applicable law.\n\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: context.sp(17),
                                    ),
                                  ),

                                  // 10. Limitations of Liability
                                  TextSpan(
                                    text: "10. Limitations of Liability\n\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: context.sp(19),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "10.1 Cap on Liability\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: context.sp(17),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "RIGHTROUTE’S TOTAL CUMULATIVE LIABILITY TO YOU ARISING OUT OF OR IN CONNECTION WITH THIS AGREEMENT OR THE SERVICES, REGARDLESS OF THE FORM OF ACTION AND WHETHER IN CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY, OR OTHERWISE, SHALL NOT EXCEED THE GREATER OF (A) THE TOTAL FEES PAID OR PAYABLE BY YOU TO RIGHTROUTE DURING THE TWELVE (12) MONTHS IMMEDIATELY PRECEDING THE EVENT GIVING RISE TO THE CLAIM, OR (B) ONE THOUSAND DOLLARS (\$1,000.00).\n\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: context.sp(17),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "10.2 Exclusion of Consequential Damages\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: context.sp(17),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "IN NO EVENT SHALL EITHER PARTY BE LIABLE TO THE OTHER FOR ANY INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, PUNITIVE, OR CONSEQUENTIAL DAMAGES, INCLUDING LOST PROFITS, LOST REVENUE, LOSS OF DATA, LOSS OF GOODWILL, BUSINESS INTERRUPTION, OR THE COST OF SUBSTITUTE SERVICES, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGES AND REGARDLESS OF WHETHER SUCH DAMAGES ARISE UNDER CONTRACT, TORT, STATUTE, OR ANY OTHER THEORY OF LIABILITY.\n\n"
                                        "THE FOREGOING LIMITATIONS SHALL NOT APPLY TO: (A) EITHER PARTY’S INDEMNIFICATION OBLIGATIONS UNDER SECTION 9; (B) YOUR OBLIGATION TO PAY FEES; (C) DAMAGES ARISING FROM YOUR BREACH OF THE LICENSE RESTRICTIONS IN SECTION 2; OR (D) A PARTY’S FRAUD OR WILLFUL MISCONDUCT.\n\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: context.sp(17),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "10.3 Essential Basis\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: context.sp(17),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "THE PARTIES ACKNOWLEDGE THAT THE LIMITATIONS OF LIABILITY IN THIS SECTION 10 REFLECT A REASONABLE ALLOCATION OF RISK AND ARE AN ESSENTIAL ELEMENT OF THE BASIS OF THE BARGAIN BETWEEN THE PARTIES. RIGHTROUTE WOULD NOT PROVIDE THE SERVICES WITHOUT THESE LIMITATIONS.\n\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: context.sp(17),
                                    ),
                                  ),

                                  // 11. Disclaimers
                                  TextSpan(
                                    text: "11. Disclaimers\n\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: context.sp(19),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "THE SERVICES ARE PROVIDED “AS IS” AND “AS AVAILABLE.” RIGHTROUTE AND ITS LICENSORS AND THIRD-PARTY DATA PROVIDERS EXPRESSLY DISCLAIM ALL WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, ACCURACY, NON-INFRINGEMENT, AND ANY WARRANTY THAT THE SERVICES WILL BE UNINTERRUPTED, ERROR-FREE, OR FREE OF HARMFUL COMPONENTS. RIGHTROUTE DOES NOT WARRANT THAT ROUTE OUTPUTS ACCURATELY REFLECT CURRENT ROAD CONDITIONS, BRIDGE RATINGS, PERMIT REQUIREMENTS, OR APPLICABLE LEGAL RESTRICTIONS IN ANY JURISDICTION. RIGHTROUTE FURTHER DOES NOT WARRANT THAT AI-PROCESSED DATA ACCURATELY OR COMPLETELY REFLECTS THE CONTENTS OF ANY UNDERLYING PERMIT DOCUMENT OR OTHER USER-SUBMITTED CONTENT. YOU ASSUME ALL RISK ARISING FROM YOUR USE OF THE SERVICES AND RELIANCE ON ROUTE OUTPUTS.\n\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: context.sp(17),
                                    ),
                                  ),

                                  // 12. Dispute Resolution
                                  TextSpan(
                                    text: "12. Dispute Resolution\n\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: context.sp(19),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "12.1 Governing Law\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: context.sp(17),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "This Agreement is governed by and construed in accordance with the laws of the State of Utah, without reference to its conflict of laws principles. The interpretation of this Agreement shall not be construed against the drafter.\n\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: context.sp(17),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "12.2 Binding Arbitration\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: context.sp(17),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "Any dispute, controversy, or claim arising out of or relating to this Agreement or the Services, including any question regarding the existence, validity, or termination of this Agreement, shall be resolved by binding arbitration administered by the American Arbitration Association (“AAA”) under its Commercial Arbitration Rules, except as provided in Section 12.4 below.\n\n"
                                        "The arbitration shall be conducted by a single arbitrator in Vernal, Utah, or remotely if the parties agree. The language of the arbitration shall be English. The arbitrator’s award shall be final and binding and may be entered as a judgment in any court of competent jurisdiction. The costs of arbitration (excluding each party’s attorneys’ fees) shall be borne equally by the parties, except as otherwise required by the AAA’s fee schedule for consumer-initiated disputes, if applicable.\n\n"
                                        "EACH PARTY WAIVES ITS RIGHT TO A JURY TRIAL WITH RESPECT TO ANY DISPUTE ARISING OUT OF OR RELATING TO THIS AGREEMENT.\n\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: context.sp(17),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "12.3 Class Action Waiver\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: context.sp(17),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "All disputes must be brought on an individual basis only. Neither party may bring or participate in any class action, class arbitration, consolidated proceeding, or representative action in connection with this Agreement. This class action waiver is an essential term of this Agreement; if it is found unenforceable, the entire arbitration provision shall be null and void.\n\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: context.sp(17),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "12.4 Injunctive Relief\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: context.sp(17),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "Notwithstanding the foregoing, either party may seek emergency injunctive or other equitable relief from a court of competent jurisdiction in North Dakota to prevent irreparable harm pending the resolution of a dispute by arbitration.\n\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: context.sp(17),
                                    ),
                                  ),

                                  // 13. General
                                  TextSpan(
                                    text: "13. General\n\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: context.sp(19),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "13.1 Assignment\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: context.sp(17),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "You may not assign or transfer this Agreement or any rights or obligations hereunder without RightRoute’s prior written consent. RightRoute may assign this Agreement, in whole or in part, without your consent in connection with a merger, acquisition, reorganization, or sale of all or substantially all of its assets. Any purported assignment in violation of this section is void.\n\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: context.sp(17),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "13.2 Subcontractors\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: context.sp(17),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "RightRoute may engage subcontractors to perform portions of the Services. RightRoute remains responsible for subcontractors’ performance. You authorize RightRoute to share your information with subcontractors as necessary to provide the Services, in accordance with the Privacy Policy.\n\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: context.sp(17),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "13.3 Modifications\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: context.sp(17),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "RightRoute may modify this Agreement by providing you with at least thirty (30) days’ prior written notice via email or a prominent notice within the Services. If you do not agree to the modified terms, you must notify RightRoute in writing within thirty (30) days and may terminate this Agreement without penalty. Your continued use of the Services after the effective date of the modified Agreement constitutes acceptance.\n\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: context.sp(17),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "13.4 Severability\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: context.sp(17),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "If any provision of this Agreement is held to be invalid, illegal, or unenforceable, that provision shall be modified to the minimum extent necessary to make it enforceable, or severed if modification is not possible, without affecting the validity of the remaining provisions.\n\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: context.sp(17),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "13.5 Waiver\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: context.sp(17),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "No waiver of any provision of this Agreement shall be effective unless in writing. A waiver of any breach shall not constitute a waiver of any subsequent breach or of the underlying obligation.\n\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: context.sp(17),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "13.6 Entire Agreement\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: context.sp(17),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "This Agreement, together with any applicable order forms and the Privacy Policy, constitutes the entire agreement between the parties with respect to the subject matter hereof and supersedes all prior or contemporaneous agreements, representations, or understandings. No oral representations or warranties shall be binding. No amendment shall be effective unless in writing and signed by authorized representatives of both parties.\n\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: context.sp(17),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "13.7 Notices\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: context.sp(17),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "Notices under this Agreement must be in writing and will be deemed delivered: (a) upon delivery if sent by United States certified mail, return receipt requested; or (b) upon confirmed delivery if sent by email to the address on record for the receiving party. Notices to RightRoute should be directed to:\n\n"
                                        "Leavitt & Davis LLC\n"
                                        "1753 US Highway 40, Suite 2, PMB 15\n"
                                        "Vernal UT 84078\n"
                                        "legal@getrightroute.app\n\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: context.sp(17),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "13.8 Force Majeure\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: context.sp(17),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "RightRoute shall not be liable for any delay or failure to perform resulting from causes beyond its reasonable control, including acts of God, natural disasters, government actions, internet or telecommunications failures, cyberattacks, or third-party service provider outages. RightRoute will use commercially reasonable efforts to resume performance as soon as practicable.\n\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: context.sp(17),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "13.9 Relationship of the Parties\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: context.sp(17),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "The parties are independent contractors. Nothing in this Agreement creates a partnership, joint venture, agency, franchise, or employment relationship between the parties.\n\n"
                                        "© 2026 Leavitt & Davis LLC. All rights reserved.\n\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: context.sp(17),
                                    ),
                                  ),
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
