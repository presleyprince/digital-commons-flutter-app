import 'package:digital_shores/app/presentation/provider/administration_notifier.dart';
import 'package:digital_shores/app/presentation/provider/auth_notifier.dart';
import 'package:digital_shores/app/presentation/provider/finance_notifier.dart';
import 'package:digital_shores/app/presentation/provider/information_notifier.dart';
import 'package:digital_shores/app/presentation/provider/weather_notifier.dart';
import 'package:digital_shores/app/presentation/widgets/global/primary_elevated_button.dart';
import 'package:digital_shores/app/presentation/widgets/global/screen_dialog_loading_indicator.dart';
import 'package:digital_shores/app/presentation/widgets/global/transparent_app_bar.dart';
import 'package:digital_shores/app/presentation/widgets/profile/profile_information_box.dart';
import 'package:digital_shores/const/resource.dart';
import 'package:digital_shores/core/constants.dart';
import 'package:digital_shores/core/utils/custom_snackbar.dart';
import 'package:digital_shores/router.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late AuthNotifier notifier;

  @override
  void initState() {
    notifier = Provider.of<AuthNotifier>(context, listen: false);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthNotifier>(builder: (context, value, child) {
      final logoutState = value.logoutState;
      if (logoutState.stateError()) {
        CustomSnackbar.alert(context, logoutState.failure!.message);
      } else if (logoutState.stateSuccess()) {
        Provider.of<FinanceNotifier>(context, listen: false).deleteDataList();
        Provider.of<FinanceNotifier>(context, listen: false).clearFinanceLogsFromLocal();
        Provider.of<AdministrationNotifier>(context, listen: false).deleteDataList();
        Provider.of<AdministrationNotifier>(context, listen: false).clearDocumentsFromLocal();
        Provider.of<InformationNotifier>(context, listen: false).clearInformationsFromLocal();
        Provider.of<WeatherNotifier>(context, listen: false).clearInformationsFromLocal();
        Future.microtask(() => router.go('/onboarding'));
        CustomSnackbar.success(context, 'Berhasil logout');
      }

      return Stack(
        children: [
          Scaffold(
            appBar: TransparentAppBar(title: 'Profil'),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProfileInformationBox(notifier: notifier),
                    const SizedBox(height: 24),
                    PrimaryElevatedButton(
                      text: 'Keluar Akun',
                      image: R.ASSETS_ICONS_LOGOUT_PNG,
                      onPressed: () => notifier.logout(),
                    ),
                    const SizedBox(height: 24),
                    PrimaryElevatedButton(
                      text: 'Hapus Akun',
                      image: R.ASSETS_ICONS_DELETE_PNG,
                      red: true,
                      onPressed: () => router.go('/profile/delete'),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
          if (logoutState.stateLoading()) const ScreenDialogLoadingIndicator()
        ],
      );
    });
  }
}
