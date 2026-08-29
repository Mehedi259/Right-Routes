import 'package:get/get.dart';
import 'package:right_routes/views/home/create_new_routes/confirm_your_routes/confirm_controller.dart';

class EditConfirmRouteBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ConfirmRouteController>(
          () => ConfirmRouteController(),
      fenix: true,
    );
  }
}
