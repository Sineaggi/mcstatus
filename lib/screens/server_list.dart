import 'dart:convert';
import 'dart:typed_data';

import 'package:dartmc/dartmc.dart';
import 'package:flutter/material.dart';
import 'package:mcstatus/models/server.dart';
import 'package:mcstatus/screens/server_detail.dart';
import 'package:mcstatus/utils/database_helper.dart';

class LiveServerData {
  int latency = 0;
  Uint8List? image;
}

class ServerList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ServerListState();
  }
}

class ServerListState extends State<ServerList> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Server> serverList = List.empty(growable: true);
  List<LiveServerData> serverDataList = List.empty(growable: true);
  int count = 0;

  ServerListState() {
    updateListView();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Servers'),
      ),
      body: getServerListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          debugPrint('FAB clicked');
          navigateToDetail(Server(id: null, name: '', address: '', image: ''), "Add Server");
        },
        tooltip: 'Add Note',
        child: Icon(Icons.add),
      ),
    );
  }

  ListView getServerListView() {
    var titleStyle = Theme.of(context).textTheme.subtitle1;
    return ListView.builder(
      itemCount: count,
      itemBuilder: (context, index) {
        return Card(
          color: Colors.white,
          elevation: 2,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: getPriorityColor(),
              child: getPriorityIcon(this.serverDataList[index].image),
            ),
            title: Text(
              this.serverList[index].name,
              style: titleStyle,
            ),
            subtitle: Text('${this.serverList[index].address} : ${this.serverDataList[index].latency}ms'),
            trailing: GestureDetector(
              child: Icon(
                Icons.delete,
                color: Colors.grey,
              ),
              onTap: () {
                _delete(context, serverList[index]);
              },
            ),
            onTap: () {
              debugPrint("ListTile tapped");
              navigateToDetail(serverList[index], "Edit Server");
            },
          ),
        );
      },
    );
  }

  Color getPriorityColor() {
    return Colors.red;
  }

  Widget getPriorityIcon(Uint8List? image) {
    if (image == null) {
      return Icon(Icons.play_arrow);
    }
    return Image.memory(image, isAntiAlias: false,
    filterQuality: FilterQuality.none,);
  }

  void _delete(BuildContext context, Server server) async {
    int result = await databaseHelper.deleteServer(server.id!);
    if (result != 0) {
      _showSnackBar(context, 'Note Deleted Successfully');
      updateListView();
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void navigateToDetail(Server server, String title) async {
    var result = await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ServerDetail(server, title);
    }));
    if (result != null && result) {
      // update
      updateListView();
    }
  }

  void updateListView() {
    final dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Server>> serverListFuture = databaseHelper.servers();
      serverListFuture.then((servers) {
        setState(() {
          serverList = servers;
          serverDataList = servers.map((e) => LiveServerData()).toList();
          serverDataList.forEach((element) {
            var address = serverList[serverDataList.indexOf(element)].address;
            MinecraftServer.lookup(address).then((server) {
              server.status().then((status) {
                setState(() {
                  element.latency = status.latency;

                  //var bytes = UriData.parse(favicon).contentAsBytes();
                  //image = Image.memory(
                  //  bytes,
                  //  scale: 0.5,
                  //  isAntiAlias: false,
                  //  filterQuality: FilterQuality.none,
                  //);

                  if (status.favicon != null) {
                    var bytes = UriData.parse(status.favicon!).contentAsBytes();
                    element.image = bytes;
                  }
                });
              });
            });
          });
          count = servers.length;
          debugPrint("count db $count");
        });
      });
    });
  }
}
