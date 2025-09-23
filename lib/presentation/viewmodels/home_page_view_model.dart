import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ViewModel for HomePage - manages bottom navigation state
class HomePageViewModel extends StateNotifier<int> {
  HomePageViewModel() : super(0);

  /// Changes the selected tab index
  void changeTab(int index) {
    state = index;
  }

  /// Gets the current selected tab index
  int get selectedIndex => state;
}

/// Provider for HomePageViewModel
final homePageViewModelProvider = StateNotifierProvider<HomePageViewModel, int>((ref) {
  return HomePageViewModel();
});
