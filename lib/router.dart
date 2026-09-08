import 'package:digital_shores/app/presentation/pages/administration/add_administration_page.dart';
import 'package:digital_shores/app/presentation/pages/administration/administration_page.dart';
import 'package:digital_shores/app/presentation/pages/auth/login_page.dart';
import 'package:digital_shores/app/presentation/pages/auth/onboarding_page.dart';
import 'package:digital_shores/app/presentation/pages/auth/otp_page.dart';
import 'package:digital_shores/app/presentation/pages/auth/signup_page.dart';
import 'package:digital_shores/app/presentation/pages/auth/splash_screen.dart';
import 'package:digital_shores/app/presentation/pages/finance/edit_finance_history_page.dart';
import 'package:digital_shores/app/presentation/pages/finance/my_finance_history_page.dart';
import 'package:digital_shores/app/presentation/pages/finance/my_finance_page.dart';
import 'package:digital_shores/app/presentation/pages/home_page.dart';
import 'package:digital_shores/app/presentation/pages/information/add_information_page.dart';
import 'package:digital_shores/app/presentation/pages/information/information_detail_page.dart';
import 'package:digital_shores/app/presentation/pages/information/information_page.dart';
import 'package:digital_shores/app/presentation/pages/plot/my_plot_page.dart';
import 'package:digital_shores/app/presentation/pages/plot/saved_plot_detail_page.dart';
import 'package:digital_shores/app/presentation/pages/plot/saved_plots_page.dart';
import 'package:digital_shores/app/presentation/pages/plot/plot_form.dart';
import 'package:digital_shores/app/presentation/pages/plot/plot_overview_page.dart';
import 'package:digital_shores/app/presentation/pages/profile/delete_account_otp_page.dart';
import 'package:digital_shores/app/presentation/pages/profile/delete_account_page.dart';
import 'package:digital_shores/app/presentation/pages/profile/edit_profile_page.dart';
import 'package:digital_shores/app/presentation/pages/profile/profile_page.dart';
import 'package:digital_shores/app/presentation/pages/scaffold_with_navbar.dart';
import 'package:digital_shores/app/presentation/pages/weather_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:digital_shores/app/presentation/pages/plot/gps_record_page.dart';
import 'package:digital_shores/app/presentation/pages/seaweed_farmer_home.dart';
// add import to the new verify plots page for secretaries
import 'package:digital_shores/app/presentation/pages/plot/verify_plots_page.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _sectionNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  initialLocation: '/',
  navigatorKey: _rootNavigatorKey,
  // errorBuilder: (context, state) => const NotFoundPage(),
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      name: 'onboarding',
      path: '/onboarding',
      builder: (context, state) => const OnboardingPage(),
      routes: [
        GoRoute(
          // parentNavigatorKey: _sectionNavigatorKey,
          path: 'otp',
          builder: (context, state) => const OtpPage(),
        ),
        GoRoute(
          path: 'login',
          builder: (context, state) => const LoginPage(),
          // routes: [
          //   GoRoute(
          //     path: 'forgot-password',
          //     builder: (context, state) => const ForgotPasswordPage(),
          //   ),
          // ],
        ),
        GoRoute(
          path: 'signup',
          builder: (context, state) => const SignupPage(),
        ),
      ],
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        // main page will have navbar
        if (state.fullPath == '/home' || state.fullPath == '/seaweed-home' ||
            state.fullPath == '/my-finance' || state.fullPath == '/information' ||
            state.fullPath == '/profile') {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        }
        // other page will not have navbar
        return Scaffold(
          body: Center(
            child: Container(
              constraints: const BoxConstraints(
                maxWidth: 480,
              ),
              child: navigationShell,
            ),
          ),
        );
      },
      branches: [
        StatefulShellBranch(
          navigatorKey: _sectionNavigatorKey,
          routes: [
            GoRoute(
            path: '/verify-plots',
            builder: (context, state) => const VerifyPlotsPage(),
            ),
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomePage(),
              routes: [
                GoRoute(
                  path: 'information',
                  builder: (context, state) {
                    return const InformationPage();
                  },
                  
                  routes: [
                    GoRoute(
                      path: 'detail',
                      builder: (context, state) => InformationDetailPage(),
                    ),
                  ],
                ),
                GoRoute(
                  parentNavigatorKey: _sectionNavigatorKey,
                  path: 'add-information',
                  builder: (context, state) {
                    return const AddInformationPage();
                  },
                ),
                  //removed sea disucssion page route
                GoRoute(
                  path: 'my-plot',
                  builder: (context, state) {
                    return const MyPlotPage();
                  },
                ),
                GoRoute(
                  path: 'gps-test',
                  builder: (context, state) => const GpsRecordPage(),
                ),
                GoRoute(
                  path: 'saved-plots',
                  builder: (context, state) => const SavedPlotsPage(),
                  routes: [
                    GoRoute(
                      path: ':id',
                      builder: (context, state) => SavedPlotDetailPage(
                        plotId: state.pathParameters['id']!,
                      ),
                      routes: [
                        GoRoute(
                          path: 'form',
                          builder: (context, state) => PlotFormPage(
                            plotId: state.pathParameters['id']!,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                GoRoute(
                  path: 'plot-overview',
                  builder: (context, state) => const PlotOverviewPage(),
                ),
                GoRoute(
                  path: 'my-finance',
                  parentNavigatorKey: _sectionNavigatorKey,
                  builder: (context, state) {
                    return MyFinancePage();
                  },
                ),
                GoRoute(
                      path: 'seaweed-home',
                      builder: (context, state) => const SeaweedFarmerHome(),
                    ),
                GoRoute(
                  path: 'weather',
                  builder: (context, state) {
                    return WeatherPage();
                  },
                ),
                GoRoute(
                  path: 'my-finance-history',
                  builder: (context, state) => const MyFinanceHistoryPage(),
                  parentNavigatorKey: _sectionNavigatorKey,
                  routes: [
                    GoRoute(
                      path: 'edit/:id',
                      builder: (context, state) {
                        final id = state.pathParameters['id']!;
                        return EditFinanceHistoryPage(id: id);
                      },
                    ),
                  ],
                ),
                GoRoute(
                  path: 'administration',
                  builder: (context, state) {
                    return const AdministrationPage();
                  },
                  routes: [
                    GoRoute(
                      path: 'add',
                      builder: (context, state) {
                        return AddAdministrationPage();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/seaweed-home',
              builder: (context, state) => const SeaweedFarmerHome(),
              ),
            ],
          ),
        
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/my-finance',
              builder: (context, state) => MyFinancePage(),
            ),
          ],
        ),

        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/information',
              builder: (context, state) => const InformationPage(),
              routes: [
                GoRoute(
                  path: 'detail',
                  builder: (context, state) => InformationDetailPage(),
                ),
              ],
            ),
          ],
        ),


        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfilePage(),
              routes: [
                GoRoute(
                  path: 'edit',
                  builder: (context, state) => const EditProfilePage(),
                ),
                GoRoute(
                  path: 'delete',
                  builder: (context, state) => const DeleteAccountPage(),
                  routes: [
                    GoRoute(
                      path: 'otp',
                      builder: (context, state) => const DeleteAccountOtpPage(),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    // GoRoute(
    //   path: '/image',
    //   parentNavigatorKey: _rootNavigatorKey,
    //   builder: (context, state) {
    //     final image = state.extra as String;
    //     return ImageDetailPage(imagePath: image);
    //   },
    // ),
  ],
);
