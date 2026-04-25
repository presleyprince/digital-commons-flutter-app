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

  Widget _buildAvatar(String? fullName) {
    final initials = (fullName ?? '') // use empty string if no name
    .trim() // remove extra spaces
    .split(' ') // split into words
    .where((e) => e.isNotEmpty) // removing empty words
    .map((e) => e[0].toUpperCase()) // take the first letter of each word
    .take(2) // max 2 intitals
    .join(); // combining to one string e.g "BS"

    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: Colors.blue.shade100,
            child: Text(
              initials.isEmpty ? '?' : initials, // show question mark ? if no name
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                color: Colors.blue,
              ),
            ),
          ),
          const SizedBox(height: 8), // gap between circle and name
          Text(
            fullName ?? '',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
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
                    _buildAvatar(notifier.userData?.fullName), // adding initials as profile pic, reaches into AuthNotifer to get the current log in details, ? takes it if it exists only
                    const SizedBox(height: 16),
                    ProfileInformationBox(notifier: notifier),
                    const SizedBox(height: 24),

                    // adding Settings section to seperate delete account and login
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Theme.of(context).colorScheme.primary),
                        borderRadius: BorderRadius.circular(kDefaultRadius),
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            title: const Text('Bahasa'), // lanaguge button for future
                            trailing: const Icon(Icons.chevron_right), // arrow on the right side of the rows
                            onTap: () => router.go('/profile/language'),
                          ),
                          Divider(height: 1, color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
                          ListTile(
                            title: Text(
                              'Hapus Akun', // delete account button
                              style: TextStyle(color: Theme.of(context).colorScheme.error), // use error. to make it red so it stands out
                            ),
                            trailing: Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.error),
                            onTap: () => router.go('/profile/delete'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // keeping logout away from the rest 
                    PrimaryElevatedButton(
                      text: 'Keluar Akun',
                      image: R.ASSETS_ICONS_LOGOUT_PNG,
                      onPressed: () => notifier.logout(),
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
