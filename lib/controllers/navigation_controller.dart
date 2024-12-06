import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../screens/dashboard.dart';
import '../screens/downloads.dart';
import '../screens/profile.dart';

class NavigationController extends GetxController {
  var selectedIndex = 0.obs;

  final List<Widget> pages = const [
    DashboardScreen(),
    DownloadScreen(),
    ProfileScreen(),
  ];

  void changePage(int index) {
    selectedIndex.value = index;
  }

  void resetPage() {
    selectedIndex.value = 0;
  }
} 