import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:garage_opener_mobile_client/services/authentication.dart';
import 'package:garage_opener_mobile_client/services/shared_preferences.dart';
import 'package:garage_opener_mobile_client/globals.dart' as globals;

class LoginPage extends StatefulWidget {
  LoginPage({required this.auth, required this.onSignedIn});

  final BaseAuth auth;
  final VoidCallback onSignedIn;

  @override
  State<StatefulWidget> createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = new GlobalKey<FormState>();

  String _email = "";
  String _password = "";
  String _errorMessage = "";
  String _server = "";

  bool _rememberUser = false;
  bool _rememberPassword = false;
  bool _isLoading = false;
  bool _isIos = false;

  @override
  Widget build(BuildContext context) {
    _isIos = Theme.of(context).platform == TargetPlatform.iOS;

    return new Scaffold(
        appBar: new AppBar(
          title: new Text('Garage Opener'),
        ),
        body: Stack(
          children: <Widget>[
            _showBody(),
          ],
        ));
  }

  Widget _showHeader() {
    return new Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
        child: Text.rich(
          TextSpan(
            children: <TextSpan>[
              TextSpan(
                  text: 'Login', style: TextStyle(fontWeight: FontWeight.bold))
            ],
          ),
          textAlign: TextAlign.center,
          textScaleFactor: 3.0,
        ));
  }

  Future<List<Object>> _getUserInfo() async {
    return [
      await SharedPreferencesHelper.getServerUrl(),
      await SharedPreferencesHelper.getUsername(),
      await SharedPreferencesHelper.getPassword(),
      await SharedPreferencesHelper.getRememberUser(),
      await SharedPreferencesHelper.getRememberPassword()
    ];
  }

  TextFormField buildTextFormField(
      {initialValue,
      hint,
      obscure,
      keyboardType,
      icon,
      validator,
      onSaved,
      inputFormatters}) {
    return new TextFormField(
      initialValue: initialValue,
      maxLines: 1,
      keyboardType: keyboardType,
      autofocus: false,
      obscureText: obscure,
      decoration: new InputDecoration(labelText: hint, icon: icon),
      validator: validator,
      onSaved: onSaved,
      inputFormatters: inputFormatters,
    );
  }

  Widget _buildUserFormItem(
      BuildContext context, int index, AsyncSnapshot snapshot) {
    TextFormField field;

    if (index == 0) {
      field = buildTextFormField(
          initialValue: snapshot.data[index] as String,
          hint: 'Server',
          obscure: false,
          keyboardType: TextInputType.url,
          icon: new Icon(
            Icons.cloud,
            color: Colors.grey,
          ),
          validator: (value) {
            if (value.isEmpty) {
              setState(() {
                _isLoading = false;
              });
              return 'Server can\'t be empty';
            }
          },
          onSaved: (value) {
            String val = value.toString();
            if (!val.contains(new RegExp(r'^[a-zA-Z]+:\/\/'))) {
              _server = 'http://$val';
            } else {
              _server = val;
            }
          });
    } else if (index == 1) {
      field = buildTextFormField(
          initialValue: snapshot.data[index] as String,
          hint: 'Email',
          keyboardType: TextInputType.emailAddress,
          obscure: false,
          icon: new Icon(
            Icons.mail,
            color: Colors.grey,
          ),
          validator: (value) {
            if (value.isEmpty) {
              setState(() {
                _isLoading = false;
              });
              return 'Email can\'t be empty';
            }
          },
          onSaved: (value) => _email = value.toString().trim());
    } else if (index == 2) {
      field = buildTextFormField(
          initialValue: snapshot.data[index] as String,
          hint: 'Password',
          keyboardType: null,
          obscure: true,
          icon: new Icon(
            Icons.lock,
            color: Colors.grey,
          ),
          validator: (value) {
            if (value.isEmpty) {
              setState(() {
                _isLoading = false;
              });
              return 'Password can\'t be empty';
            }
          },
          onSaved: (value) => _password = value.toString().trim());
    } else if (index == 3) {
      _rememberUser = snapshot.data[index] as bool;
      return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              'Remember User',
              textScaleFactor: 1,
            ),
            Checkbox(
                value: _rememberUser,
                onChanged: (value) {
                  setState(() {
                    _rememberUser = value != null ? value : false;
                  });
                })
          ]);
    } else if (index == 4) {
      _rememberPassword = snapshot.data[index] as bool;
      return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              'Remember Password',
              textScaleFactor: 1,
            ),
            Checkbox(
                value: _rememberPassword,
                onChanged: (value) {
                  setState(() {
                    _rememberPassword = value != null ? value : false;
                  });
                })
          ]);
    } else {
      throw new ArgumentError.value(index, "Index cannot be > 4");
    }

    return Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 5.0), child: field);
  }

  Widget _showInputs() {
    return FutureBuilder<List<Object>>(
        future: _getUserInfo(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
              shrinkWrap: true,
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) =>
                  _buildUserFormItem(context, index, snapshot));
        });
  }

/*
  Widget _showRememberChecks() {
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            'Remember User',
            textScaleFactor: 1,
          ),
          Checkbox(
              value: _rememberUser,
              onChanged: (value) {
                setState(() {
                  _rememberUser = value;
                });
              }),
          Text(
            'Remember Password',
            textScaleFactor: 1,
          ),
          Checkbox(
              value: _rememberPassword,
              onChanged: (value) {
                setState(() {
                  _rememberPassword = value;
                });
              })
        ]);
  }
  */

  Widget _showPrimaryButton() {
    return new Padding(
        padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0),
        child: SizedBox(
          height: 40.0,
          child: new ElevatedButton(style: ElevatedButton.styleFrom(
            elevation: 5.0,
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(10.0)),
            backgroundColor: Colors.blue),
            child: new Text('Login',
                style: new TextStyle(fontSize: 20.0, color: Colors.white)),
            onPressed: _validateAndSubmit,
          ),
        ));
  }

  Widget _showErrorMessage() {
    if (_errorMessage.length > 0) {
      return new Padding(
          padding: EdgeInsets.fromLTRB(40, 0.0, 0, 0),
          child: Text(
            _errorMessage,
            style: TextStyle(
                fontSize: 13.0,
                color: Colors.red,
                height: 1.0,
                fontWeight: FontWeight.bold),
          ));
    } else {
      return new Container(
        height: 0.0,
      );
    }
  }

  Widget _showBody() {
    if (!_isLoading) {
      return new Container(
          padding: EdgeInsets.all(16.0),
          child: new Form(
            key: _formKey,
            child: new ListView(
              shrinkWrap: true,
              children: <Widget>[
                _showHeader(),
                new ListView(
                  shrinkWrap: true,
                  children: <Widget>[
                    _showErrorMessage(),
                    _showInputs(),
                    _showPrimaryButton(),
                  ],
                )
              ],
            ),
          ));
    }
    return Center(child: CircularProgressIndicator());
  }

  bool _validateAndSave() {
    final form = _formKey.currentState;
    if (form == null) {
      return false;
    }

    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  Future<bool> _doRequest(server, idToken, {count = 0}) async {
    Uri uri = Uri.parse(server);

    final response = await http.post(uri, headers: {
      'X-Auth': idToken
    }).timeout(new Duration(seconds: globals.TIMEOUT));

    if (response.statusCode == 200) {
      await SharedPreferencesHelper.setRememberUser(_rememberUser);
      await SharedPreferencesHelper.setRememberPassword(_rememberPassword);
      await SharedPreferencesHelper.setServerUrl('${uri.origin}');

      if (_rememberUser!) {
        await SharedPreferencesHelper.setUsername(_email);
      } else {
        await SharedPreferencesHelper.setUsername("");
      }

      if (_rememberPassword!) {
        await SharedPreferencesHelper.setPassword(_password);
      } else {
        await SharedPreferencesHelper.setPassword("");
      }
      return true;
    } else if (response.statusCode >= 300 &&
        response.statusCode <= 399 &&
        count <= 3) {
      return await this
          ._doRequest(response.headers['location'], idToken, count: count + 1);
    } else if (response.statusCode == 403) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Unknown email or password';
      });
    } else if (response.statusCode == 404) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Server not found';
      });
    } else if (response.statusCode >= 500 && response.statusCode <= 599) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Something went wrong with your request';
      });
    }

    return false;
  }

  void _validateAndSubmit() async {
    setState(() {
      _errorMessage = "";
      _isLoading = true;
    });
    if (_validateAndSave()) {
      String userId = "";
      try {
        userId = await widget.auth.signIn(_email, _password);
        String? idToken = await widget.auth.getIdToken();
        if (idToken == null) {
          throw new Exception("Unable to login");
        }

        bool _success = await this._doRequest('$_server/login', idToken);

        if (_success) {
          setState(() {
            _isLoading = false;
          });
          if (userId.length > 0) {
            widget.onSignedIn();
          }
        }
      } catch (e) {
        print('Error: $e');
        await SharedPreferencesHelper.setRememberUser(false);
        await SharedPreferencesHelper.setRememberPassword(false);
        await SharedPreferencesHelper.setServerUrl("");
        await SharedPreferencesHelper.setUsername("");
        await SharedPreferencesHelper.setPassword("");
        setState(() {
          _isLoading = false;
          _errorMessage = 'An error has occurred with your request';
        });
      }
    }
  }

  @override
  void initState() {
    _errorMessage = "";
    _isLoading = false;
    super.initState();
  }
}
