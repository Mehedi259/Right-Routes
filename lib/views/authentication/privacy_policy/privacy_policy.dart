import 'package:flutter/material.dart';
import 'package:right_routes/utils/responsive_ext.dart';
import 'package:get/get.dart';
import 'package:right_routes/utils/colors.dart';
import 'package:flutter_svg/svg.dart';

class PrivacyPolicy extends StatelessWidget {
  const PrivacyPolicy({super.key});

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
                      "Privacy Policy",
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
                                    text: "Leavitt & Davis LLC\nRightRoute Software™ Privacy Policy\n\n",
                                    style: TextStyle(
                                      color: AppColors.orange,
                                      fontWeight: FontWeight.bold,
                                      fontSize: context.sp(19),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "Last updated: 7/11/2026\n\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: context.sp(17),
                                    ),
                                  ),

                                  // 1. Introduction
                                  TextSpan(
                                    text: "1. Introduction\n\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: context.sp(19),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "This Privacy Policy applies to the RightRoute Software platform and related services provided by Leavitt & Davis LLC (\"RightRoute\", \"we\", \"us\", or \"our\"). It explains how we collect, use, share, and protect information when you access or use RightRoute Software as a carrier, trucking company, broker, dispatcher, or other authorized user.\n\n"
                                        "By accessing or using the Services, you agree to the collection and use of information as described in this Privacy Policy. If you do not agree, you must discontinue use of the Services.\n\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: context.sp(17),
                                    ),
                                  ),

                                  // 2. Definitions
                                  TextSpan(
                                    text: "2. Definitions\n\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: context.sp(19),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "The following defined terms apply throughout this Privacy Policy:\n\n"
                                        "• “Route Data” means origin, destination, waypoint, road segment, bridge, height/clearance, and weight-limit data, as well as permit information, load specifications, and other operational data entered into or generated by the Services in connection with planning or executing an oversized load move.\n\n"
                                        "• “Personal Data” means any information relating to an identified or identifiable natural person processed through the Services, including driver name, contact information, and device location data.\n\n"
                                        "• “Usage Data” means information about how you interact with the Services, including feature usage, session duration, device and browser characteristics, and log data.\n\n"
                                        "• “Third-Party Data” means data sourced from state departments of transportation, mapping providers, bridge databases, weather services, and other external data providers integrated with the Services.\n\n"
                                        "• “Derived Data” means analytics, models, benchmarks, and other outputs created by RightRoute using Route Data, Personal Data, Usage Data, or Third-Party Data.\n\n"
                                        "• “AI-Processed Data” means any output generated by artificial intelligence or machine learning tools used within the Services to extract, summarize, classify, score, or otherwise analyze permit documents or other content you submit, including any associated confidence scores.\n\n"
                                        "• “Sensitive Personal Information” means Personal Data that is treated as sensitive under applicable law, including precise geolocation data. Our collection and use of Sensitive Personal Information is described in Section 3.3 and Section 9 below.\n\n"
                                        "• “Team Data” means Route Data, Personal Data, and other information associated with a Team Member's use of the Services that is visible to a Team Owner or Team Admin, as described in Section 6.6.\n\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: context.sp(17),
                                    ),
                                  ),

                                  // 3. Information We Collect
                                  TextSpan(
                                    text: "3. Information We Collect\n\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: context.sp(19),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "3.1 Account and Contact Information\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: context.sp(17),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "When you create or manage an account, we collect your name, contact details, company or organization information, login credentials, and user role. This information is used to establish and maintain your account and to communicate with you about the Services.\n\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: context.sp(17),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "3.2 Route Data and Load Information\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: context.sp(17),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "The Services are designed to process Route Data you submit, including origin and destination information, load dimensions and weight specifications, permit data, preferred corridors, hazard or restriction overrides, and related operational data. This data is the core input for the Services’ routing and planning functionality.\n\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: context.sp(17),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "3.3 Location Data\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: context.sp(17),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "If you enable location-based features, the Services may collect and process precise or approximate GPS location data associated with devices, vehicles, or loads. Precise geolocation data is treated as Sensitive Personal Information under applicable law. Location data may be used to provide real-time routing updates, track move progress, and improve routing accuracy. We collect GPS coordinates, speed, and heading through the Services' route-tracking functionality on a continuous basis while location-based features are enabled. You may be able to manage location data collection through device or account settings, subject to applicable law. See Section 9 below for information on your right to limit the use of Sensitive Personal Information.\n\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: context.sp(17),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "3.4 Third-Party Data\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: context.sp(17),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "The Services integrate Third-Party Data, including publicly available and licensed data from state departments of transportation, federal highway systems, bridge databases, GIS mapping providers, and weather services. RightRoute does not warrant the accuracy, completeness, or currency of Third-Party Data. See Section 7 (Third-Party Data Disclaimer) below.\n\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: context.sp(17),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "3.5 Usage Data\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: context.sp(17),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "We automatically collect Usage Data when you access the Services, including log files, IP addresses, browser type, device identifiers, session length, and feature interaction data. We use cookies, SDKs, and similar technologies to collect Usage Data. You may manage certain cookie preferences through your browser settings or any in-product consent tools we make available.\n\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: context.sp(17),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "3.6 Support and Communications\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: context.sp(17),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "When you contact our support team, we collect the content of your communications and metadata about the interaction (timestamps, issue category, resolution steps) for service quality and audit purposes.\n\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: context.sp(17),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "3.7 AI Processing of Uploaded Documents\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: context.sp(17),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "When you upload permit files or other documents to the Services, we use artificial intelligence and machine learning tools — including third-party AI service providers — to extract text, classify content, and generate AI-Processed Data, such as extracted permit terms and associated confidence scores. This processing supports the permit-checklist and decision-support features described in the Terms of Service. AI-Processed Data is generated automatically and has not been independently verified by RightRoute; you remain responsible for reviewing the underlying document, as described in the Decision-Support Disclaimer in our Terms of Service.\n\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: context.sp(17),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "3.8 SMS/Text Communications\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: context.sp(17),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "If you or your Team members provide a mobile telephone number to the Services — for example, to receive a one-time passcode or a Team invitation — we collect that phone number and use it, together with a third-party SMS/text messaging service provider, to deliver the applicable text message. We also retain a record of consent and opt-out status associated with that number. See the Terms of Service for the consent representations that apply to submitting a phone number to the Services, and Section 6.1 below for information about our SMS/text messaging service provider.\n\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: context.sp(17),
                                    ),
                                  ),

                                  // 4. How We Use Your Information
                                  TextSpan(
                                    text: "4. How We Use Your Information\n\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: context.sp(19),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "4.1 Personal Data\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: context.sp(17),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "We use Personal Data to:\n"
                                        "• Provide, operate, and maintain the Services;\n"
                                        "• Authenticate your identity and manage account security;\n"
                                        "• Communicate with you about the Services, including updates, security notices, and support responses;\n"
                                        "• Send marketing communications about our products and services, where permitted by law and subject to your opt-out rights;\n"
                                        "• Comply with legal and regulatory obligations and respond to lawful government requests; and\n"
                                        "• Protect our legal rights, enforce this Privacy Policy and our Terms of Service, and prevent fraud or abuse.\n\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: context.sp(17),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "4.2 Route Data and Location Data\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: context.sp(17),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "We use Route Data and Location Data to:\n"
                                        "• Generate route plans, clearance analyses, permit checklists, and decision-support outputs for your use;\n"
                                        "• Improve the accuracy and reliability of the Services, including refining routing algorithms and updating restriction databases;\n"
                                        "• Train, validate, and operate analytics and machine learning models that support routing recommendations and decision-support tools;\n"
                                        "• Create aggregated or anonymized data sets that do not identify you, your organization, or any individual, for benchmarking, research, and product improvement purposes; and\n"
                                        "• Extract and analyze permit document content using AI/machine learning tools, as described in Section 3.7, to generate AI-Processed Data and support permit-checklist features.\n\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: context.sp(17),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "4.3 Usage Data\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: context.sp(17),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "We use Usage Data to monitor platform performance, diagnose technical issues, analyze feature utilization, and improve the user experience.\n\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: context.sp(17),
                                    ),
                                  ),

                                  // 5. Third-Party Data Disclaimer
                                  TextSpan(
                                    text: "5. Third-Party Data Disclaimer\n\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: context.sp(19),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "THE SERVICES INCORPORATE THIRD-PARTY DATA SOURCED FROM STATE DEPARTMENTS OF TRANSPORTATION, FEDERAL HIGHWAY ADMINISTRATION DATABASES, BRIDGE INSPECTION RECORDS, MAPPING PROVIDERS, AND OTHER EXTERNAL SOURCES. RIGHTROUTE DOES NOT INDEPENDENTLY VERIFY, WARRANT, OR GUARANTEE THE ACCURACY, COMPLETENESS, TIMELINESS, OR FITNESS FOR ANY PARTICULAR PURPOSE OF THIRD-PARTY DATA. ROUTE OUTPUTS AND RECOMMENDATIONS GENERATED BY THE SERVICES ARE DECISION-SUPPORT TOOLS ONLY AND MUST BE INDEPENDENTLY VERIFIED AGAINST APPLICABLE PERMIT CONDITIONS, STATE AND FEDERAL LOAD REGULATIONS, AND CURRENT ROAD AND BRIDGE CONDITIONS BEFORE RELIANCE. SEE ALSO THE DECISION-SUPPORT DISCLAIMER IN THE TERMS OF SERVICE.\n\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: context.sp(17),
                                    ),
                                  ),

                                  // 6. How We Share Your Information
                                  TextSpan(
                                    text: "6. How We Share Your Information\n\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: context.sp(19),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "6.1 Service Providers\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: context.sp(17),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "We share Personal Data with third-party service providers who assist us in operating the Services, including cloud hosting providers, analytics vendors, and customer support platforms, as well as our AI/machine learning service provider (for permit-document processing, as described in Section 3.7) and our SMS/text messaging service provider (for OTP and Team invitation delivery, as described in Section 3.8). These providers act as processors under written agreements that limit their use of Personal Data to providing services to us.\n\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: context.sp(17),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "6.2 Third-Party Integrations\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: context.sp(17),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "If you enable integrations with third-party permitting systems, mapping platforms, or other services, Route Data and related information may be transmitted to those third parties as necessary to provide the integrated functionality. Your use of third-party integrations is subject to those parties’ own terms and privacy policies.\n\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: context.sp(17),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "6.3 Aggregated and Anonymized Data\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: context.sp(17),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "We may share Derived Data and aggregated or anonymized data that does not identify you, your organization, or any individual with third parties for research, benchmarking, and industry analysis purposes.\n\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: context.sp(17),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "6.4 Legal and Compliance Disclosures\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: context.sp(17),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "We may disclose your information to government authorities, regulators, or law enforcement where required by law, valid legal process, or where we reasonably believe disclosure is necessary to protect the rights, property, or safety of RightRoute, our users, or the public.\n\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: context.sp(17),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "6.5 Business Transfers\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: context.sp(17),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "In the event of a merger, acquisition, sale of assets, or similar transaction, your information may be transferred to the acquiring entity. We will provide notice of such a transfer and any material changes to this Privacy Policy as required by applicable law.\n\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: context.sp(17),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "6.6 Team and Multi-User Accounts\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: context.sp(17),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "If you create or participate in a Team within the Services, a Team Owner or Team Admin may be able to view, manage, and export Team Data associated with Team Members under that Team. Team Members are notified within the Services of this visibility when joining a Team. Removal of a Team Member from a Team does not automatically delete that individual's Personal Data; retention and deletion following removal are governed by Section 8 (Data Retention) below.\n\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: context.sp(17),
                                    ),
                                  ),

                                  // 7. Security
                                  TextSpan(
                                    text: "7. Security\n\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: context.sp(19),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "We implement technical and organizational measures designed to protect your information against unauthorized access, loss, misuse, and alteration, including encryption in transit and at rest, role-based access controls, activity logging and monitoring, regular backups, and documented incident-response procedures. No system is completely secure, and we cannot guarantee that unauthorized access, hacking, data loss, or other breaches will never occur. We will notify affected users and applicable regulators of security incidents as required by applicable law, including N.D.C.C. § 51-30 (North Dakota breach notification) and other applicable state breach notification statutes.\n\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: context.sp(17),
                                    ),
                                  ),

                                  // 8. Data Retention
                                  TextSpan(
                                    text: "8. Data Retention\n\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: context.sp(19),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "We retain Personal Data and Route Data for as long as necessary to provide the Services and fulfill the purposes described in this Privacy Policy, unless a longer retention period is required or permitted by law. Upon termination of your account or written request, we will delete or anonymize your data in accordance with our Terms of Service and applicable law, subject to legal retention obligations and our legitimate interests in dispute resolution and fraud prevention.\n\n"
                                        "The table below sets out our retention period for each category of data we collect. Some categories are anonymized rather than deleted at the end of the stated period, as noted, to satisfy financial recordkeeping or security-audit obligations that survive account closure.\n\n"
                                        "• Account / User profile: Life of account + 3 years post-deletion (CCPA right-to-delete compliance; fraud prevention)\n\n"
                                        "• OTP verification records: 90 days after verification or expiry (Security audit trail)\n\n"
                                        "• Team & membership data: Life of Team + 1 year (Contractual / operational need)\n\n"
                                        "• Payment method tokens: Until you remove the method or your account is deleted (User control; subject to processor retention)\n\n"
                                        "• Payment transactions: 7 years (anonymized, not deleted, after account closure) (U.S. tax / financial recordkeeping requirements)\n\n"
                                        "• Subscription records: 7 years post-expiration (Financial compliance)\n\n"
                                        "• Route & waypoint data: Life of account + 2 years (Operational need; legal hold)\n\n"
                                        "• GPS route tracking: 1 year, rolling (Storage minimization; limits retention of precise location data)\n\n"
                                        "• Permit files: Life of the associated route + 2 years (Regulatory / legal hold)\n\n"
                                        "• Notifications: 6 months after read; 1 year if unread (Operational need)\n\n"
                                        "• Activity / audit logs: 3 years (anonymized, not deleted, after account closure) (Security, compliance, fraud investigation)\n\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: context.sp(17),
                                    ),
                                  ),

                                  // 9. Your Privacy Rights
                                  TextSpan(
                                    text: "9. Your Privacy Rights\n\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: context.sp(19),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "Depending on your location and applicable law, you may have the following rights regarding your Personal Data:\n\n"
                                        "• Access: to request a copy of the Personal Data we hold about you;\n"
                                        "• Correction: to request correction of inaccurate or incomplete Personal Data;\n"
                                        "• Deletion: to request deletion of your Personal Data, subject to legal retention obligations (as described in Section 8, certain categories — such as payment transaction records and activity logs — are anonymized rather than deleted in order to satisfy those obligations);\n"
                                        "• Restriction and Objection: to request that we limit certain processing or object to processing based on our legitimate interests;\n"
                                        "• Portability: to receive certain Personal Data in a structured, machine-readable format;\n"
                                        "• Marketing opt-out: to opt out of marketing communications at any time; and\n"
                                        "• U.S. State Rights (for eligible residents): users in California and other states with applicable privacy statutes may have additional rights, including the right to opt out of the “sale” or “sharing” of Personal Data and to limit the use of sensitive Personal Data.\n\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: context.sp(17),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "Limiting the Use of Sensitive Personal Information\n\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: context.sp(18),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "Where required by applicable law, you have the right to limit our use of Sensitive Personal Information — including precise geolocation data — to purposes necessary to provide the Services. You may exercise this right using the in-product control described as “Limit the Use of My Sensitive Personal Information” in your account settings, or by contacting us using the details in Section 12 below. Limiting the use of precise geolocation data may affect the availability of real-time routing, move-progress tracking, and related features.\n\n"
                                        "To exercise these rights, contact us using the details in Section 12 below or through any account-based self-service tools we make available. We will respond within the time required by applicable law after verifying your identity.\n\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: context.sp(17),
                                    ),
                                  ),

                                  // 10. Children
                                  TextSpan(
                                    text: "10. Children\n\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: context.sp(19),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "The Services are not directed to individuals under 18 years of age. We do not knowingly collect Personal Data from children. If you believe we have inadvertently collected information from a child, please contact us and we will take prompt steps to delete it.\n\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: context.sp(17),
                                    ),
                                  ),

                                  // 11. Data Storage and Transfer
                                  TextSpan(
                                    text: "11. Data Storage and Transfer\n\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: context.sp(19),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "We store your data in cloud systems located in the United States and subject to the laws of the United States. If you access the Services from outside the United States, your information will be transferred to and processed in the United States. By using the Services, you consent to this transfer.\n\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: context.sp(17),
                                    ),
                                  ),

                                  // 12. How to Contact Us
                                  TextSpan(
                                    text: "12. How to Contact Us\n\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: context.sp(19),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "If you have questions about this Privacy Policy or wish to exercise your privacy rights, please contact us at:\n\n"
                                        "Leavitt & Davis LLC\n"
                                        "1753 US Highway 40, Suite 2, PMB 15\n"
                                        "Vernal UT 84078\n"
                                        "legal@getrightroute.app\n\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: context.sp(17),
                                    ),
                                  ),

                                  // 13. Changes to This Privacy Policy
                                  TextSpan(
                                    text: "13. Changes to This Privacy Policy\n\n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: context.sp(19),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "We may update this Privacy Policy from time to time. If we make material changes, we will notify you by email or through a prominent notice in the Services at least 30 days before the changes take effect. Your continued use of the Services after the effective date of the revised Privacy Policy constitutes your acceptance of the changes. If you do not agree to the changes, you must discontinue use of the Services.\n\n"
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
