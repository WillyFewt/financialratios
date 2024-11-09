import 'package:catcher/catcher_plugin.dart';
import 'package:financialratios/app_model.dart';
import 'package:financialratios/screens/app_loading_screen.dart';
import 'package:financialratios/screens/app_splash_screen.dart';
import 'package:financialratios/screens/dashboard/dasboard_screen.dart';
import 'package:financialratios/screens/dashboard/dashboard_model.dart';
import 'package:financialratios/screens/login/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: Catcher.navigatorKey,
      builder: (BuildContext context, Widget widget) {
        Catcher.addDefaultErrorWidget(
            showStacktrace: false,
            customTitle: "An error has occured",
            customDescription: "Please contact application developer");
        return widget;
      },
      theme: ThemeData(
        primaryColor: Color(0xff0f75bc),
        primaryColorDark: Color(0xff0c5e96),
        primaryColorLight: Color(0xff3f91c9),
        scaffoldBackgroundColor: Color(0xffffffff),
        cardColor: Color(0xfffbfbff),
        fontFamily: 'Montserrat',
        textTheme: TextTheme(
          headline: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
          title: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
          body1: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
        ),
      ),
      home: Consumer<AppModel>(
        builder: (_, appModel, __) {
          switch (appModel.state) {
            case AppState.Started:
              return AppSplashScreen();
            case AppState.Loading:
              return AppLoadingScreen();
            case AppState.Authorized:
              return Consumer<DashboardModel>(
                  builder: (context, dashboardModel, child) {
                dashboardModel.user = appModel.user;
                return DashboardScreen();
              });
            default:
              return LoginScreen();
          }
        },
      ),
    );
  }
}
