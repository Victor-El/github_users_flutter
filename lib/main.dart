import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart' as urlLauncher;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:github_users/models/ResponseModel.dart';
import 'package:github_users/models/User.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Map<int, Color> swatch = <int, Color>{
      50: Color.fromRGBO(200, 200, 200, 0.1),
      100: Color.fromRGBO(200, 200, 200, 0.2),
      200: Color.fromRGBO(200, 200, 200, 0.3),
      300: Color.fromRGBO(200, 200, 200, 0.4),
      400: Color.fromRGBO(200, 200, 200, 0.5),
      500: Color.fromRGBO(200, 200, 200, 0.6),
      600: Color.fromRGBO(200, 200, 200, 0.7),
      700: Color.fromRGBO(200, 200, 200, 0.8),
      800: Color.fromRGBO(200, 200, 200, 0.9),
      900: Color.fromRGBO(200, 200, 200, 1),
    };
    return MaterialApp(
      home: Home(),
      theme: ThemeData(primarySwatch: MaterialColor(0xFF2F3035, swatch)),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String apiTextData;
  bool haveData;
  List<User> users;

  void _getGithubUsers() async {
    try {
      Response res = await Dio()
          .get("https://api.github.com/search/repositories?q=flutter");
      var a = jsonDecode(res.toString());
      var b = ResponseModel.fromJSON(a);
      print(b.totalCount);
      print("Done");
      print(b.items[1].avatarUrl);

      setState(() {
        users = b.items;
      });
    } catch (e) {
      print(e);
      setState(() {
        apiTextData = "Network Error";
      });
    } finally {
      setState(() {
        haveData = true;
      });
    }
  }

  void _launchUrl(String url, BuildContext context) async {
    if (await urlLauncher.canLaunch(url)) {
      await urlLauncher.launch(
        url,
        forceWebView: true,
        enableJavaScript: true,
      );
    } else {
      Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text("Can't open url")));
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    apiTextData = "No Users Yet";
    haveData = false;
    users = null;
    _getGithubUsers();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("GitHub Users"),
      ),
      body: Container(
        padding: EdgeInsets.all(10.0),
        child: Center(
          child: haveData == true
              ? users == null
                  ? ListView(
                      children: <Widget>[
                        Text(apiTextData),
                        RaisedButton(
                          child: Text("retry"),
                          onPressed: () {
                            setState(() {
                              haveData = false;
                            });
                            _getGithubUsers();
                          },
                        ),
                      ],
                    )
                  : ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                          padding: EdgeInsets.all(10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Expanded(
                                flex: 1,
                                child: ClipOval(
                                  child: Image.network(
                                    users[index].avatarUrl,
                                  ),
                                ),
                              ),
                              Padding(padding: EdgeInsets.all(8.0)),
                              Expanded(
                                  flex: 1, child: Text(users[index].login)),
                              Expanded(
                                flex: 1,
                                child: Container(
                                  padding: EdgeInsets.all(5.0),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.0),
                                      border: Border.all(width: 1.0)),
                                  child: InkWell(
                                    onTap: () {
                                      _launchUrl(users[index].url, context);
                                    },
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Text("View Profile"),
                                        Padding(padding: EdgeInsets.all(3.0)),
                                        FaIcon(FontAwesomeIcons.github),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        );
                      })
              : SizedBox(
                  width: 50.0,
                  height: 50.0,
                  child: CircularProgressIndicator(),
                ),
        ),
      ),
    );
  }
}
