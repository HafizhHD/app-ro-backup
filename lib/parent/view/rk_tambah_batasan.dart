import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ruangkeluarga/parent/view/rk_setting_time_app_limit.dart';

class RKTambahBatasan extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp();
  }

}

class RKTambahBatasanPage extends StatefulWidget {
  // List<charts.Series> seriesList;
  @override
  _RKTambahBatasanPageState createState() => _RKTambahBatasanPageState();
  final String title;
  final String name;
  final String email;

  RKTambahBatasanPage({Key? key, required this.title, required this.name, required this.email}) : super(key: key);
}

class _RKTambahBatasanPageState extends State<RKTambahBatasanPage> {

  bool checkSocial = false;
  bool checkGames = false;
  bool checkProductivity = false;
  bool checkOther = false;

  String dataName = "Social";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pilih Kategori', style: TextStyle(color: Colors.darkGrey)),
        backgroundColor: Colors.whiteLight,
        iconTheme: IconThemeData(color: Colors.darkGrey),
        actions: <Widget>[
          GestureDetector(
            child: Container(
              margin: EdgeInsets.only(right: 20.0),
              child: Align(
                child: Text(
                  'Lanjut',
                  style: TextStyle(color: Color(0xffFF018786), fontWeight: FontWeight.bold),
                ),
              ),
            ),
            onTap: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) =>
                  RKSettingAppLimitPage(title: widget.title, name: dataName, email: widget.email)));
            },
          ),
          /*IconButton(onPressed: () {}, icon: Icon(
            Icons.add,
            color: Colors.darkGrey,
          ),),*/
        ],
      ),
      backgroundColor: Colors.grey[300],
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.grey[300],
        child: Container(
          margin: EdgeInsets.only(top: 20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 10.0),
                    child: CupertinoSwitch(
                      value: checkSocial,
                      onChanged: (value) {
                        setState(() {
                          checkSocial = value;
                          checkOther = false;
                          checkProductivity = false;
                          checkGames = false;
                          dataName = "Social";
                        });
                      },
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 20.0),
                    child: Text('Social'),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 10.0),
                    child: CupertinoSwitch(
                      value: checkGames,
                      onChanged: (value) {
                        setState(() {
                          checkGames = value;
                          checkOther = false;
                          checkProductivity = false;
                          checkSocial = false;
                          dataName = "Games";
                        });
                      },
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 20.0),
                    child: Text('Game'),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 10.0),
                    child: CupertinoSwitch(
                      value: checkProductivity,
                      onChanged: (value) {
                        setState(() {
                          checkProductivity = value;
                          checkOther = false;
                          checkSocial = false;
                          checkGames = false;
                          dataName = "Productivity";
                        });
                      },
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 20.0),
                    child: Text('Productivity'),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 10.0),
                    child: CupertinoSwitch(
                      value: checkOther,
                      onChanged: (value) {
                        setState(() {
                          checkOther = value;
                          checkSocial = false;
                          checkProductivity = false;
                          checkGames = false;
                          dataName = "Other";
                        });
                      },
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 20.0),
                    child: Text('Other'),
                  )
                ],
              ),
            ],
          ),
        ),
      )
    );
  }

}