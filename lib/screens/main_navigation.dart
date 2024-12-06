import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/navigation_controller.dart';

class MainNavigation extends StatelessWidget {
  const MainNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());
    return Scaffold(
        body: Obx(() => controller.pages[controller.selectedIndex.value]),
        bottomNavigationBar: Obx(
          ()=> NavigationBar(
              selectedIndex: controller.selectedIndex.value,
              onDestinationSelected: (index) =>
                  controller.selectedIndex.value = index,
              destinations: const [
                NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
                NavigationDestination(
                    icon: Icon(Icons.download), label: 'Downloads'),
                NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
              ]),
        ));
  }
}
