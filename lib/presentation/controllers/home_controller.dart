import 'package:get/get.dart';

class HomeController extends GetxController {
  final selectedTab = 0.obs;

  void onTabChanged(int index) {
    selectedTab.value = index;
  }
}
