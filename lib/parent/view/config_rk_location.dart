import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:http/http.dart';
import 'package:ruangkeluarga/model/rk_child_location_model.dart';
import 'package:ruangkeluarga/global/global.dart';
import 'package:ruangkeluarga/utils/repository/media_repository.dart';

import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  DateTimeRange? selectedRange = DateTimeRange(start: DateTime.now(), end: DateTime.now());
  List<DateTime> selectedDates = [];
  String tanggal = '';
  late SharedPreferences prefs;

  Map<MarkerId, Marker> markers = {};
  late Future<Map<MarkerId, Marker>> loadMarker;
  List<LocationChild> listLocationChild = [];

  Completer<GoogleMapController> _controller = Completer();
  CameraPosition _myLocationLatLng = CameraPosition(target: LatLng(-6.1800525, 106.7106455), zoom: 15.0);
  String _myLocationPlace = '';
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

  Future<Map<MarkerId, Marker>> fetchMarkers() async {
    markers.clear();
    var outputFormat = DateFormat('yyyy-MM-dd');
    var outputDate = outputFormat.format(DateTime.now());
    try {
      Response response = await MediaRepository().fetchUserLocation(widget.email, outputDate);
      if (response.statusCode == 200) {
        var json = jsonDecode(response.body);
        List locationChilds = json['timeLine'];

        if (json['resultCode'] == 'OK' && locationChilds.length > 0) {
          print('response fetch markers : ${response.body}');
          listLocationChild = locationChilds.map((model) => LocationChild.fromJson(model)).toSet().toList();
          listLocationChild.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          for (int i = 0; i < listLocationChild.length; i++) {
            final childLocation = listLocationChild[i];
            MarkerId markerId = MarkerId("$i");
            final coordinates = childLocation.location.coordinates;
            Marker marker = Marker(
                markerId: markerId,
                position: LatLng(double.parse(coordinates[0]), double.parse(coordinates[1])),
                infoWindow: InfoWindow(title: 'Location', snippet: childLocation.location.place));
            markers[markerId] = marker;
          }
          _myLocationLatLng = CameraPosition(
            target: LatLng(
              double.parse(listLocationChild.first.location.coordinates[0]),
              double.parse(listLocationChild.first.location.coordinates[1]),
            ),
            zoom: 15.0,
          );
          _myLocationPlace = listLocationChild.first.location.place;
          // (await _controller.future).animateCamera(CameraUpdate.newCameraPosition(_myLocationLatLng));
          setState(() {});
        } else {
          print('response fetch markers : ${response.body}');
          setState(() {});
        }
      } else {
        print('response fetch markers : ${response.statusCode}');
        setState(() {});
      }
    } catch (e, s) {
      print('fetchMarkers error : $e');
      print('fetchMarkers stack : $s');
    }

    print('markers : $markers');
    return markers;
  }

  void fetchFilterMarker(List<DateTime> rangeDate) async {
    markers.clear();
    listLocationChild.clear();
    var outputFormat = DateFormat('yyyy-MM-dd');
    var startDate = outputFormat.format(rangeDate[0]);
    var endDate = outputFormat.format(rangeDate[rangeDate.length - 1]);
    Response response = await MediaRepository().fetchFilterUserLocation(widget.email, startDate, endDate);
    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);
      if (json['resultCode'] == 'OK') {
        print('response fetch markers : ${response.body}');
        List locationChilds = json['timeLine'];
        listLocationChild = locationChilds.map((model) => LocationChild.fromJson(model)).toSet().toList();
        listLocationChild.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        for (int i = 0; i < listLocationChild.length; i++) {
          final childLocation = listLocationChild[i];
          MarkerId markerId = MarkerId("$i");
          final coordinates = childLocation.location.coordinates;
          Marker marker = Marker(
              markerId: markerId,
              position: LatLng(double.parse(coordinates[0]), double.parse(coordinates[1])),
              infoWindow: InfoWindow(title: 'Location', snippet: childLocation.location.place));
          markers[markerId] = marker;
        }
        _myLocationLatLng = CameraPosition(
          target: LatLng(
            double.parse(listLocationChild.first.location.coordinates[0]),
            double.parse(listLocationChild.first.location.coordinates[1]),
          ),
          zoom: 15.0,
        );
        _myLocationPlace = listLocationChild.first.location.place;
        (await _controller.future).animateCamera(CameraUpdate.newCameraPosition(_myLocationLatLng));

        setState(() {});
      } else {
        print('response fetch markers : ${response.body}');
        setState(() {});
      }
    } else {
      print('response fetch markers : ${response.statusCode}');
      setState(() {});
    }
  }

  void fetchCurrentLoc() async {
    prefs = await SharedPreferences.getInstance();
    Response response = await MediaRepository().fetchCurrentUserLocation(prefs.getString(rkEmailUser)!, widget.email);
    print('response request current loc ${response.body}');
  }

  @override
  void initState() {
    super.initState();
    tanggal = dateFormat_EDMY(DateTime.now());
    loadMarker = fetchMarkers();
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
      body: FutureBuilder(
          future: loadMarker,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) return wProgressIndicator();
            return Container(
                padding: EdgeInsets.only(left: 10, right: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text('Update Lokasi: 1 menit lalu', style: TextStyle(color: cOrtuWhite)),
                        ),
                        Row(
                          children: [
                            IconButton(
                              color: cOrtuWhite,
                              icon: Icon(Icons.directions),
                              onPressed: () {
                                showSnackbar('Belum di implementasi.', pShowDuration: Duration(seconds: 2));
                              },
                            ),
                            IconButton(
                              color: cOrtuWhite,
                              icon: Icon(Icons.my_location),
                              onPressed: () async {
                                showLoadingOverlay();
                                await fetchMarkers();
                                closeOverlay();
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    Flexible(
                      child: Container(
                        height: MediaQuery.of(context).size.height / 3,
                        child: GoogleMap(
                            initialCameraPosition: _myLocationLatLng,
                            mapType: MapType.normal,
                            markers: Set.of(markers.values),
                            myLocationEnabled: true,
                            myLocationButtonEnabled: true,
                            zoomControlsEnabled: true,
                            zoomGesturesEnabled: true,
                            scrollGesturesEnabled: true,
                            onMapCreated: (GoogleMapController controller) {
                              _controller.complete(controller);
                              // fetchMarkers();
                              // addKml(controller);
                            },
                            tiltGesturesEnabled: true,
                            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
                              new Factory<OneSequenceGestureRecognizer>(
                                () => new EagerGestureRecognizer(),
                              ),
                            ].toSet()),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 10, bottom: 15),
                      child: Text(
                        _myLocationPlace != '' ? 'Nama lokasi: $_myLocationPlace' : '',
                        style: TextStyle(fontSize: 16, color: cOrtuWhite),
                      ),
                    ),
                    Divider(
                      thickness: 1,
                      color: cOrtuWhite,
                    ),
                    Container(
                      margin: EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Timeline',
                            style: TextStyle(fontSize: 16, color: cOrtuWhite),
                          ),
                          SizedBox(width: 10),
                          Flexible(
                            child: GestureDetector(
                              child: Text(
                                '$tanggal',
                                maxLines: 2,
                                textAlign: TextAlign.right,
                                style: TextStyle(fontSize: 16, color: cOrtuBlue),
                              ),
                              onTap: () async {
                                showLoadingOverlay();
                                final pickedRange = await showDateRangePicker(
                                    context: context,
                                    confirmText: 'Confirm Text',
                                    firstDate: DateTime.now().subtract(const Duration(days: 365 * 3)),
                                    lastDate: DateTime.now().add(const Duration(days: 365)),
                                    initialDateRange: selectedRange,
                                    initialEntryMode: DatePickerEntryMode.calendarOnly,
                                    builder: (ctx, child) {
                                      return Theme(
                                        data: ThemeData.dark(),
                                        child: child!,
                                      );
                                    });
                                if (pickedRange != null) {
                                  selectedRange = pickedRange;
                                  selectedDates = [pickedRange.start, pickedRange.end];
                                  tanggal = selectedDates.first == selectedDates.last
                                      ? '${dateFormat_EDMY(selectedDates.first)}'
                                      : '${dateFormat_EDMY(selectedDates.first)} -\n ${dateFormat_EDMY(selectedDates.last)}';
                                  fetchFilterMarker(selectedDates);
                                  setState(() {});
                                }
                                closeOverlay();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      thickness: 1,
                      color: cOrtuWhite,
                    ),
                    Flexible(
                      child: ListView.builder(
                        itemCount: listLocationChild.length,
                        itemBuilder: (context, index) {
                          final data = listLocationChild[index];
                          return ListTile(
                            title: Text(
                              data.location.place,
                              style: TextStyle(fontSize: 16, color: cOrtuWhite),
                            ),
                            // isThreeLine: true,
                            // subtitle: Text(
                            //   'on Jln $index where in indonesia',
                            //   style: TextStyle(fontSize: 16, color: cOrtuWhite),
                            // ),
                            trailing: Text(
                              data.dateHistory,
                              style: TextStyle(fontSize: 16, color: cOrtuWhite),
                            ),
                            onTap: () async {
                              _myLocationPlace = data.location.place;
                              _myLocationLatLng = CameraPosition(
                                target: LatLng(
                                  double.parse(data.location.coordinates[0]),
                                  double.parse(data.location.coordinates[1]),
                                ),
                                zoom: 15.0,
                              );
                              final GoogleMapController controller = await _controller.future;
                              controller.animateCamera(CameraUpdate.newCameraPosition(_myLocationLatLng));

                              setState(() {});
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ));
          }),
    );
  }
}
