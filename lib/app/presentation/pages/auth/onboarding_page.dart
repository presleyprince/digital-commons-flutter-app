import 'package:carousel_slider/carousel_slider.dart';
import 'package:digital_shores/app/presentation/provider/onboarding_notifier.dart';
import 'package:digital_shores/app/presentation/widgets/global/primary_elevated_button.dart';
import 'package:digital_shores/app/presentation/widgets/global/primary_outlined_button.dart';
import 'package:digital_shores/app/presentation/widgets/global/slider_indicator.dart';
import 'package:digital_shores/const/resource.dart';
import 'package:digital_shores/core/constants.dart';
import 'package:digital_shores/router.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  late OnboardingNotifier notifier;

  @override
  void initState() {
    notifier = Provider.of<OnboardingNotifier>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              // fix overflow: the carousel takes whatever height is left above
              // the buttons instead of a fixed 450, and each slide can scroll
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return CarouselSlider(
                    carouselController: notifier.carouselController,
                    items: notifier.carouselItems.map(
                      (carousel) {
                        return SingleChildScrollView(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 288,
                                  height: 194,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(kDefaultRadius),
                                    image: DecorationImage(
                                      image: AssetImage(carousel.image),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: kDefaultPadding,
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        carousel.title,
                                        style: kTitle4TextStyle,
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        carousel.description,
                                        style: kSubtitle5TextStyle,
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 36),
                                Image.asset(
                                  R.ASSETS_IMAGES_APP_LOGO_PNG,
                                  height: 60,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ).toList(),
                    options: CarouselOptions(
                      height: constraints.maxHeight,
                      viewportFraction: 1,
                      onPageChanged: notifier.onPageChanged,
                      autoPlay: true,
                      pageSnapping: true,
                      autoPlayCurve: Curves.fastOutSlowIn,
                    ),
                  );
                },
              ),
            ),
            ValueListenableBuilder<int>(
              valueListenable: notifier.currentPage,
              builder: (BuildContext context, int page, Widget? child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SliderIndicator(
                      page: 0,
                      currentPage: page,
                    ),
                    const SizedBox(width: 10),
                    SliderIndicator(
                      page: 1,
                      currentPage: page,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
              child: Column(
                children: [
                  PrimaryElevatedButton(
                    text: 'Masuk',
                    onPressed: () => router.go('/onboarding/login'),
                  ),
                  const SizedBox(height: 10),
                  PrimaryOutlinedButton(
                    text: 'Daftar Akun Baru',
                    onPressed: () => router.go('/onboarding/signup'),
                  ),
                  const SizedBox(height: 36),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}