import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:right_routes/utils/colors.dart';
import 'package:right_routes/utils/responsive_ext.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../utils/assets_manager.dart';
import '../../global_widgets/custom_navbar.dart';

class ContactSupport extends StatefulWidget {
  const ContactSupport({super.key});

  @override
  State<ContactSupport> createState() => _ContactSupportState();
}

class _ContactSupportState extends State<ContactSupport> {
  late final TapGestureRecognizer _emailRecognizer;
  late final TapGestureRecognizer _webRecognizer;

  @override
  void initState() {
    super.initState();
    _emailRecognizer = TapGestureRecognizer()
      ..onTap = () async {
        final uri = Uri.parse('mailto:help@getrightroute.app');
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        }
      };
    _webRecognizer = TapGestureRecognizer()
      ..onTap = () async {
        final uri = Uri.parse('https://getrightroute.app/support/');
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      };
  }

  @override
  void dispose() {
    _emailRecognizer.dispose();
    _webRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isLandscape = context.landscape;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(ImageManager.mapBackground),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: isLandscape
              ? _buildLandscapeLayout(context)
              : _buildPortraitLayout(context),
        ),
      ),
      bottomNavigationBar: const CustomNavbar(),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // PORTRAIT LAYOUT
  // ─────────────────────────────────────────────────────────────
  Widget _buildPortraitLayout(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: context.w(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: context.h(20)),
            _buildLogo(context),
            SizedBox(height: context.h(39)),
            _buildContent(context),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // LANDSCAPE LAYOUT
  // ─────────────────────────────────────────────────────────────
  Widget _buildLandscapeLayout(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(context.s(12)),
      child: Flex(
        direction: Axis.horizontal,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // LEFT — sticky logo
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.35,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: context.h(10)),
                _buildLogo(context),
              ],
            ),
          ),
          SizedBox(width: context.w(15)),
          // RIGHT — scrollable content
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.only(top: context.h(10)),
                child: _buildContent(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // SHARED WIDGETS
  // ─────────────────────────────────────────────────────────────

  Widget _buildLogo(BuildContext context) {
    return Center(
      child: Container(
        width: context.w(225),
        height: context.h(112),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(ImageManager.splashScreenLogo),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contact Support',
          textAlign: TextAlign.start,
          style: TextStyle(
            color: Colors.white,
            fontSize: context.sp(28),
            fontFamily: 'Lato',
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
        Divider(color: AppColors.dividerColor, thickness: 1),
        SizedBox(height: context.h(8)),
        RichText(
          text: TextSpan(
            style: TextStyle(
              color: Colors.white,
              fontSize: context.sp(18),
              fontFamily: 'Lato',
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
            children: [
              const TextSpan(
                text: 'Please contact us at ',
              ),
              TextSpan(
                text: 'help@getrightroute.app',
                recognizer: _emailRecognizer,
                style: TextStyle(
                  color: AppColors.purple,
                  fontSize: context.sp(18),
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w500,
                ),
              ),
              const TextSpan(
                text: ' or fill out a support ticket on our website here: ',
              ),
              TextSpan(
                text: 'https://getrightroute.app/support/',
                recognizer: _webRecognizer,
                style: TextStyle(
                  color: AppColors.purple,
                  fontSize: context.sp(18),
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
