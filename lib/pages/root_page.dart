import 'package:flutter/material.dart';
import 'package:garage_opener_mobile_client/services/authentication.dart';
import 'package:garage_opener_mobile_client/services/shared_preferences.dart';

import 'home_page.dart';
import 'login_page.dart';

class RootPage extends StatefulWidget {
  RootPage({required this.auth});

  final BaseAuth auth;

  @override
  State<StatefulWidget> createState() => new _RootPageState();
}

enum AuthStatus {
  NOT_DETERMINED,
  NOT_LOGGED_IN,
  LOGGED_IN,
}

class _RootPageState extends State<RootPage> {
  AuthStatus authStatus = AuthStatus.NOT_DETERMINED;
  String? _userId;

  @override
  void initState() {
    super.initState();
    widget.auth.getCurrentUser().then((user) {
      setState(() {
        if (user != null) {
          _userId = user.uid;
        }
        authStatus =
            user == null ? AuthStatus.NOT_LOGGED_IN : AuthStatus.LOGGED_IN;
      });
    });
  }

  void _onLoggedIn() {
    widget.auth.getCurrentUser().then((user) {
      setState(() {
        _userId = user?.uid.toString();
      });
    });
    setState(() {
      authStatus = AuthStatus.LOGGED_IN;
    });
  }

  void _onSignedOut() {
    SharedPreferencesHelper.setUsername("").then((val) =>
        SharedPreferencesHelper.setPassword("").then((val) => setState(() {
              authStatus = AuthStatus.NOT_LOGGED_IN;
              _userId = "";
            })));
  }

  Widget _buildWaitingScreen() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (authStatus) {
      case AuthStatus.NOT_DETERMINED:
        return _buildWaitingScreen();
      case AuthStatus.NOT_LOGGED_IN:
        return new LoginPage(
          auth: widget.auth,
          onSignedIn: _onLoggedIn,
        );
      case AuthStatus.LOGGED_IN:
        if (_userId == null) {
          return new LoginPage(auth: widget.auth, onSignedIn: _onLoggedIn);
        }

        if (_userId!.length > 0) {
          return new HomePage(
            userId: _userId!,
            auth: widget.auth,
            onSignedOut: _onSignedOut,
          );
        }
        return _buildWaitingScreen();
      default:
        return _buildWaitingScreen();
    }
  }
}
