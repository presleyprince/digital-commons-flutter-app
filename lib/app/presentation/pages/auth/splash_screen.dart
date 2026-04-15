import 'package:digital_shores/app/presentation/provider/administration_notifier.dart';
import 'package:digital_shores/app/presentation/provider/auth_notifier.dart';
import 'package:digital_shores/app/presentation/provider/finance_notifier.dart';
import 'package:digital_shores/app/presentation/provider/information_notifier.dart';
import 'package:digital_shores/const/resource.dart';
import 'package:digital_shores/router.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late AuthNotifier notifier;

  @override
  initState() {
    super.initState();
    notifier = Provider.of<AuthNotifier>(context, listen: false);

    Future.delayed(
      const Duration(seconds: 2),
      () {
        notifier.getUserFromLocal();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AuthNotifier>(
        builder: (context, value, child) {
          final state = value.state;
          if (state.stateError()) {
            Future.microtask(() => router.go('/onboarding'));
          } else if (state.stateSuccess()) {
            Provider.of<FinanceNotifier>(context, listen: false).getDataFromLocal();
            Provider.of<AdministrationNotifier>(context, listen: false).getDataFromLocal();
            Provider.of<InformationNotifier>(context, listen: false).getDataFromLocal();
            Future.microtask(() => router.go('/home'));
          }
          return SafeArea(
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    R.ASSETS_IMAGES_APP_LOGO_PNG,
                    width: 250,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
