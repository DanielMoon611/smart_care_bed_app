import 'package:flutter/material.dart';
import 'routes.dart';
import 'shell.dart';

import 'package:smart_care_bed_app/layout/home.dart';
import 'package:smart_care_bed_app/layout/body_pressure_distribution.dart';
import 'package:smart_care_bed_app/layout/alternating_pressure.dart';
import 'package:smart_care_bed_app/layout/massage.dart';
import 'package:smart_care_bed_app/layout/patient_care.dart';

import 'package:smart_care_bed_app/layout/settings/setup.dart';
import 'package:smart_care_bed_app/layout/settings/language.dart';
import 'package:smart_care_bed_app/layout/settings/ble_connect.dart';
import 'package:smart_care_bed_app/layout/settings/user_check.dart';
import 'package:smart_care_bed_app/layout/settings/user_info.dart';
import 'package:smart_care_bed_app/layout/settings/stt.dart';
import 'package:smart_care_bed_app/layout/settings/bgm.dart';
import 'package:smart_care_bed_app/layout/settings/log.dart';
import 'package:smart_care_bed_app/layout/settings/manual.dart';
import 'package:smart_care_bed_app/layout/settings/self_test.dart';
import 'package:smart_care_bed_app/layout/settings/help.dart';
import 'package:smart_care_bed_app/layout/settings/reset.dart';

class NoTransitionsBuilder extends PageTransitionsBuilder {
  const NoTransitionsBuilder();
  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Care Bed',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.iOS: NoTransitionsBuilder(),
            TargetPlatform.android: NoTransitionsBuilder(),
            TargetPlatform.macOS: NoTransitionsBuilder(),
            TargetPlatform.windows: NoTransitionsBuilder(),
            TargetPlatform.linux: NoTransitionsBuilder(),
          },
        ),
      ),
      onGenerateRoute: _onGenerate,
      initialRoute: AppRoutes.home,
    );
  }

  Route<dynamic> _onGenerate(RouteSettings settings) {
    Widget page;
    switch (settings.name) {
      case AppRoutes.home:
        page = const HomePage();
        break;
      case AppRoutes.bodyPressure:
        page = const BodyPressureDistributionPage();
        break;
      case AppRoutes.alternatingPressure:
        page = const AlternatingPressurePage();
        break;
      case AppRoutes.massage:
        page = const MassagePage();
        break;
      case AppRoutes.patientCare:
        page = const PatientCarePage();
        break;
      case AppRoutes.setup:
        page = const SetupPage();
        break;
      case AppRoutes.language:
        page = const LanguagePage();
        break;
      case AppRoutes.bleConnect:
        page = const BleConnectPage();
        break;
      case AppRoutes.userCheck:
        page = const UserCheckPage();
        break;
      case AppRoutes.userInfo:
        page = const UserInfoPage();
        break;
      case AppRoutes.stt:
        page = const SttPage();
        break;
      case AppRoutes.bgm:
        page = const BgmPage();
        break;
      case AppRoutes.log:
        page = const LogPage();
        break;
      case AppRoutes.manual:
        page = const ManualPage();
        break;
      case AppRoutes.selfTest:
        page = const SelfTestPage();
        break;
      case AppRoutes.help:
        page = const HelpPage();
        break;
      case AppRoutes.reset:
        page = const ResetPage();
        break;
      default:
        page = const HomePage();
    }

    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, _, _) => ControlPanelShell(child: page),
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
    );
  }
}
