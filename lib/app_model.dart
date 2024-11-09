import 'package:financialratios/exceptions/FirebaseException.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:financialratios/models/user.dart';
import 'package:financialratios/services/authorization_service.dart';
import 'package:flutter/services.dart';

enum AppState { Started, Loading, Authorized, Unauthorized }

class AppModel with ChangeNotifier {
  User _user;
  AppState _state = AppState.Started;

  AppModel() {
    _initialize();
  }

  User get user => _user;

  AppState get state => _state;

  void setUser(User user) => _user = user;

  Future _initialize() async {
    await Future.delayed(Duration(seconds: 4), () {});
    _state = AppState.Loading;
    notifyListeners();
    await Future.delayed(Duration(seconds: 2), () {});
    await _getExistingUser();
    notifyListeners();
  }

  void userLoggedIn(User user) {
    _user = user;
    _state = AppState.Authorized;
    notifyListeners();
  }

  void userLoggedOut() {
    AuthorizationService.instance.logout();
    _user = null;
    _state = AppState.Unauthorized;
    notifyListeners();
  }

  Future _getExistingUser() async {
    User user = await AuthorizationService.instance.getUser();
    if (user != null) {
      userLoggedIn(user);
    } else {
      userLoggedOut();
    }
  }

  Future<void> changePassword(
      String email, String oldPassword, String newPassword) async {
    try {
      FirebaseUser user = await AuthorizationService.instance
          .reauthenticate(email, oldPassword);
      await user.updatePassword(newPassword);
    } on PlatformException catch (e) {
      String errorMessage =
          'Please check your internet connection.\nIf the error persist please contact developer team';
      switch (e.code) {
        case "ERROR_INVALID_EMAIL":
          errorMessage = "Invalid email address.";
          break;
        case "ERROR_WRONG_PASSWORD":
          errorMessage = "Current password is wrong";
          break;
        case "ERROR_USER_NOT_FOUND":
          errorMessage = "User not found";
          break;
        case "ERROR_USER_DISABLED":
          errorMessage = "User was disabled, please contact admin";
          break;
        case "ERROR_TOO_MANY_REQUESTS":
          errorMessage =
              "Too many failed request, please try again after few minutes";
          break;
        case "ERROR_OPERATION_NOT_ALLOWED":
          errorMessage = "Operation not allowed";
          break;
        case "ERROR_WEAK_PASSWORD":
          errorMessage = "Password too weak";
          break;
        case "ERROR_REQUIRES_RECENT_LOGIN":
          errorMessage =
              "Change password request failed, please relogin first and try again";
          break;
      }
      throw FirebaseException(errorMessage);
    }
  }
}
