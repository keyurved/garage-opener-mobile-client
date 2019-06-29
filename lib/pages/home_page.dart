import 'package:garage_opener_mobile_client/globals.dart' as globals;
import 'package:flutter/material.dart';
import 'package:garage_opener_mobile_client/services/authentication.dart';
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

class _HomePageState extends State<HomePage> {
  void _signOut() async {
    try {
      await widget.auth.signOut();
      widget.onSignedOut();
    } catch (e) {
      print(e);
    }
  }

  _constructBody() {
    final idToken = widget.auth.getIdToken();
    return new Column(
      children: <Widget>[
        Expanded(
          child: GarageWidget(
            garageId: 1,
            idToken: idToken,
          ),
        ),
        Expanded(
            child: GarageWidget(
          garageId: 2,
          idToken: idToken,
        ))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text('Garage Opener'),
          actions: <Widget>[
            new FlatButton(
                child: new Text('Logout',
                    style: new TextStyle(fontSize: 17.0, color: Colors.white)),
                onPressed: _signOut)
          ],
        ),
        body: _constructBody());
  }
}
