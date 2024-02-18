import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:garage_opener_mobile_client/entities/garage.dart';
import 'package:garage_opener_mobile_client/globals.dart' as globals;

class GarageWidget extends StatefulWidget {
  GarageWidget({required Key key, required this.idToken, required this.garageId, required this.serverUrl, required this.delay})
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
  String? _error;
  Garage? garage;

  getGarageStatus() async {

    setState(() {
      _isLoading = true;
    });

    try {
      Uri uri = Uri.parse('${await widget.serverUrl}/garage/${widget.garageId}');
      final response = await http
          .get(uri, headers: {
        'X-Auth': await widget.idToken
      }).timeout(new Duration(seconds: globals.TIMEOUT));

      if (response.statusCode == 200) {
        if (garage == null) {
          garage = Garage.fromJson(json.decode(response.body));
        } else {
          garage!.updateFromJson(json.decode(response.body));
        }

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
    if (garage == null) {
      return;
    }

    if (delay > timeout) {
      timeout = delay + 10;
    }
    setState(() {
      _isLoading = true;
    });

    String url = '${await widget.serverUrl}/garage/';

    if (garage!.state == GarageState.CLOSED) {
      url += 'open/';
    } else {
      url += 'close/';
    }
    url += garage!.garageNum.toString();

    Uri urlAsUri = Uri.parse(url);

  try {
    final response = await http.post(urlAsUri, headers: {
      'X-Auth': await widget.idToken,
      'Delay': (await widget.delay).toString()
    }).timeout(new Duration(seconds:timeout));

    if (response.statusCode == 200) {
      garage!.updateFromJson(json.decode(response.body));

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
    final ButtonStyle style = ElevatedButton.styleFrom(backgroundColor: Colors.blue,
        textStyle: const TextStyle(color: Colors.white),
        elevation: 5.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)));

    return Padding(
        padding: EdgeInsets.fromLTRB(10.0, 45.0, 10.0, 0.0),
        child: SizedBox(
            height: 40.0,
            child: new ElevatedButton(
              style: style,
              child: Text(
                text,
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
    } else    return _createRaisedButton('Refresh', getGarageStatus);
  
  }

  @override
  Widget build(BuildContext context) {
    String text = _error ?? "";

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
