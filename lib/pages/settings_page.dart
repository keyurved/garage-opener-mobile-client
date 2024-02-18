import 'package:flutter/material.dart';
import 'package:garage_opener_mobile_client/services/authentication.dart';
import 'package:garage_opener_mobile_client/services/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({Key? key, required this.auth, required this.onSignedOut}) : super(key: key);
  final BaseAuth auth;
  final VoidCallback onSignedOut;

  @override
  State<StatefulWidget> createState() => new _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _formKey = new GlobalKey<FormState>();
  final snackBar = SnackBar(content: Text('Settings saved'));
  bool _isLoading = false;
  bool _isSaving = false;
  bool _isSaved = false;
  int _delay = 7;

  void _signOut() async {
    try {
      await widget.auth.signOut();
      widget.onSignedOut();
    } catch (e) {
      print(e);
    }
  }

  Future<List<Object>> _getSettings() async {
    return [
      await SharedPreferencesHelper.getServerUrl(),
      await widget.auth.getCurrentUser() as Object,
      await SharedPreferencesHelper.getDelay(),
    ];
  }

  Widget _buildSettingsFormItem(
      BuildContext context, int index, AsyncSnapshot snapshot) {
    TextFormField field;

    if (index == 0) {
      field = TextFormField(
        initialValue: snapshot.data[index].toString(),
        style: TextStyle(color: Colors.grey),
        decoration: new InputDecoration(labelText: 'Server'),
        enabled: false,
      );
    } else if (index == 1) {
      field = TextFormField(
        initialValue: snapshot.data[index].email.toString(),
        style: TextStyle(color: Colors.grey),
        decoration: new InputDecoration(labelText: 'Username'),
        enabled: false,
      );
    } else if (index == 2) {
      field = TextFormField(
          initialValue: snapshot.data[index].toString(),
          maxLines: 1,
          keyboardType: TextInputType.number,
          decoration: new InputDecoration(labelText: 'Delay'),
          obscureText: false,
          validator: (value) {
            if (value == null || value.isEmpty) {
              setState(() {
                _isLoading = false;
              });
              return 'Delay can\'t be empty';
            }
            return null;
          },
          onSaved: (value) {
            if (value == null) {
              _delay = 7;
              return;
            }
            

            int? parsed = int.tryParse(value);

            if (parsed == null) {
              _delay = 7;
              return;
            }

            _delay = parsed;
          });
            
    } else {
      throw new ArgumentError("Invalid");
    }
    return Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 5.0), child: field);
  }

  Widget _showPrimaryButtons() {
    if (!_isSaving) {
      return new Builder(
          builder: (context) => Row(
                children: [
                  Padding(
                      padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0),
                      child: SizedBox(
                        height: 40.0,
                        child: ElevatedButton(style: ElevatedButton.styleFrom(
                          elevation: 5.0,
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(10.0)),
                          backgroundColor: Colors.blue),
                          child: new Text('Save',
                              style: new TextStyle(
                                  fontSize: 20.0, color: Colors.white)),
                          onPressed: () => _validateAndSubmit(context),
                        ),
                      )),
                ],
              ));
    }
    return new CircularProgressIndicator();
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

  void _validateAndSubmit(BuildContext context) async {
    setState(() {
      _isSaving = true;
    });

    if (_validateAndSave()) {
      await SharedPreferencesHelper.setDelay(_delay);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Settings Saved'),
        action: SnackBarAction(
          label: 'Back',
          onPressed: () => Navigator.pop(context, false),
        ),
      ));
    }

    setState(() {
      _isSaving = false;
    });
  }

  Widget _showInputs() {
    return FutureBuilder<List<Object>>(
      future: _getSettings(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        return ListView.builder(
            shrinkWrap: true,
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) =>
                _buildSettingsFormItem(context, index, snapshot));
      },
    );
  }

  Widget _constructBody() {
    if (!_isLoading) {
      return new Container(
        padding: EdgeInsets.all(16.0),
        child: new Form(
            key: _formKey,
            child: new ListView(
              shrinkWrap: true,
              children: <Widget>[
                _showInputs(),
                _showPrimaryButtons(),
              ],
            )),
      );
    }

    return new Center(
      child: CircularProgressIndicator(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
          automaticallyImplyLeading: true,
          title: new Text('Settings'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context, false),
          )),
      body: _constructBody(),
    );
  }
}
