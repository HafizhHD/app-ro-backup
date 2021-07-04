import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RKConfigLimitDevice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp();
  }

}

class RKConfigLimitDevicetPage extends StatefulWidget {
  // List<charts.Series> seriesList;
  @override
  _RKConfigLimitDevicePageState createState() => _RKConfigLimitDevicePageState();
  final String title;
  final String name;

  RKConfigLimitDevicetPage({Key? key, required this.title, required this.name}) : super(key: key);
}

class _RKConfigLimitDevicePageState extends State<RKConfigLimitDevicetPage> {
  bool _switchValueFilter = true;
  bool _switchValueSafeSearch = true;
  bool _switchValuePorno = true;
  bool _switchValueAborsi = true;
  bool _switchValueKencan = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: TextStyle(color: Colors.darkGrey)),
        backgroundColor: Colors.whiteLight,
        iconTheme: IconThemeData(color: Colors.darkGrey),
        actions: <Widget>[
          IconButton(onPressed: () {}, icon: Icon(
            Icons.add,
            color: Colors.darkGrey,
          ),),
        ],
      ),
      backgroundColor: Colors.grey[300],
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.grey[300],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: SingleChildScrollView(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.only(top: 10.0),
                          height: 50,
                          color: Colors.white,
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              'Boao Simanjuntak',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.all(20.0),
                          child: Text('Kontrol Instant',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                        Container(
                          height: 80,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey,
                                blurRadius: 3.0,
                              ),
                            ],
                          ),
                          child: Align(
                            child: Container(
                              margin: EdgeInsets.all(10.0),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    child: Text(
                                      'Mode Penjadwalan',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  Container(
                                    child: CupertinoSwitch(
                                      value: _switchValueFilter,
                                      onChanged: (value) {
                                        setState(() {
                                          _switchValueFilter = value;
                                        });
                                      },
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        /*Container(
                          height: 50,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey,
                                blurRadius: 3.0,
                              ),
                            ],
                          ),
                          child: Align(
                            child: Container(
                              margin: EdgeInsets.all(10.0),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(left: 10.0),
                                    child: Text(
                                      'Waktu Bangun Pagi',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(right: 10.0),
                                    child: Icon(
                                      Icons.more_vert_outlined,
                                      color: Colors.green,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),*/
                      ]
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

}