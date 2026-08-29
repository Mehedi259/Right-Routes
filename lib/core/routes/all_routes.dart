import 'package:get/get.dart';
import 'package:right_routes/views/home/create_new_routes/homescreen.dart';
import '../../views/account/account_delete.dart';
import '../../views/account/are_you_sure_delete_this_account.dart';
import '../../views/account/change_mail/change_email.dart';
import '../../views/account/change_password/change_password.dart';
import '../../views/account/contact_support.dart';
import '../../views/account/email_saved.dart';
import '../../views/account/help.dart';
import '../../views/account/password_saved.dart';
import '../../views/authentication/create_an_account/create_an_account.dart';
import '../../views/authentication/enter_email_for_delete/enter_email_for_delete.dart';
import '../../views/authentication/enter_email_screen/enter_email_screen.dart';
import '../../views/authentication/get_started_screen/get_started_screen.dart';
import '../../views/authentication/get_started_screen/getstarted_sign_in_screen.dart';
// import '../../views/authentication/login_account/email_edit/email_edit.dart';
import '../../views/authentication/login_account/login_account.dart';
import '../../views/authentication/login_account/otp_verification/otp_verification_binding.dart';
import '../../views/authentication/login_account/otp_verification/otp_verification_screen.dart';
import '../../views/authentication/privacy_policy/privacy_policy.dart';
import '../../views/authentication/subscriber_agreement/subscriber_agreement.dart';
import '../../views/authentication/terms_of_service/terms_of_service.dart';
import '../../views/authentication/disclaimer/disclaimer.dart';
import '../../views/authentication/we_willbe_login/we_logged_you.dart';
import '../../views/home/account_screen/account_screen_for_team.dart';
import 'package:right_routes/views/home/create_new_routes/home_controller.dart';
import 'package:right_routes/views/home/create_new_routes/confirm_your_routes/confirm_controller.dart';
import '../../views/home/create_new_routes/confirm_your_routes/confirm_your_routes.dart';
import '../../views/home/create_new_routes/confirm_your_routes/create_route_after_confirm_route/create_route_after_confirm_route.dart';
import '../../views/home/history_screen/history_screen.dart';
import '../../views/home/team_manager/team_manager.dart';
import '../../views/splash_screen/splash_screen.dart';
import '../../views/subscription_plans/choose_team_plan/choose_team_plan.dart';
import '../../views/subscription_plans/choose_your_plan/choose_your_plan.dart';
import '../../views/subscription_plans/individual_team.dart';

class AppRoutes {
  // dialog box
  static const String subscriberAgreement = "/SubscriberAgreement";

  static const String splashScreen = "/SplashScreen";
  static const String getStartedScreen = "/GetStartedScreen";
  static const String getStartedSignInScreen = "/GetStartedSignInScreen";
  static const String enterEmailForDelete = "/EnterEmailForDelete";

  // ================== Enter Email screen =====================//
  static const String enterEmailScreen = "/EnterEmailScreen";
  static const String createAccountScreen = "/CreateAnAccount";
  static const String loginAccount = "/LoginAccount";
  static const String emailEdit = "/EmailEdit";

  static const String otpVerificationScreen = "/OtpVerificationScreen";
  static const String weLoggedYou = "/WeLoggedYou";
  static const String individualTeam = "/IndividualTeam";
  static const String chooseYourPlan = "/ChooseYourPlan";
  static const String chooseATeamPlan = "/ChooseATeamPlan";

  // ================= home teamManager ===========================
  static const String homeScreen =
      "/Homescreen"; // Home screen route name (alias)
  static const String teamManager = "/TeamManager";
  static const String accountScreen = "/AccountScreen";
  static const String historyScreen = "/HistoryScreen";

  // account all routes
  static const String contactSupport = "/ContactSupport";
  static const String changeEmail = "/ChangeEmail";
  static const String emailSaved = "/EmailSaved";
  static const String changePassword = "/ChangePassword";
  static const String passwordSaved = "/PasswordSaved";
  static const String areYouSureDeleteThisAccount =
      "/AreYouSureDeleteThisAccount";
  static const String accountDelete = "/AccountDelete";
  static const String help = "/Help";
  static const String privacyPolicy = "/PrivacyPolicy";
  static const String termsModal = "/TermsModal";
  static const String disclaimer = "/Disclaimer";

  //  =================  permit selection screen  ======================

  static const String addPermitScreen = "/AddPermitScreen";



  static const String confirmYourRoutes = "/EditConfirmStartYourRoute";
  static const String confirmYourRouteForSegment =
      "/ConfirmYourRouteForSegment";
  static const String createRouteAfterConfirmRoute =
      "/CreateRouteAfterConfirmRoute";

  // =============  edit - confirm - start route section ================

  // static const String teamManager ="/TeamManager";

  // ================ login Screen part ================================

  // bridge
  static List<GetPage> routes = [
    // dialog box
    // accounts ar routes
    GetPage(
        transition: Transition.fadeIn,
        transitionDuration: const Duration(milliseconds: 300),
        name: subscriberAgreement,
        page: () => SubscriberAgreement()),
    GetPage(
        transition: Transition.fadeIn,
        transitionDuration: const Duration(milliseconds: 300),
        name: privacyPolicy,
        page: () => PrivacyPolicy()),
    GetPage(
        transition: Transition.fadeIn,
        transitionDuration: const Duration(milliseconds: 300),
        name: termsModal,
        page: () => TermsModal()),
    GetPage(
        transition: Transition.fadeIn,
        transitionDuration: const Duration(milliseconds: 300),
        name: disclaimer,
        page: () => DisclaimerModal()),
    GetPage(
        transition: Transition.fadeIn,
        transitionDuration: const Duration(milliseconds: 300),
        name: splashScreen,
        page: () => SplashScreen()),
    GetPage(
        transition: Transition.fadeIn,
        transitionDuration: const Duration(milliseconds: 300),
        name: getStartedScreen,
        page: () => GetStartedScreen()),
    GetPage(
        transition: Transition.fadeIn,
        transitionDuration: const Duration(milliseconds: 300),
        name: getStartedSignInScreen,
        page: () => GetStartedSignInScreen()),
    GetPage(
        transition: Transition.fadeIn,
        transitionDuration: const Duration(milliseconds: 300),
        name: enterEmailScreen,
        page: () => EnterEmailScreen()),
    GetPage(
        transition: Transition.fadeIn,
        transitionDuration: const Duration(milliseconds: 300),
        name: createAccountScreen,
        page: () => CreateAnAccount()),
    GetPage(
        transition: Transition.fadeIn,
        transitionDuration: const Duration(milliseconds: 300),
        name: loginAccount,
        page: () => LoginAccount()),
    GetPage(
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      name: otpVerificationScreen,
      page: () => OtpVerificationScreen(),
      binding: OtpVerificationBinding(),
    ),
    // GetPage(
    //     transition: Transition.fadeIn,
    //     transitionDuration: const Duration(milliseconds: 300),
    //     name: emailEdit,
    //     page: () => EmailEdit()),

    GetPage(
        transition: Transition.fadeIn,
        transitionDuration: const Duration(milliseconds: 300),
        name: weLoggedYou,
        page: () => WeLoggedYou()),
    GetPage(
        transition: Transition.fadeIn,
        transitionDuration: const Duration(milliseconds: 300),
        name: individualTeam,
        page: () => IndividualTeam()),
    GetPage(
        transition: Transition.fadeIn,
        transitionDuration: const Duration(milliseconds: 300),
        name: chooseYourPlan,
        page: () => ChooseYourPlan()),
    GetPage(
        transition: Transition.fadeIn,
        transitionDuration: const Duration(milliseconds: 300),
        name: chooseATeamPlan,
        page: () => ChooseATeamPlan()),

    // HOME ROUTES (Navbar tabs)
    GetPage(
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      name: homeScreen,
      page: () => Homescreen(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<HomeController>()) {
          Get.put<HomeController>(HomeController(), permanent: true);
        }
      }),
    ),
    GetPage(
        transition: Transition.fadeIn,
        transitionDuration: const Duration(milliseconds: 300),
        name: teamManager,
        page: () => TeamManager()),
    GetPage(
        transition: Transition.fadeIn,
        transitionDuration: const Duration(milliseconds: 300),
        name: accountScreen,
        page: () => AccountScreen()),
    GetPage(
        transition: Transition.fadeIn,
        transitionDuration: const Duration(milliseconds: 300),
        name: historyScreen,
        page: () => HistoryScreen()),

    // Route creation flow
    // GetPage(
    //     transition: Transition.fadeIn,
    //     transitionDuration: const Duration(milliseconds: 300),
    //     name: addPermitScreen,
    //     page: () => AddPermit()),
    //

    GetPage(
        transition: Transition.fadeIn,
        transitionDuration: const Duration(milliseconds: 300),
        name: confirmYourRoutes,
        page: () => EditConfirmStartYourRoute(),
        binding: BindingsBuilder(() => Get.lazyPut<ConfirmRouteController>(
            () => ConfirmRouteController()))),

    GetPage(
        transition: Transition.fadeIn,
        transitionDuration: const Duration(milliseconds: 300),
        name: createRouteAfterConfirmRoute,
        page: () => CreateRouteAfterConfirmRoute()),

    // =============  edit - confirm - start route section ================
    // accounts all screen route
    GetPage(
        transition: Transition.fadeIn,
        transitionDuration: const Duration(milliseconds: 300),
        name: contactSupport,
        page: () => ContactSupport()),
    GetPage(
        transition: Transition.fadeIn,
        transitionDuration: const Duration(milliseconds: 300),
        name: changeEmail,
        page: () => ChangeEmail()),
    GetPage(
        transition: Transition.fadeIn,
        transitionDuration: const Duration(milliseconds: 300),
        name: emailSaved,
        page: () => EmailSaved()),
    GetPage(
        transition: Transition.fadeIn,
        transitionDuration: const Duration(milliseconds: 300),
        name: changePassword,
        page: () => ChangePassword()),
    GetPage(
        transition: Transition.fadeIn,
        transitionDuration: const Duration(milliseconds: 300),
        name: passwordSaved,
        page: () => PasswordSaved()),
    GetPage(
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      name: areYouSureDeleteThisAccount,
      page: () => AreYouSureDeleteThisAccount(),
    ),
    GetPage(
        transition: Transition.fadeIn,
        transitionDuration: const Duration(milliseconds: 300),
        name: accountDelete,
        page: () => AccountDelete()),
    GetPage(
        transition: Transition.fadeIn,
        transitionDuration: const Duration(milliseconds: 300),
        name: enterEmailForDelete,
        page: () => EnterEmailForDelete()),
    GetPage(
        transition: Transition.fadeIn,
        transitionDuration: const Duration(milliseconds: 300),
        name: help,
        page: () => Help()),
  ];
}
