import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

var fsconnect;
String cmd;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

mydata(mycmd) async {
  var url = "http://192.168.183.128/cgi-bin/web.py?x=${mycmd}";
  var response = await http.get(url);
  print(response.body);
}

getdata() async {
  var d = await fsconnect.collection("commands").get();
  // print(d);
  // print(d.docs[0].data());

  for (var i in d.docs) {
    print(i.data());
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    fsconnect = FirebaseFirestore.instance;
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("LINUX COMMANDS"),
        ),
        body: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              margin: EdgeInsets.only(top: 10),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Enter your Linux Command: ",
                  border: const OutlineInputBorder(),
                ),
                onChanged: (value) {
                  cmd = value;
                },
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 10),
              color: Colors.blueAccent,
              child: RaisedButton(
                onPressed: () {
                  mydata(cmd);
                  print(cmd);
                  fsconnect.collection("commands").add({
                    'command': cmd,
                    "output": cmd,
                  });
                },
                child: Text(
                  "SHOW OUTPUT",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(top: 20),
              margin: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                "OUTPUT",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 10),
              child: Card(
                  child: Padding(
                padding: EdgeInsets.only(top: 20.0),
                child: StreamBuilder<QuerySnapshot>(
                  stream: fsconnect.collection("commands").snapshots(),
                  builder: (context, snapshot) {
                    var msg = snapshot.data.docs;
                    print(msg);
                    List<Widget> y = [];
                    for (var d in msg) {
                      var msgCommand = d.data()['command'];
                      var msgOutput = d.data()['output'];
                      var msgFinal = Text("$msgCommand: $msgOutput");
                      y.add(msgFinal);
                    }
                    return Container(
                      child: Column(
                        children: y,
                        // [
                        // TextField(
                        //   maxLines: 10,
                        //   decoration: InputDecoration(
                        //     hintText: "Enter your text here",
                        //     border: const OutlineInputBorder(),
                        //   ),
                        // ),
                        // ],
                      ),
                    );
                  },
                ),
              )),
            ),
          ],
        ),
      ),
    );
  }
}
