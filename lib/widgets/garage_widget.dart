import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:garage_opener_mobile_client/entities/garage.dart';
import 'package:garage_opener_mobile_client/globals.dart' as globals;

class GarageWidget extends StatefulWidget {
  GarageWidget({Key key, this.idToken, this.garageId, this.serverUrl, this.delay})
      : super(key: key);
  final Future<String> idToken;
  final Future<String> serverUrl;
  final Future<int> delay;
  final int garageId;

  @override
  State<StatefulWidget> createState() => new GarageWidgetState();
}

class GarageWidgetState extends State<GarageWidget> {
  bool _isLoading = false;
  String _error;
  Garage garage;

  getGarageStatus() async {

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http
          .get('${await widget.serverUrl}/garage/${widget.garageId}', headers: {
        'X-Auth': await widget.idToken
      }).timeout(new Duration(seconds: globals.TIMEOUT));

      if (response.statusCode == 200) {
        garage.updateFromJson(json.decode(response.body));

        setState(() {
          _error = null;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response.reasonPhrase;
          _isLoading = false;
        });
      }
    } catch (e) {
      print(e.toString());
      setState(() {
        _error = 'Could not connect to Garage ${widget.garageId}';
        _isLoading = false;
      });
    }
  }

  _toggleGarage() async {
    int timeout = globals.TIMEOUT;
    int delay = await widget.delay;

    if (delay > timeout) {
      timeout = delay + 10;
    }
    setState(() {
      _isLoading = true;
    });

    String url = '${await widget.serverUrl}/garage/';

    if (garage.state == GarageState.CLOSED) {
      url += 'open/';
    } else {
      url += 'close/';
    }
    url += garage.garageNum.toString();

  try {
    final response = await http.post(url, headers: {
      'X-Auth': await widget.idToken,
      'Delay': (await widget.delay).toString()
    }).timeout(new Duration(seconds:timeout));

    if (response.statusCode == 200) {
      garage.updateFromJson(json.decode(response.body));

      if (this.mounted) {
        setState(() {
          _error = null;
          _isLoading = false;
        });
      }
    } else {
      if (this.mounted) {
        setState(() {
          _error = response.reasonPhrase;
          _isLoading = false;
        });
      }
    }
  } catch (e) {
      print(e.toString());
      setState(() {
        _error = 'Could not connect to Garage ${widget.garageId}';
        _isLoading = false;
      });

  }
  }

  @override
  initState() {
    super.initState();
    garage = new Garage(garageNum: widget.garageId);
    _error = null;
    getGarageStatus();
  }

  _createRaisedButton(text, onPressed) {
    return Padding(
        padding: EdgeInsets.fromLTRB(10.0, 45.0, 10.0, 0.0),
        child: SizedBox(
            height: 40.0,
            child: new RaisedButton(
              elevation: 5.0,
              shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(30.0)),
              color: Colors.blue,
              child: Text(
                text,
                style: TextStyle(color: Colors.white),
              ),
              onPressed: onPressed,
            )));
  }

  _showToggleButton() {
    if (_isLoading) {
      return Padding(
          padding: EdgeInsets.fromLTRB(0, 45, 0, 0),
          child: Center(
            child: CircularProgressIndicator(),
          ));
    } else if (_error == null) {
      return _createRaisedButton(
          garage.state == GarageState.CLOSED ? 'Open' : 'Close', _toggleGarage);
    } else {
      return _createRaisedButton('Refresh', getGarageStatus);
    }
  }

  @override
  Widget build(BuildContext context) {
    String text = _error;

    if (text == null) {
      text = "Garage ${garage.garageNum} is ${garage.getGarageStatus()}.";
    }

    return Padding(
        padding: EdgeInsets.fromLTRB(0, 40, 0, 0),
        child: ListView(
          children: <Widget>[
            Center(
                child: Text(
              text,
              style: TextStyle(fontSize: 20),
            )),
            _showToggleButton()
          ],
        ));
  }
}
