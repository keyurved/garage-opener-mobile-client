import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:garage_opener_mobile_client/globals.dart' as globals;
import 'package:flutter/widgets.dart';
import 'package:garage_opener_mobile_client/entities/garage.dart';
import 'package:http/http.dart' as http;

class GarageWidget extends StatefulWidget {
  GarageWidget({Key key, this.idToken, this.garageId}) : super(key: key);

  final Future<String> idToken;
  final int garageId;

  @override
  State<StatefulWidget> createState() => new _GarageWidgetState();
}

class _GarageWidgetState extends State<GarageWidget> {
  bool _isLoading = false;
  String _error;
  Garage garage;

  _getGarageStatus() async {
    setState(() {
      _error = null;
      _isLoading = true;
    });

    try {
      final response = await http
          .get('${globals.SERVER_URL}/garage/${widget.garageId}', headers: {
        'X-Auth': await widget.idToken
      }).timeout(new Duration(seconds: 10));

      if (response.statusCode == 200) {
        garage = Garage.fromJson(json.decode(response.body));

        setState(() {
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response.reasonPhrase;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Connection timeout';
        _isLoading = false;
      });
    }
  }

  @override
  initState() {
    super.initState();
    _error = null;
    _getGarageStatus();
  }

  _toggleGarage() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    String url = '${globals.SERVER_URL}/garage/';

    if (garage.state == GarageState.CLOSED) {
      url += 'open/';
    } else {
      url += 'close/';
    }
    url += garage.garageNum.toString();

    final response =
        await http.post(url, headers: {'X-Auth': await widget.idToken});

    if (response.statusCode == 200) {
      garage.updateFromJson(json.decode(response.body));

      setState(() {
        _isLoading = false;
      });
    } else {
      setState(() {
        _error = response.reasonPhrase;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else if (_error == null) {
      return ListView(
        children: <Widget>[
          Text(
            "Garage ${garage.garageNum} is ${garage.getGarageStatus()}.",
          ),
          Padding(
              padding: EdgeInsets.fromLTRB(10.0, 45.0, 10.0, 0.0),
              child: SizedBox(
                  height: 40.0,
                  child: new RaisedButton(
                    elevation: 5.0,
                    shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30.0)),
                    color: Colors.blue,
                    child: Text(
                      garage.state == GarageState.CLOSED ? 'Open' : 'Close',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: _toggleGarage,
                  )))
        ],
      );
    }
    return ListView(children: <Widget>[
      Center(child: Text(_error, style: TextStyle(color: Colors.red))),
      Padding(
          padding: EdgeInsets.fromLTRB(10.0, 45.0, 10.0, 0.0),
          child: SizedBox(
              height: 40.0,
              child: new RaisedButton(
                elevation: 5.0,
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(30.0)),
                color: Colors.blue,
                child: Text(
                  'Refresh',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: _getGarageStatus,
              )))
    ]);
  }
}
