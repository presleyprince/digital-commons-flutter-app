import 'package:digital_shores/app/presentation/provider/auth_notifier.dart';
import 'package:digital_shores/app/presentation/widgets/global/digital_shores_introduction_column.dart';
import 'package:digital_shores/app/presentation/widgets/home/home_digital_shores.dart';
import 'package:digital_shores/app/presentation/widgets/home/home_latest_information_section.dart';
import 'package:digital_shores/const/resource.dart';
import 'package:digital_shores/core/constants.dart';
import 'package:digital_shores/router.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:digital_shores/app/presentation/provider/weather_notifier.dart';
import 'package:digital_shores/app/presentation/theme/role_theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<WeatherNotifier>(context, listen: false).init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthNotifier>(
      builder: (context, notifier, child) {
        final role = notifier.userData?.role;

        return Theme(
          data: withRoleColor(context, role),
          child: Scaffold(
            body: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: kDefaultPadding),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: kDefaultPadding),
                      child: DigitalShoresIntroductionColumn(titleBlue: false),
                    ),
                    Consumer<AuthNotifier>(
                      builder: (context, notifier, child) {
                        final isAdmin = notifier.userData?.isAdmin ?? false;

                        if (!isAdmin) return SizedBox();
                        final color = Theme.of(context).colorScheme;

                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: kDefaultPadding),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Selamat Datang, Penyuluh!', style: kTitle5TextStyle),
                              const SizedBox(height: 16),
                              Text(
                                'Bagikan kabar terbaru dan informasi penting kepada semua pengguna $kAppName.',
                                style: kSubtitle5TextStyle,
                                textAlign: TextAlign.justify,
                              ),
                              const SizedBox(height: 16),
                              Center(
                                child: InkWell(
                                  onTap: () => router.push('/home/add-information'),
                                  borderRadius: BorderRadius.circular(8),
                                  splashColor: Colors.grey.withValues(alpha: 0.3),
                                  highlightColor: Colors.grey.withValues(alpha: 0.1),
                                  child: Container(
                                    color: Colors.transparent,
                                    child: Column(
                                      children: [
                                        Image.asset(
                                          R.ASSETS_ICONS_ADD_INFORMATION_PNG,
                                          width: 64,
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: color.primary,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          child: Text(
                                            "Bagikan Berita",
                                            style: kTitle7TextStyle.copyWith(color: color.onPrimary),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        );
                      },
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: kDefaultPadding),
                      child: HomeDigitalShoresMenu(),
                    ),
                    HomeLatestInformationSection(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
