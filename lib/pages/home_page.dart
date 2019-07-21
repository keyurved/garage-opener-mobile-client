import 'package:flutter/material.dart';
import 'package:garage_opener_mobile_client/pages/settings_page.dart';
import 'package:garage_opener_mobile_client/services/authentication.dart';
import 'package:garage_opener_mobile_client/services/shared_preferences.dart';
import 'package:garage_opener_mobile_client/widgets/garage_widget.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.auth, this.userId, this.onSignedOut})
      : super(key: key);

  final BaseAuth auth;
  final VoidCallback onSignedOut;
  final String userId;

  @override
  State<StatefulWidget> createState() => new _HomePageState();
}

enum PopupOptions { logout }

class _HomePageState extends State<HomePage> {
  GlobalKey<GarageWidgetState> _widget1Key = GlobalKey();
  GlobalKey<GarageWidgetState> _widget2Key = GlobalKey();

  Future<void> _refreshGarages() async {
    _widget1Key.currentState.getGarageStatus();
    _widget2Key.currentState.getGarageStatus();
  }

  _constructBody() {
    final idToken = widget.auth.getIdToken();
    final Future<String> url = SharedPreferencesHelper.getServerUrl();
    final Future<int> delay = SharedPreferencesHelper.getDelay();

    return new RefreshIndicator(
        child: Flex(
          children: <Widget>[
            Expanded(
                child: GarageWidget(
                    key: _widget1Key,
                    garageId: 1,
                    idToken: idToken,
                    serverUrl: url,
                    delay: delay)),
            Expanded(
                child: GarageWidget(
                    key: _widget2Key,
                    garageId: 2,
                    idToken: idToken,
                    serverUrl: url,
                    delay: delay)),
          ],
          direction: Axis.vertical,
        ),
        onRefresh: _refreshGarages);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text('Garage Opener'),
          actions: <Widget>[
            new IconButton(
              icon: new Icon(Icons.refresh, color: Colors.white),
              onPressed: _refreshGarages,
            ),
            new IconButton(
              icon: new Icon(
                Icons.settings,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SettingsPage(
                              auth: widget.auth,
                              onSignedOut: widget.onSignedOut,
                            )));
              },
            ),
            PopupMenuButton<PopupOptions>(
                onSelected: (PopupOptions option) {
                  switch (option) {
                    case PopupOptions.logout:
                      widget.onSignedOut();
                      break;
                  }
                },
                itemBuilder: (BuildContext context) =>
                    <PopupMenuEntry<PopupOptions>>[
                      const PopupMenuItem<PopupOptions>(
                          value: PopupOptions.logout, child: Text('Logout'))
                    ])
          ],
        ),
        body: _constructBody());
  }
}
