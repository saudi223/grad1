import 'package:get/get.dart';
import 'package:graduate/auth/auth_service.dart';

class MyBinding extends Bindings{
  @override
  void dependencies() {
    Get.lazyPut(()=>AuthService());
  }
}