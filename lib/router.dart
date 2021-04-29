import 'package:flutter/material.dart';
import 'package:provider/Screen/History/history.dart';
import 'package:provider/Screen/Home/home.dart';
import 'package:provider/Screen/Login/login.dart';
import 'package:provider/Screen/MyProfile/myProfile.dart';
import 'package:provider/Screen/MyProfile/profile.dart';
import 'package:provider/Screen/MyWallet/myWallet.dart';
import 'package:provider/Screen/MyWallet/payment.dart';
import 'package:provider/Screen/Notification/notification.dart';
import 'package:provider/Screen/Request/request.dart';
import 'package:provider/Screen/Settings/settings.dart';
import 'package:provider/Screen/SignUp/signup2.dart';
import 'package:provider/Screen/UseMyLocation/useMyLocation.dart';
import 'package:provider/Screen/Walkthrough/walkthrough.dart';
import 'package:provider/Screen/SetStatusOnline/setStatusOnline.dart';
import 'package:provider/Screen/ProfileInformation/profileInfo.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyCustomRoute<T> extends MaterialPageRoute<T> {
  MyCustomRoute({WidgetBuilder builder, RouteSettings settings})
      : super(builder: builder, settings: settings);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
//    if (settings.isInitialRoute) return child;
    if (animation.status == AnimationStatus.reverse)
      return super
          .buildTransitions(context, animation, secondaryAnimation, child);
    return FadeTransition(opacity: animation, child: child);
  }
}

MaterialPageRoute getRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/lastlogin':
      return new MyCustomRoute(
        builder: (_) => new HomeScreen(),
        settings: settings,
      );
    case '/home':
      return new MyCustomRoute(
        builder: (_) => new HomeScreen(),
        settings: settings,
      );
    case '/signup2':
      return new MyCustomRoute(
        builder: (_) => new SignupScreen2(),
        settings: settings,
      );
    // case '/login':
    //   return new MyCustomRoute(
    //     builder: (_) => new LoginScreen(),
    //     settings: settings,
    //   );
    case '/walkthrough':
      return new MyCustomRoute(
        builder: (_) => new WalkthroughScreen(),
        settings: settings,
      );
    case '/use_my_location':
      return new MyCustomRoute(
        builder: (_) => new UseMyLocation(),
        settings: settings,
      );
    case '/set_status_online':
      return new MyCustomRoute(
        builder: (_) => new SetStatusOnline(),
        settings: settings,
      );
    case '/payment_method':
      return new MyCustomRoute(
        builder: (_) => new PaymentMethod(),
        settings: settings,
      );
    case '/request':
      return new MyCustomRoute(
        builder: (_) => new RequestScreen(),
        settings: settings,
      );
    case '/my_wallet':
      return new MyCustomRoute(
        builder: (_) => new MyWallet(),
        settings: settings,
      );
    case '/history':
      return new MyCustomRoute(
        builder: (_) => new HistoryScreen(),
        settings: settings,
      );
    case '/notification':
      return new MyCustomRoute(
        builder: (_) => new NotificationScreens(),
        settings: settings,
      );
    case '/setting':
      return new MyCustomRoute(
        builder: (_) => new SettingsScreen(),
        settings: settings,
      );
    case '/profile':
      return new MyCustomRoute(
        builder: (_) => new Profile(),
        settings: settings,
      );
    case '/edit_prifile':
      return new MyCustomRoute(
        builder: (_) => new MyProfile(),
        settings: settings,
      );
    case '/profile_setup':
      return new MyCustomRoute(
        builder: (_) => new ProfileSetupScreen(),
        settings: settings,
      );
    case '/logout':
      signOut();
      return new MyCustomRoute(
        builder: (_) => new SignupScreen2(),
        settings: settings,
      );
    default:
      return new MyCustomRoute(
        builder: (_) => new HomeScreen(),
        settings: settings,
      );
  }
}

Future signOut() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove('userID');
  prefs.clear();
}
