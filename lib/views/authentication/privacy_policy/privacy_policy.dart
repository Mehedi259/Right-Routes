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
                                          "Leavitt & Davis LLC - Right Route™ Privacy Policy\n\n",
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
                                      text: "1. Introduction\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: context.sp(19))),
                                  TextSpan(
                                      text:
                                          "This Privacy Policy applies to the [Product Name] platform and related services provided by [CLIENT ENTITY NAME] (“[Short Name]”, “we”, “us”, or “our”). It explains how we collect, use, share, and protect information when you access or use [Product Name] as a carrier, trucking company, broker, dispatcher, or other authorized user.\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "By accessing or using the Services, you agree to the collection and use of information as described in this Privacy Policy. If you do not agree, you must discontinue use of the Services.\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text: "2. Definitions\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: context.sp(19))),
                                  TextSpan(
                                      text:
                                          "The following defined terms apply throughout this Privacy Policy: “Route Data” means origin, destination, waypoint, road segment, bridge, height/clearance, and weight-limit data, as well as permit information, load specifications, and other operational data entered into or generated by the Services in connection with planning or executing an oversized load move.\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "“Personal Data” means any information relating to an identified or identifiable natural person processed through the Services, including driver name, contact information, and device location data.\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "“Usage Data” means information about how you interact with the Services, including feature usage, session duration, device and browser characteristics, and log data.\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "“Third-Party Data” means data sourced from state departments of transportation, mapping providers, bridge databases, weather services, and other external data providers integrated with the Services.\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "“Derived Data” means analytics, models, benchmarks, and other outputs created by [Short Name] using Route Data, Personal Data, Usage Data, or Third- Party Data.\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text: "3. Information We Collect\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: context.sp(19))),
                                  TextSpan(
                                      text:
                                          "3.1 Account and Contact Information\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "When you create or manage an account, we collect your name, contact details, company or organization information, login credentials, and user role. This information is used to establish and maintain your account and to communicate with you about the Services.\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "3.2 Route Data and Load Information\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "The Services are designed to process Route Data you submit, including origin and destination information, load dimensions and weight specifications, permit data, preferred corridors, hazard or restriction overrides, and related operational data. This data is the core input for the Services’ routing and planning functionality.\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text: "3.3 Location Data\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "If you enable location-based features, the Services may collect and process precise or approximate GPS location data associated with devices, vehicles, or loads. Location data may be used to provide real-time routing updates, track move progress, and improve routing accuracy. You may be able to manage location data collection through device or account settings, subject to applicable law.\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text: "3.4 Third-Party Data\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "The Services integrate Third-Party Data, including publicly available and licensed data from state departments of transportation, federal highway systems, bridge databases, GIS mapping providers, and weather services. [Short Name] does not warrant the accuracy, completeness, or currency of Third-Party Data. See Section 7 (Third-Party Data Disclaimer) below.\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text: "3.5 Usage Data\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "We automatically collect Usage Data when you access the Services, including log files, IP addresses, browser type, device identifiers, session length, and feature interaction data. We use cookies, SDKs, and similar technologies to collect Usage Data. You may manage certain cookie preferences through your browser settings or any in-product consent tools we make available.\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "3.6 Support and Communications\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "When you contact our support team, we collect the content of your communications and metadata about the interaction (timestamps, issue category, resolution steps) for service quality and audit purposes.\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "4. How We Use Your Information\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: context.sp(19))),
                                  TextSpan(
                                      text: "4.1 Personal Data\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text: "We use Personal Data to:\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "•  Provide, operate, and maintain the Services;\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "•  Authenticate your identity and manage account security;\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "•  Communicate with you about the Services, including updates, security notices, and support responses;\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "•  Send marketing communications about our products and services, where permitted by law and subject to your opt-out rights;\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "•  Comply with legal and regulatory obligations and respond to lawful government requests; and\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "•  Protect our legal rights, enforce this Privacy Policy and our Terms of Service, and prevent fraud or abuse.\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "4.2 Route Data and Location Data\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "We use Route Data and Location Data to:\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "•  Generate route plans, clearance analyses, permit checklists, and decision-support outputs for your use;\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "•  Improve the accuracy and reliability of the Services, including refining routing algorithms and updating restriction databases;\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "•  Train, validate, and operate analytics and machine learning models that support routing recommendations and decision-support tools; and\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "•  Create aggregated or anonymized data sets that do not identify you, your organization, or any individual, for benchmarking, research, and product improvement purposes.\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text: "4.3 Usage Data\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "We use Usage Data to monitor platform performance, diagnose technical issues, analyze feature utilization, and improve the user experience.\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "5. Third-Party Data Disclaimer\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: context.sp(19))),
                                  TextSpan(
                                      text:
                                          "THE SERVICES INCORPORATE THIRD-PARTY DATA SOURCED FROM STATE DEPARTMENTS OF TRANSPORTATION, FEDERAL HIGHWAY ADMINISTRATION DATABASES, BRIDGE INSPECTION RECORDS, MAPPING PROVIDERS, AND OTHER EXTERNAL SOURCES. [SHORT NAME] DOES NOT INDEPENDENTLY VERIFY, WARRANT, OR GUARANTEE THE ACCURACY, COMPLETENESS, TIMELINESS, OR FITNESS FOR ANY PARTICULAR PURPOSE OF THIRD-PARTY DATA. ROUTE OUTPUTS AND RECOMMENDATIONS GENERATED BY THE SERVICES ARE DECISION-SUPPORT TOOLS ONLY AND MUST BE INDEPENDENTLY VERIFIED AGAINST APPLICABLE PERMIT CONDITIONS, STATE AND FEDERAL LOAD REGULATIONS, AND CURRENT ROAD AND BRIDGE CONDITIONS BEFORE RELIANCE. SEE ALSO THE DECISION-SUPPORT DISCLAIMER IN THE TERMS OF SERVICE.\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "6. How We Share Your Information\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: context.sp(19))),
                                  TextSpan(
                                      text: "6.1 Service Providers\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "We share Personal Data with third-party service providers who assist us in operating the Services, including cloud hosting providers, analytics vendors, and customer support platforms. These providers act as processors under written agreements that limit their use of Personal Data to providing services to us.\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text: "6.2 Third-Party Integrations\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "If you enable integrations with third-party permitting systems, mapping platforms, or other services, Route Data and related information may be transmitted to those third parties as necessary to provide the integrated functionality. Your use of third-party integrations is subject to those parties’ own terms and privacy policies.\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "6.3 Aggregated and Anonymized Data\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "We may share Derived Data and aggregated or anonymized data that does not identify you, your organization, or any individual with third parties for research, benchmarking, and industry analysis purposes.\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "6.4 Legal and Compliance Disclosures\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "We may disclose your information to government authorities, regulators, or law enforcement where required by law, valid legal process, or where we reasonably believe disclosure is necessary to protect the rights, property, or safety of [Short Name], our users, or the public.\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text: "6.5 Business Transfers\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "In the event of a merger, acquisition, sale of assets, or similar transaction, your information may be transferred to the acquiring entity. We will provide notice of such a transfer and any material changes to this Privacy Policy as required by applicable law.\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text: "7. Security\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: context.sp(19))),
                                  TextSpan(
                                      text:
                                          "We implement technical and organizational measures designed to protect your information against unauthorized access, loss, misuse, and alteration, including encryption in transit and at rest, role-based access controls, activity logging and monitoring, regular backups, and documented incident-response procedures. No system is completely secure, and we cannot guarantee that unauthorized access, hacking, data loss, or other breaches will never occur. We will notify affected users and applicable regulators of security incidents as required by applicable law, including N.D.C.C. § 51-30 (North Dakota breach notification) and other applicable state breach notification statutes.\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text: "8. Data Retention\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: context.sp(19))),
                                  TextSpan(
                                      text:
                                          "We retain Personal Data and Route Data for as long as necessary to provide the Services and fulfill the purposes described in this Privacy Policy, unless a longer retention period is required or permitted by law. Upon termination of your account or written request, we will delete or anonymize your data in accordance with our Terms of Service and applicable law, subject to legal retention obligations and our legitimate interests in dispute resolution and fraud prevention.\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text: "9. Your Privacy Rights\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: context.sp(19))),
                                  TextSpan(
                                      text:
                                          "Depending on your location and applicable law, you may have the following rights regarding your Personal Data:\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "•  Access: to request a copy of the Personal Data we hold about you;\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "•  Correction: to request correction of inaccurate or incomplete Personal Data;\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "•  Deletion: to request deletion of your Personal Data, subject to legal retention obligations;\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "•  Restriction and Objection: to request that we limit certain processing or object to processing based on our legitimate interests;\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "•  Portability: to receive certain Personal Data in a structured, machine-readable format;\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "•  Marketing opt-out: to opt out of marketing communications at any time; and\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "U.S. State Rights (for eligible residents): users in California and other states with applicable privacy statutes may have additional rights, including the right to opt out of the “sale” or “sharing” of Personal Data and to limit the use of sensitive Personal Data.\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text:
                                          "To exercise these rights, contact us using the details in Section 12 below or through any account-based self-service tools we make available. We will respond within the time required by applicable law after verifying your identity.\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text: "10. Children\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: context.sp(19))),
                                  TextSpan(
                                      text:
                                          "The Services are not directed to individuals under 18 years of age. We do not knowingly collect Personal Data from children. If you believe we have inadvertently collected information from a child, please contact us and we will take prompt steps to delete it.\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text: "11. Data Storage and Transfer\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: context.sp(19))),
                                  TextSpan(
                                      text:
                                          "We store your data in cloud systems located in the United States and subject to the laws of the United States. If you access the Services from outside the United States, your information will be transferred to and processed in the United States. By using the Services, you consent to this transfer.\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: context.sp(17))),
                                  TextSpan(
                                      text: "12. How to Contact Us\n\n",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: context.sp(19))),
                                  TextSpan(
                                      text:
                                          "If you have questions about this Privacy Policy or wish to exercise your privacy rights, please contact us at:\n\n",
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
