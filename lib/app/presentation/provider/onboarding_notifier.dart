import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_options.dart';
import 'package:digital_shores/app/domain/entities/onboarding_slider.dart';
import 'package:digital_shores/const/resource.dart';
import 'package:flutter/material.dart';

class OnboardingNotifier extends ChangeNotifier {
  late CarouselSliderController carouselController;
  late ValueNotifier<int> currentPage;

  OnboardingNotifier() {
    init();
  }

  final List<OnboardingSlider> carouselItems = [
    OnboardingSlider(
      image: R.ASSETS_IMAGES_ONBOARDING_1_PNG,
      title: '🌊 Solusi Digital untuk Nelayan dan\nPetani Rumput Laut',
      description:
          'Mudah akses informasi, kelola\nkeuangan, dan plot lahan rumput laut\n dalam satu aplikasi!',
    ),
    OnboardingSlider(
      image: R.ASSETS_IMAGES_ONBOARDING_2_JPG,
      title: '🌱 Bersama Membangun Masa\nDepan Laut yang Lebih Baik',
      description:
          'Jelajahi peluang baru untuk nelayan\ndan petani rumput laut dengan solusi\ndigital terbaik.',
    ),
  ];

  void init() {
    carouselController = CarouselSliderController();
    currentPage = ValueNotifier(0);
  }

  void onPageChanged(int page, CarouselPageChangedReason reason) {
    currentPage.value = page;
  }

  void changePageManual(int slide) {
    carouselController.animateToPage(
      slide,
      duration: const Duration(seconds: 2),
      curve: Curves.bounceIn,
    );
  }
}
