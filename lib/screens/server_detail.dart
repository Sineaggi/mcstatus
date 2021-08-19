import 'package:flutter/material.dart';
import 'package:mcstatus/models/server.dart';
import 'package:mcstatus/utils/database_helper.dart';

class ServerDetail extends StatefulWidget {
  final Server server;
  String appBarTitle;
  ServerDetail(this.server, this.appBarTitle);

  @override
  State<StatefulWidget> createState() {
    return ServerDetailState(server, appBarTitle);
  }
}

class ServerDetailState extends State<ServerDetail> {

  final databaseHelper = DatabaseHelper();

  var serverNameController = TextEditingController(text: 'Minecraft Server');
  var serverAddressController = TextEditingController();

  Server server;
  String appBarTitle;
  ServerDetailState(this.server, this.appBarTitle);

  @override
  Widget build(BuildContext context) {
    var textStyle = Theme.of(context).textTheme.headline6;

    if (server.id != null) {
      serverNameController.text = server.name;
      serverAddressController.text = server.address;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        //leading: IconButton(
        //  icon: Icon(Icons.arrow_back),
        //  onPressed: () {
        //    moveToLastScreen();
        //  },
        //),
      ),
      body: Padding(
        padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
        child: ListView(
          children: <Widget>[
            Padding(
                padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
                child: TextField(
                  controller: serverNameController,
                  style: textStyle,
                  onChanged: (value) {
                    debugPrint('Changed server name to $value');
                    updateName();
                  },
                  decoration: InputDecoration(
                    labelText: 'Server Name',
                    labelStyle: textStyle,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                )),
            Padding(
              padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
              child: textField(
                labelText: "Server Address",
                controller: serverAddressController,
                onChanged: (value) {
                  debugPrint("Server address changed to $value");
                  updateAddress();
                },
                autofillHints: [AutofillHints.url],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: Row(
                children: [
                  Expanded(
                    child: button(
                      buttonText: 'Save',
                      onPressed: () {
                        setState(() {
                          debugPrint('Save button clicked');
                          _save();
                        });
                      },
                    ),
                  ),
                  Container(
                    width: 5.0,
                  ),
                  Expanded(
                    child: button(
                      buttonText: 'Delete',
                      onPressed: () {
                        setState(() {
                          debugPrint('Delete button clicked');
                          _delete();
                        });
                      },
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  TextField textField(
      {required String labelText,
        required TextEditingController controller,
        required ValueChanged<String> onChanged,
        Iterable<String>? autofillHints}) {
    var textStyle = Theme.of(context).textTheme.headline6;
    return TextField(
      controller: controller,
      style: textStyle,
      onChanged: onChanged,
      autofillHints: autofillHints,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: textStyle,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
      ),
    );
  }

  ElevatedButton button(
      {required String buttonText, required VoidCallback onPressed}) {
    return ElevatedButton(
      //color: Theme.of(context).primaryColorDark,
      //textColor: Theme.of(context).primaryColorLight,
      child: Text(
        buttonText,
        textScaleFactor: 1.5,
      ),
      onPressed: onPressed,
    );
  }

  void updateName() {
    //server = Server(name: serverNameController.text, id: server.id, address: server.address, image: server.address);
  }

  void updateAddress() {
    //server = Server(name: server.name, id: server.id, address: serverAddressController.text, image: server.address);
  }

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }

  void _save() async {
    server = Server(name: serverNameController.text, id: server.id, address: serverAddressController.text, image: server.address);
    moveToLastScreen();

    int result;
    if (server.id != null) {
      result = await databaseHelper.updateServer(server);
    } else {
      result = await databaseHelper.insertServer(server);
    }
    if (result != 0) {
      _showAlertDialog('Status', 'Server Saved Successfully');
    } else {
      _showAlertDialog('Status', 'Error occurred while saving Server');
    }

  }

  void _delete() async {
    moveToLastScreen();
    if (server.id == null) {
      _showAlertDialog('Status', 'No Server was deleted');
      return;
    }
    var result = await databaseHelper.deleteServer(server.id!);
    if (result != 0) {
      _showAlertDialog('title', 'Server deleted Successfully');
    } else {
      _showAlertDialog('title', 'Error occured while deleting Server');
    }
  }

  void _showAlertDialog(String title, String message) {
    var alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }
}
