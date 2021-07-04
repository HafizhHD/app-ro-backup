import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:http/http.dart';
import 'package:ruangkeluarga/model/rk_child_location_model.dart';
import 'package:ruangkeluarga/utils/constant.dart';
import 'package:ruangkeluarga/utils/repository/media_repository.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:some_calendar/some_calendar.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:jiffy/jiffy.dart';

class RKConfigLocationView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp();
  }
}

class RKConfigLocationPage extends StatefulWidget {
  // List<charts.Series> seriesList;
  @override
  _RKConfigLocationPageState createState() => _RKConfigLocationPageState();
  final String title;
  final String email;
  final String name;

  RKConfigLocationPage({Key? key, required this.title, required this.email, required this.name}) : super(key: key);
}

class _RKConfigLocationPageState extends State<RKConfigLocationPage> {
  bool _switchValue = true;
  DateTime selectedDate = DateTime.now();
  List<DateTime> selectedDates = [];
  String tanggal = '';
  late SharedPreferences prefs;

  // LatLng _initialcameraposition = LatLng(20.5937, 78.9629);
  // GoogleMapController _controller;
  // Location _location = Location();
  //
  // void _onMapCreated(GoogleMapController _cntlr) {
  //   _controller = _cntlr;
  //   _location.onLocationChanged.listen((l) {
  //     _controller.animateCamera(
  //       CameraUpdate.newCameraPosition(
  //         CameraPosition(target: LatLng(l.latitude, l.longitude),zoom: 15),
  //       ),
  //     );
  //   });
  // }
  Completer<GoogleMapController> _controller = Completer();
  Map<MarkerId,Marker> markers = {};
  static final CameraPosition _myLocation = CameraPosition(target: LatLng(-6.1800525, 106.7106455), zoom: 15.0);
  var url = 'https://www.google.com/maps/timeline/kml?authuser=0&pb=!1m8!1m3!1i2021!2i4!3i1!2m3!1i2021!2i4!3i4';

  Future<void> addKml(GoogleMapController mapController) async {
    const MethodChannel channel = MethodChannel('ruangkeluarga.flutter.dev/kmlmap');
    try {
      // int kmlResourceId = await channel.invokeMethod('KML#@#$url');
      Uint8List kmlResourceId = await channel.invokeMethod('KML#@#$url');
      return mapController.channel?.invokeMethod("map#addKML", <String, dynamic>{
        'resourceId': kmlResourceId,
      });

    } on PlatformException catch (e) {
      throw 'Unable to plot map: ${e.message}';
    }
  }

  void fetchMarkers() async {
    markers.clear();
    var outputFormat = DateFormat('yyyy-MM-dd');
    var outputDate = outputFormat.format(DateTime.now());
    Response response = await MediaRepository().fetchUserLocation(widget.email, outputDate);
    if(response.statusCode == 200) {
      var json = jsonDecode(response.body);
      if(json['resultCode'] == 'OK') {
        print('response fetch markers : ${response.body}');
        var locationChilds = json['timeLine'];
        List<LocationChild> data = List<LocationChild>.from(
            locationChilds.map((model) => LocationChild.fromJson(model)));
        for(int i = 0; i < data.length; i++) {
          MarkerId markerId = MarkerId("$i");
          var locate = data[i].location;
          var coordinates = locate['coordinates'];
          Marker marker = Marker(
            markerId: markerId,
            position: LatLng(double.parse(coordinates[0]), double.parse(coordinates[1])),
            infoWindow: InfoWindow(
              title: 'Location',
              snippet: locate['place']
            )
          );
          markers[markerId] = marker;
        }
        setState(() {

        });
      } else {
        print('response fetch markers : ${response.body}');
        setState(() {

        });
      }
    } else {
      print('response fetch markers : ${response.statusCode}');
      setState(() {

      });
    }
  }

  void fetchFilterMarker(List<DateTime> rangeDate) async {
    markers.clear();
    var outputFormat = DateFormat('yyyy-MM-dd');
    var startDate = outputFormat.format(rangeDate[0]);
    var endDate = outputFormat.format(rangeDate[1]);
    Response response = await MediaRepository().fetchFilterUserLocation(widget.email, startDate, endDate);
    if(response.statusCode == 200) {
      var json = jsonDecode(response.body);
      if(json['resultCode'] == 'OK') {
        print('response fetch markers : ${response.body}');
        var locationChilds = json['timeLine'];
        List<LocationChild> data = List<LocationChild>.from(
            locationChilds.map((model) => LocationChild.fromJson(model)));
        for(int i = 0; i < data.length; i++) {
          MarkerId markerId = MarkerId("$i");
          var locate = data[i].location;
          var coordinates = locate['coordinates'];
          Marker marker = Marker(
              markerId: markerId,
              position: LatLng(double.parse(coordinates[0]), double.parse(coordinates[1])),
              infoWindow: InfoWindow(
                  title: 'Location',
                  snippet: locate['place']
              )
          );
          markers[markerId] = marker;
        }
        setState(() {

        });
      } else {
        print('response fetch markers : ${response.body}');
        setState(() {

        });
      }
    } else {
      print('response fetch markers : ${response.statusCode}');
      setState(() {

      });
    }
  }

  String setDayName(String name) {
    String days = 'Minggu';
    if(name == 'Sunday') {
      days = 'Minggu';
    } else if(name == 'Monday') {
      days = 'Senin';
    } else if(name == 'Tuesday') {
      days = 'Selasa';
    } else if(name == 'Wednesday') {
      days = 'Rabu';
    } else if(name == 'Thursday') {
      days = 'Kamis';
    } else if(name == 'Friday') {
      days = 'Jum\'at';
    } else if(name == 'Saturday') {
      days = 'Sabtu';
    }

    return days;
  }

  String setMonthName(String tanggal) {
    var data = tanggal.split('-');
    int name = int.parse(data[1]);
    String days = 'Minggu';
    if(name == 1) {
      days = '${data[0]} Januari ${data[2]}';
    } else if(name == 2) {
      days = '${data[0]} Februari ${data[2]}';
    } else if(name == 3) {
      days = '${data[0]} Maret ${data[2]}';
    } else if(name == 4) {
      days = '${data[0]} April ${data[2]}';
    } else if(name == 5) {
      days = '${data[0]} Mei ${data[2]}';
    } else if(name == 6) {
      days = '${data[0]} Juni ${data[2]}';
    } else if(name == 7) {
      days = '${data[0]} Juli ${data[2]}';
    } else if(name == 8) {
      days = '${data[0]} Agustus ${data[2]}';
    } else if(name == 9) {
      days = '${data[0]} September ${data[2]}';
    } else if(name == 10) {
      days = '${data[0]} Oktober ${data[2]}';
    } else if(name == 11) {
      days = '${data[0]} November ${data[2]}';
    } else if(name == 12) {
      days = '${data[0]} Desember ${data[2]}';
    }

    return days;
  }

  void fetchCurrentLoc() async {
    prefs = await SharedPreferences.getInstance();
    Response response = await MediaRepository().fetchCurrentUserLocation(prefs.getString(rkEmailUser)!, widget.email);
    print('response request current loc ${response.body}');
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    var outputFormat = DateFormat('dd-MM-yyyy');
    var outputFormatDay = DateFormat('EEEE');
    var dayName = outputFormatDay.format(DateTime.now());
    var outputDate = outputFormat.format(DateTime.now());
    tanggal = "${setDayName(dayName)}, ${setMonthName(outputDate)}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: TextStyle(color: Colors.darkGrey)),
        backgroundColor: Colors.whiteLight,
        iconTheme: IconThemeData(color: Colors.darkGrey),
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
                              '${widget.name}',
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
                          height: 150,
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: EdgeInsets.all(10.0),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      child: Text(
                                        'Mode Penulusuran Lokasi',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                                    Container(
                                      child: CupertinoSwitch(
                                        value: _switchValue,
                                        onChanged: (value) {
                                          setState(() {
                                            _switchValue = value;
                                          });
                                        },
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                height: 50,
                                margin: EdgeInsets.only(left: 10.0, right: 10.0),
                                child: DefaultTabController(
                                  length: 2,
                                  initialIndex: 0,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: <Widget>[
                                      Container(
                                        child: TabBar(
                                          labelColor: Colors.green,
                                          unselectedLabelColor: Colors.black,
                                          indicatorColor: Colors.green,
                                          tabs: [
                                            Tab(text: 'Timeline'),
                                            Tab(text: 'Waktu Tempuh'),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.all(20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Penulusuran Lokasi',
                                  style: TextStyle(
                                      fontSize: 18, fontWeight: FontWeight.bold)),
                              GestureDetector(
                                child: Text('Current',
                                    style: TextStyle(
                                        fontSize: 18, fontWeight: FontWeight.bold,
                                        color: Color(0xff05745F))),
                                onTap: () {
                                  fetchCurrentLoc();
                                },
                              )
                            ],
                          ),
                        ),
                        Container(
                          height: 400,
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.all(20.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '$tanggal',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    GestureDetector(
                                      child: Icon(
                                        //Icons.skip_previous,
                                        Icons.compare_arrows,
                                        size: 20.0,
                                        color: Theme.of(context).brightness == Brightness.dark
                                            ? Theme.of(context).accentColor
                                            : Color(0xFF787878),
                                      ),
                                      onTap: () {
                                        showDialog(
                                            context: context,
                                            builder: (_) => SomeCalendar(
                                              mode: SomeMode.Range,
                                              labels: new Labels(
                                                dialogDone: 'Selesai',
                                                dialogCancel: 'Batal',
                                                dialogRangeFirstDate: 'Tanggal Pertama',
                                                dialogRangeLastDate: 'Tanggal Terakhir',
                                              ),
                                              primaryColor: Color(0xff5833A5),
                                              startDate: Jiffy().subtract(years: 3),
                                              lastDate: Jiffy().add(months: 9),
                                              selectedDates: selectedDates,
                                              isWithoutDialog: false,
                                              done: (date) {
                                                setState(() {
                                                  selectedDates = date;
                                                  print('select date : $selectedDates');
                                                  fetchFilterMarker(selectedDates);
                                                });
                                              },
                                            ));
                                      },
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                height: 340,
                                child: GoogleMap(
                                  initialCameraPosition: _myLocation,
                                  mapType: MapType.normal,
                                  markers: Set.of(markers.values),
                                  myLocationEnabled: true,
                                  myLocationButtonEnabled: true,
                                  zoomControlsEnabled: true,
                                  zoomGesturesEnabled: true,
                                  scrollGesturesEnabled: true,
                                  onMapCreated: (GoogleMapController controller) {
                                    _controller.complete(controller);
                                    fetchMarkers();
                                    // addKml(controller);
                                  },
                                  tiltGesturesEnabled: true,
                                  gestureRecognizers: < Factory < OneSequenceGestureRecognizer >> [
                                    new Factory < OneSequenceGestureRecognizer > (
                                          () => new EagerGestureRecognizer(),
                                    ),
                                  ].toSet()
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                )
            )
          ]
        )
      ),
    );
  }
}