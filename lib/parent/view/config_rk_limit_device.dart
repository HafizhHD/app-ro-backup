import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

import 'package:intl/intl.dart';
import 'package:ruangkeluarga/global/global.dart';
import 'package:ruangkeluarga/utils/repository/media_repository.dart';
import 'package:http/http.dart';

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
  final String email;

  RKConfigLimitDevicetPage({Key? key, required this.title, required this.name, required this.email}) : super(key: key);
}

class _RKConfigLimitDevicePageState extends State<RKConfigLimitDevicetPage> {
  bool _switchValueFilter = false;
  bool _switchValueSafeSearch = true;
  bool _switchValuePorno = true;
  bool _switchValueAborsi = true;
  bool _switchValueKencan = true;
  bool _switchValueEveryday = true;
  bool _switchValueEveryWeekDay = false;
  bool _switchValueEveryWeekEnd = false;
  String startDateEveryday = '07:00';
  String endDateEveryday = '22:00';
  String startDateWeekday = '07:00';
  String endDateWeekday = '22:00';
  String startDateWeekend = '07:00';
  String endDateWeekend = '22:00';
  String type = 'everyday';

  void onSaveSchedule(String status) async {
    String startTime = "07:00";
    String endTime = "22:00";
    if (type == 'everyday') {
      startTime = startDateEveryday;
      endTime = endDateEveryday;
    } else if (type == 'weekday') {
      startTime = startDateWeekday;
      endTime = endDateWeekday;
    } else {
      startTime = startDateWeekend;
      endTime = endDateWeekend;
    }
    Response response = await MediaRepository().saveSchedule(widget.email, type, startTime, endTime, status);
    if (response.statusCode == 200) {
      // print('isi response save schedule ${response.body}');
      var json = jsonDecode(response.body);
      if (json['resultCode'] == 'OK') {
        print('isi response save schedule ${response.body}');
      } else {
        print('isi response nok save schedule ${response.body}');
      }
    } else {
      print('isi error response save schedule ${response.statusCode}');
    }
  }

  void onUpdateSchedule(String status) async {
    String startTime = "07:00";
    String endTime = "22:00";
    if (type == 'everyday') {
      startTime = startDateEveryday;
      endTime = endDateEveryday;
    } else if (type == 'weekday') {
      startTime = startDateWeekday;
      endTime = endDateWeekday;
    } else {
      startTime = startDateWeekend;
      endTime = endDateWeekend;
    }
    Response response = await MediaRepository().shceduleUpdate(widget.email, type, startTime, endTime, status);
    if (response.statusCode == 200) {
      // print('isi response save schedule ${response.body}');
      var json = jsonDecode(response.body);
      if (json['resultCode'] == 'OK') {
        print('isi response update schedule ${response.body}');
      } else {
        print('isi response nok update schedule ${response.body}');
      }
    } else {
      print('isi error response update schedule ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cPrimaryBg,
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.name, style: TextStyle(color: cOrtuWhite)),
        backgroundColor: cPrimaryBg,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: cOrtuWhite),
          onPressed: () => Navigator.of(context).pop(),
        ),
        elevation: 0,
      ),
      body: Container(
        padding: EdgeInsets.only(left: 15, right: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            WSearchBar(
              fOnChanged: (v) {},
            ),
            //dropDown
            Container(
              padding: const EdgeInsets.all(5.0),
              width: MediaQuery.of(context).size.width / 2,
              child: Divider(
                thickness: 1,
                color: cOrtuWhite,
              ),
            ),
            Flexible(
              child: ListView.builder(
                  itemCount: 20,
                  itemBuilder: (ctx, index) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          margin: EdgeInsets.all(5),
                          padding: EdgeInsets.all(5).copyWith(left: 10),
                          decoration: BoxDecoration(color: Colors.grey.shade700, borderRadius: BorderRadius.circular(10)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: EdgeInsets.all(5),
                                    child: Text(
                                      'Tidur Siang ke $index',
                                      style: TextStyle(color: cOrtuWhite),
                                    ),
                                  ),
                                  Text(
                                    '$index Jam - ${index}x kali  Dalam seminggu',
                                    style: TextStyle(color: cOrtuWhite),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  IconButton(
                                      onPressed: () {},
                                      icon: Icon(
                                        Icons.close,
                                        color: cOrtuWhite,
                                      )),
                                  IconButton(
                                      onPressed: () {},
                                      icon: Icon(
                                        Icons.edit,
                                        color: cOrtuWhite,
                                      )),
                                  IconButton(
                                      onPressed: () {},
                                      icon: Icon(
                                        Icons.radio_button_checked,
                                        color: cOrtuWhite,
                                      )),
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (index == 19)
                          Container(
                            margin: EdgeInsets.all(5),
                            padding: EdgeInsets.all(5).copyWith(left: 10),
                            child: ListTile(),
                          )
                      ],
                    );
                  }),
              // child: FutureBuilder<List<Contact>>(
              //   future: fetchContact(),
              //   builder: (BuildContext context, AsyncSnapshot<List<Contact>> data) {
              //     if (data.data == null) {
              //       return const Center(child: CircularProgressIndicator());
              //     } else {
              //       List<Contact> apps = data.data!;
              //       apps.sort((a, b) {
              //         var aName = a.name;
              //         var bName = b.name;
              //         return aName!.compareTo(bName!);
              //       });
              //       for (int i = 0; i < apps.length; i++) {
              //         Contact dt = apps[i];
              //         listSwitchValue.add(dt.blacklist!);
              //       }
              //
              //       if (apps.length == 0) {
              //         return Align(
              //           child: Text(
              //             'Tidak ada data.',
              //             style: TextStyle(color: Colors.black, fontSize: 18),
              //           ),
              //         );
              //       } else {
              //         return Scrollbar(
              //           child: ListView.builder(
              //               itemBuilder: (BuildContext context, int position) {
              //                 Contact app = apps[position];
              //                 var phones = "";
              //                 if (app.phone != null && app.phone!.length > 0) {
              //                   phones = app.phone![0];
              //                 }
              //
              //                 if (phones == "") {
              //                   return Column(
              //                     children: <Widget>[
              //                       ListTile(
              //                         leading: Icon(
              //                           Icons.android_outlined,
              //                           color: Colors.green,
              //                         ),
              //                         title: Column(
              //                           mainAxisAlignment: MainAxisAlignment.start,
              //                           crossAxisAlignment: CrossAxisAlignment.start,
              //                           children: [
              //                             Text('${app.name}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              //                           ],
              //                         ),
              //                         // title: Text('${app.name}'),
              //                         trailing: CupertinoSwitch(
              //                           value: listSwitchValue[position],
              //                           onChanged: (bool value) {
              //                             onBlacklistContact(app.name.toString(), app.phone![0].toString());
              //                             setState(() {
              //                               listSwitchValue[position] = value;
              //                             });
              //                           },
              //                         ),
              //                       ),
              //                       const Divider(
              //                         height: 1.0,
              //                       )
              //                     ],
              //                   );
              //                 } else {
              //                   return Column(
              //                     children: <Widget>[
              //                       ListTile(
              //                         leading: Icon(
              //                           Icons.android_outlined,
              //                           color: Colors.green,
              //                         ),
              //                         title: Column(
              //                           mainAxisAlignment: MainAxisAlignment.start,
              //                           crossAxisAlignment: CrossAxisAlignment.start,
              //                           children: [
              //                             Text('${app.name}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              //                             SizedBox(
              //                               height: 5,
              //                             ),
              //                             Text('$phones', style: TextStyle(fontSize: 12))
              //                           ],
              //                         ),
              //                         // title: Text('${app.name}'),
              //                         trailing: CupertinoSwitch(
              //                           value: listSwitchValue[position],
              //                           onChanged: (bool value) {
              //                             onBlacklistContact(app.name.toString(), app.phone![0].toString());
              //                             setState(() {
              //                               listSwitchValue[position] = value;
              //                             });
              //                           },
              //                         ),
              //                       ),
              //                       const Divider(
              //                         height: 1.0,
              //                       )
              //                     ],
              //                   );
              //                 }
              //               },
              //               itemCount: apps.length),
              //         );
              //       }
              //     }
              //   },
              // ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: cOrtuBlue,
        child: Icon(Icons.add, color: cPrimaryBg),
        onPressed: () {},
      ),
    );
  }

  Widget onLoadDate(bool flag, String type) {
    if (flag) {
      if (type == 'everyday') {
        return Container(
          margin: EdgeInsets.only(top: 30.0),
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        child: Text(
                          'Dari',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      Container(
                        child: GestureDetector(
                          onTap: () {
                            var outputFormat = DateFormat('HH:mm');
                            DatePicker.showTimePicker(context, showTitleActions: true, onChanged: (date) {
                              print('change $date in time zone ' + date.timeZoneOffset.inHours.toString());
                            }, onConfirm: (date) {
                              print('confirm ${outputFormat.format(date)}');
                              setState(() {
                                startDateEveryday = outputFormat.format(date);
                                onUpdateSchedule('Active');
                              });
                            }, currentTime: outputFormat.parse(outputFormat.format(DateTime.now())));
                          },
                          child: Text(
                            '$startDateEveryday',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  height: 1,
                  margin: EdgeInsets.only(left: 10.0, top: 3.0, bottom: 3.0),
                  color: Colors.grey,
                ),
                Container(
                  margin: EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        child: Text(
                          'Sampai',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      Container(
                        child: GestureDetector(
                          onTap: () {
                            var outputFormat = DateFormat('HH:mm');
                            DatePicker.showTimePicker(context, showTitleActions: true, onChanged: (date) {
                              print('change $date in time zone ' + date.timeZoneOffset.inHours.toString());
                            }, onConfirm: (date) {
                              print('confirm ${outputFormat.format(date)}');
                              setState(() {
                                endDateEveryday = outputFormat.format(date);
                                onUpdateSchedule('Active');
                              });
                            }, currentTime: outputFormat.parse(outputFormat.format(DateTime.now())));
                          },
                          child: Text(
                            '$endDateEveryday',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      } else if (type == 'weekday') {
        /*return Container(
        margin: EdgeInsets.only(top: 30.0),
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      child: Text(
                        'Senin',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    Container(
                      child: GestureDetector(
                        onTap: () {
                          var outputFormat = DateFormat('HH:mm');
                          DatePicker.showTimePicker(context, showTitleActions: true,
                              onChanged: (date) {
                                print('change $date in time zone ' +
                                    date.timeZoneOffset.inHours.toString());
                              }, onConfirm: (date) {
                                print('confirm ${outputFormat.format(date)}');
                                setState(() {
                                  startDate = outputFormat.format(date);
                                });
                              }, currentTime: outputFormat.parse(outputFormat.format(DateTime.now())));
                        },
                        child: Text(
                          '$startDate',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Container(
                height: 1,
                margin: EdgeInsets.only(left: 10.0, top: 3.0, bottom: 3.0),
                color: Colors.grey,
              ),
              Container(
                margin: EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      child: Text(
                        'Selasa',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    Container(
                      child: GestureDetector(
                        onTap: () {
                          var outputFormat = DateFormat('HH:mm');
                          DatePicker.showTimePicker(context, showTitleActions: true,
                              onChanged: (date) {
                                print('change $date in time zone ' +
                                    date.timeZoneOffset.inHours.toString());
                              }, onConfirm: (date) {
                                print('confirm ${outputFormat.format(date)}');
                                setState(() {
                                  endDate = outputFormat.format(date);
                                });
                              }, currentTime: outputFormat.parse(outputFormat.format(DateTime.now())));
                        },
                        child: Text(
                          '$endDate',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Container(
                height: 1,
                margin: EdgeInsets.only(left: 10.0, top: 3.0, bottom: 3.0),
                color: Colors.grey,
              ),
              Container(
                margin: EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      child: Text(
                        'Rabu',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    Container(
                      child: GestureDetector(
                        onTap: () {
                          var outputFormat = DateFormat('HH:mm');
                          DatePicker.showTimePicker(context, showTitleActions: true,
                              onChanged: (date) {
                                print('change $date in time zone ' +
                                    date.timeZoneOffset.inHours.toString());
                              }, onConfirm: (date) {
                                print('confirm ${outputFormat.format(date)}');
                                setState(() {
                                  endDate = outputFormat.format(date);
                                });
                              }, currentTime: outputFormat.parse(outputFormat.format(DateTime.now())));
                        },
                        child: Text(
                          '$endDate',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Container(
                height: 1,
                margin: EdgeInsets.only(left: 10.0, top: 3.0, bottom: 3.0),
                color: Colors.grey,
              ),
              Container(
                margin: EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      child: Text(
                        'Kamis',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    Container(
                      child: GestureDetector(
                        onTap: () {
                          var outputFormat = DateFormat('HH:mm');
                          DatePicker.showTimePicker(context, showTitleActions: true,
                              onChanged: (date) {
                                print('change $date in time zone ' +
                                    date.timeZoneOffset.inHours.toString());
                              }, onConfirm: (date) {
                                print('confirm ${outputFormat.format(date)}');
                                setState(() {
                                  endDate = outputFormat.format(date);
                                });
                              }, currentTime: outputFormat.parse(outputFormat.format(DateTime.now())));
                        },
                        child: Text(
                          '$endDate',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Container(
                height: 1,
                margin: EdgeInsets.only(left: 10.0, top: 3.0, bottom: 3.0),
                color: Colors.grey,
              ),
              Container(
                margin: EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      child: Text(
                        'Jumat',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    Container(
                      child: GestureDetector(
                        onTap: () {
                          var outputFormat = DateFormat('HH:mm');
                          DatePicker.showTimePicker(context, showTitleActions: true,
                              onChanged: (date) {
                                print('change $date in time zone ' +
                                    date.timeZoneOffset.inHours.toString());
                              }, onConfirm: (date) {
                                print('confirm ${outputFormat.format(date)}');
                                setState(() {
                                  endDate = outputFormat.format(date);
                                });
                              }, currentTime: outputFormat.parse(outputFormat.format(DateTime.now())));
                        },
                        child: Text(
                          '$endDate',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Container(
                height: 1,
                margin: EdgeInsets.only(left: 10.0, top: 3.0, bottom: 3.0),
                color: Colors.grey,
              ),
              Container(
                margin: EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      child: Text(
                        'Sabtu',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    Container(
                      child: GestureDetector(
                        onTap: () {
                          var outputFormat = DateFormat('HH:mm');
                          DatePicker.showTimePicker(context, showTitleActions: true,
                              onChanged: (date) {
                                print('change $date in time zone ' +
                                    date.timeZoneOffset.inHours.toString());
                              }, onConfirm: (date) {
                                print('confirm ${outputFormat.format(date)}');
                                setState(() {
                                  endDate = outputFormat.format(date);
                                });
                              }, currentTime: outputFormat.parse(outputFormat.format(DateTime.now())));
                        },
                        child: Text(
                          '$endDate',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Container(
                height: 1,
                margin: EdgeInsets.only(left: 10.0, top: 3.0, bottom: 3.0),
                color: Colors.grey,
              ),
              Container(
                margin: EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      child: Text(
                        'Minggu',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    Container(
                      child: GestureDetector(
                        onTap: () {
                          var outputFormat = DateFormat('HH:mm');
                          DatePicker.showTimePicker(context, showTitleActions: true,
                              onChanged: (date) {
                                print('change $date in time zone ' +
                                    date.timeZoneOffset.inHours.toString());
                              }, onConfirm: (date) {
                                print('confirm ${outputFormat.format(date)}');
                                setState(() {
                                  endDate = outputFormat.format(date);
                                });
                              }, currentTime: outputFormat.parse(outputFormat.format(DateTime.now())));
                        },
                        child: Text(
                          '$endDate',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      );*/
        return Container(
          margin: EdgeInsets.only(top: 30.0),
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        child: Text(
                          'Dari',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      Container(
                        child: GestureDetector(
                          onTap: () {
                            var outputFormat = DateFormat('HH:mm');
                            DatePicker.showTimePicker(context, showTitleActions: true, onChanged: (date) {
                              print('change $date in time zone ' + date.timeZoneOffset.inHours.toString());
                            }, onConfirm: (date) {
                              print('confirm ${outputFormat.format(date)}');
                              setState(() {
                                startDateWeekday = outputFormat.format(date);
                                onUpdateSchedule('Active');
                              });
                            }, currentTime: outputFormat.parse(outputFormat.format(DateTime.now())));
                          },
                          child: Text(
                            '$startDateWeekday',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  height: 1,
                  margin: EdgeInsets.only(left: 10.0, top: 3.0, bottom: 3.0),
                  color: Colors.grey,
                ),
                Container(
                  margin: EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        child: Text(
                          'Sampai',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      Container(
                        child: GestureDetector(
                          onTap: () {
                            var outputFormat = DateFormat('HH:mm');
                            DatePicker.showTimePicker(context, showTitleActions: true, onChanged: (date) {
                              print('change $date in time zone ' + date.timeZoneOffset.inHours.toString());
                            }, onConfirm: (date) {
                              print('confirm ${outputFormat.format(date)}');
                              setState(() {
                                endDateWeekday = outputFormat.format(date);
                                onUpdateSchedule('Active');
                              });
                            }, currentTime: outputFormat.parse(outputFormat.format(DateTime.now())));
                          },
                          child: Text(
                            '$endDateWeekday',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      } else {
        return Container(
          margin: EdgeInsets.only(top: 30.0),
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        child: Text(
                          'Dari',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      Container(
                        child: GestureDetector(
                          onTap: () {
                            var outputFormat = DateFormat('HH:mm');
                            DatePicker.showTimePicker(context, showTitleActions: true, onChanged: (date) {
                              print('change $date in time zone ' + date.timeZoneOffset.inHours.toString());
                            }, onConfirm: (date) {
                              print('confirm ${outputFormat.format(date)}');
                              setState(() {
                                startDateWeekend = outputFormat.format(date);
                                onUpdateSchedule('Active');
                              });
                            }, currentTime: outputFormat.parse(outputFormat.format(DateTime.now())));
                          },
                          child: Text(
                            '$startDateWeekend',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  height: 1,
                  margin: EdgeInsets.only(left: 10.0, top: 3.0, bottom: 3.0),
                  color: Colors.grey,
                ),
                Container(
                  margin: EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        child: Text(
                          'Sampai',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      Container(
                        child: GestureDetector(
                          onTap: () {
                            var outputFormat = DateFormat('HH:mm');
                            DatePicker.showTimePicker(context, showTitleActions: true, onChanged: (date) {
                              print('change $date in time zone ' + date.timeZoneOffset.inHours.toString());
                            }, onConfirm: (date) {
                              print('confirm ${outputFormat.format(date)}');
                              setState(() {
                                endDateWeekend = outputFormat.format(date);
                                onUpdateSchedule('Active');
                              });
                            }, currentTime: outputFormat.parse(outputFormat.format(DateTime.now())));
                          },
                          child: Text(
                            '$endDateWeekend',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      }
    } else {
      return Container();
    }
  }

  Widget onLoadEveryDay(bool flag, bool flagIsActive) {
    if (flag) {
      return Container(
        margin: EdgeInsets.only(top: 10.0),
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
        child: GestureDetector(
          onTap: () {
            setState(() {
              _switchValueEveryday = true;
              _switchValueEveryWeekDay = false;
              _switchValueEveryWeekEnd = false;
              onActiveWeekDay(_switchValueEveryWeekDay);
              onActiveWeekEnd(_switchValueEveryWeekEnd);
              type = 'everyday';
              onLoadDate(_switchValueFilter, type);
              onUpdateSchedule('Active');
            });
          },
          child: Container(
            margin: EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  margin: EdgeInsets.only(left: 10.0),
                  child: Text(
                    'Setiap Hari',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                onActiveEveryDay(_switchValueEveryday)
              ],
            ),
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  Widget onLoadEveryWeekDay(bool flag, bool flagIsActive) {
    if (flag) {
      return Container(
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
        child: GestureDetector(
          onTap: () {
            setState(() {
              _switchValueEveryday = false;
              _switchValueEveryWeekDay = true;
              _switchValueEveryWeekEnd = false;
              onActiveWeekDay(_switchValueEveryWeekDay);
              type = 'weekday';
              onLoadDate(_switchValueFilter, type);
              onUpdateSchedule('Active');
            });
          },
          child: Container(
            margin: EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  margin: EdgeInsets.only(left: 10.0),
                  child: Text(
                    'Setiap Hari Kerja',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                onActiveWeekDay(_switchValueEveryWeekDay)
              ],
            ),
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  Widget onActiveEveryDay(bool flag) {
    if (flag) {
      return Icon(
        Icons.alarm_on_outlined,
        color: Color(0xff05745F),
      );
    } else {
      return Icon(
        Icons.alarm_on_outlined,
        color: Colors.white,
      );
    }
  }

  Widget onActiveWeekDay(bool flag) {
    if (flag) {
      return Icon(
        Icons.alarm_on_outlined,
        color: Color(0xff05745F),
      );
    } else {
      return Icon(
        Icons.alarm_on_outlined,
        color: Colors.white,
      );
    }
  }

  Widget onActiveWeekEnd(bool flag) {
    if (flag) {
      return Icon(
        Icons.alarm_on_outlined,
        color: Color(0xff05745F),
      );
    } else {
      return Icon(
        Icons.alarm_on_outlined,
        color: Colors.white,
      );
    }
  }

  Widget onLoadEveryWeekEnd(bool flag, bool flagIsActive) {
    if (flag) {
      return GestureDetector(
        onTap: () {
          setState(() {
            _switchValueEveryWeekEnd = true;
            _switchValueEveryWeekDay = false;
            _switchValueEveryday = false;
            onActiveWeekEnd(_switchValueEveryWeekEnd);
            type = 'weekend';
            onLoadDate(_switchValueFilter, type);
            onUpdateSchedule('Active');
          });
        },
        child: Container(
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      margin: EdgeInsets.only(left: 10.0),
                      child: Text(
                        'Setiap Akhir Pekan',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    onActiveWeekEnd(_switchValueEveryWeekEnd)
                  ],
                ),
              )
            ],
          ),
        ),
      );
    } else {
      return Container();
    }
  }
}
