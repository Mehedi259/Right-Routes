import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'core/constants/services/auth_service.dart';
import 'core/constants/services/device_storage_service.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';
import 'package:right_routes/core/routes/all_routes.dart';

Future<void> main() async {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );


  WidgetsFlutterBinding.ensureInitialized();

  Get.put(DeviceStorageService());
  Get.put(AuthController(
    authRepository: AuthRepositoryImpl(
      remoteDataSource: AuthRemoteDataSourceImpl(
        dio: Dio(
          BaseOptions(
            connectTimeout: const Duration(seconds: 5),
            receiveTimeout: const Duration(seconds: 5),
          ),
        ),
      ),
    ),
    deviceStorage: Get.find<DeviceStorageService>(),
  ));
  await AuthService.init();

  bool isLoggedIn = AuthService.isLoggedIn();
  String? token = await AuthService.getAccessToken();
  String? userEmail = AuthService.getUserEmail();
  bool isTouchIDEnabled = AuthService.getTouchIDEnabled();
  String? savedPassword = await AuthService.getUserPassword();

  print('');
  print('═══════════════════════════════════════════════════');
  print('🚀 APP STARTING');
  print('═══════════════════════════════════════════════════');
  print('📊 Login Status: $isLoggedIn');
  print('🔑 Has Access Token: ${token != null}');
  print('📧 User Email: ${userEmail ?? "No email"}');
  print('👆 Touch ID Enabled: $isTouchIDEnabled');
  print('🔐 Has Saved Password: ${savedPassword != null}');
  print('═══════════════════════════════════════════════════');

  String initialRoute;

  if (isLoggedIn && token != null && token.isNotEmpty) {
    print('✅ Valid token found - Auto login to Home');
    initialRoute = AppRoutes.homeScreen;
  } else if (isTouchIDEnabled &&
      userEmail != null &&
      userEmail.isNotEmpty &&
      savedPassword != null &&
      savedPassword.isNotEmpty) {

    print('👆 Touch ID enabled - Going to Login screen for biometric');
    initialRoute = AppRoutes.loginAccount;
  } else {
    print('❌ No valid token - Going to splash/getStarted');
    initialRoute = AppRoutes.splashScreen;
  }

  print('═══════════════════════════════════════════════════');
  print('');

  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(440, 956),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: MediaQuery.of(context).textScaler.clamp(
                  minScaleFactor: 0.9,
                  maxScaleFactor: 1.15,
                ),
          ),
          child: GetMaterialApp(
            title: 'Right Routes',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: true,
              scaffoldBackgroundColor: const Color(0xFF0B1129),
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.deepPurple,
                brightness: Brightness.dark,
              ),
              appBarTheme: const AppBarTheme(
                systemOverlayStyle: SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent,
                  statusBarIconBrightness: Brightness.light,
                  statusBarBrightness: Brightness.dark,
                ),
              ),
            ),
            initialRoute: initialRoute,
            navigatorKey: Get.key,
            getPages: AppRoutes.routes,
            routingCallback: (routing) {
              if (routing != null && routing.current.isNotEmpty) {
                if (routing.isDialog != true && routing.isBottomSheet != true) {
                  final currentRoute = routing.current;
                  final persistableRoutes = [
                    AppRoutes.homeScreen,
                    AppRoutes.teamManager,
                    AppRoutes.accountScreen,
                    AppRoutes.historyScreen,
                    AppRoutes.confirmYourRoutes,
                    AppRoutes.createRouteAfterConfirmRoute,
                  ];
                  
                  if (persistableRoutes.contains(currentRoute)) {
                    try {
                      Map<String, dynamic>? args;
                      if (routing.args is Map) {
                        args = Map<String, dynamic>.from(routing.args as Map);
                      }
                      AuthService.saveLastRoute(currentRoute, arguments: args);
                    } catch (e) {
                      print('Could not save route args: $e');
                    }
                  }
                }
              }
            },
          ),
        );
      },
    );
  }
}
