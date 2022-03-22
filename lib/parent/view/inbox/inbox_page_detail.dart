import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_config/flutter_native_config.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:http/http.dart';
import 'package:ruangkeluarga/model/rk_child_location_model.dart';
import 'package:ruangkeluarga/global/global.dart';
import 'package:ruangkeluarga/utils/repository/media_repository.dart';
import 'package:ruangkeluarga/parent/view_model/inbox_notification_model.dart';
import 'package:ruangkeluarga/utils/rk_webview.dart';

import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InboxDetail extends StatefulWidget {
  // List<charts.Series> seriesList;
  @override
  _InboxDetailState createState() => _InboxDetailState();
  final InboxNotif inboxNotif;

  InboxDetail({Key? key, required this.inboxNotif}) : super(key: key);
}

class _InboxDetailState extends State<InboxDetail> {
  bool _switchValue = true;
  DateTime selectedDate = DateTime.now();
  DateTimeRange? selectedRange =
      DateTimeRange(start: DateTime.now(), end: DateTime.now());
  List<DateTime> selectedDates = [];
  String tanggal = '';
  late SharedPreferences prefs;

  Map<MarkerId, Marker> markers = {};
  late Future<Map<MarkerId, Marker>> loadMarker;
  List<LocationChild> listLocationChild = [];

  Map<String, dynamic> locMatrix = {};
  late Position currentPosition;
  String etaDuration = '0s';
  String etaDistance = '0 m';
  CameraPosition etaCamera =
      CameraPosition(target: LatLng(-6.1800525, 106.7106455), zoom: 15.0);

  // List<LatLng> polylineCoordinates = [];
  // Set<Polyline> route = {};
  // late PolylinePoints polylinePoints;
  bool showEta = false;

  Completer<GoogleMapController> _controller = Completer();
  CameraPosition _myLocationLatLng =
      CameraPosition(target: LatLng(-6.1800525, 106.7106455), zoom: 15.0);
  String _myLocationPlace = '';
  var url =
      'https://www.google.com/maps/timeline/kml?authuser=0&pb=!1m8!1m3!1i2021!2i4!3i1!2m3!1i2021!2i4!3i4';

  Future<void> addKml(GoogleMapController mapController) async {
    const MethodChannel channel =
        MethodChannel('ruangkeluarga.flutter.dev/kmlmap');
    try {
      // int kmlResourceId = await channel.invokeMethod('KML#@#$url');
      Uint8List kmlResourceId = await channel.invokeMethod('KML#@#$url');
      return mapController.channel
          ?.invokeMethod("map#addKML", <String, dynamic>{
        'resourceId': kmlResourceId,
      });
    } on PlatformException catch (e) {
      throw 'Unable to plot map: ${e.message}';
    }
  }

  Future<Map<MarkerId, Marker>> fetchMarkers() async {
    markers.clear();
    final childLocation = widget.inboxNotif.message.location!;
    MarkerId markerId = MarkerId("0");
    final coordinates = childLocation.coordinates;
    Marker marker = Marker(
        markerId: markerId,
        position:
            LatLng(double.parse(coordinates[0]), double.parse(coordinates[1])),
        infoWindow:
            InfoWindow(title: 'Location', snippet: childLocation.place));
    markers[markerId] = marker;

    _myLocationLatLng = CameraPosition(
      target: LatLng(
        double.parse(coordinates[0]),
        double.parse(coordinates[1]),
      ),
      zoom: 15.0,
    );
    _myLocationPlace = childLocation.place;
    // (await _controller.future).animateCamera(CameraUpdate.newCameraPosition(_myLocationLatLng));
    setState(() {});

    print('markers : $markers');
    return markers;
  }

  Future<void> getLocationMatrix() async {
    currentPosition = await Geolocator.getCurrentPosition();
    // LatLng parentPosition =
    //     LatLng(currentPosition.latitude, currentPosition.longitude);
    LatLng childPosition = _myLocationLatLng.target;
    List<double> origin = [currentPosition.longitude, currentPosition.latitude];
    List<double> destination = [
      childPosition.longitude,
      childPosition.latitude
    ];
    String apiKey = await FlutterNativeConfig.getConfig(
      android: "org.openrouteservices.api.API_KEY",
      ios: "org.openrouteservices.api.API_KEY",
    );

    print('Ini string openrouteservices api panas: $apiKey');
    Response res =
        await MediaRepository().getLocationMatrix(origin, destination, apiKey);
    print('resnya: ${res.statusCode}');
    if (res.statusCode == 200) {
      print('print res getLocationMatrix ${res.body}');
      final GoogleMapController controller = await _controller.future;
      double duration = 0, distance = 0;
      locMatrix = jsonDecode(res.body);
      if (locMatrix['durations'][0][1] is double)
        duration = locMatrix['durations'][0][1];
      if (locMatrix['distances'][0][1] is double)
        distance = locMatrix['distances'][0][1];

      etaDuration = secsToHours(duration);
      etaDistance = mToKm(distance);
      etaCamera = CameraPosition(
        target: LatLng(
          (_myLocationLatLng.target.latitude + currentPosition.latitude) / 2,
          (_myLocationLatLng.target.longitude + currentPosition.longitude) / 2,
        ),
        zoom: distance < 10000
            ? 10.0
            : distance < 100000
                ? 7.0
                : 5.0,
      );
      controller.animateCamera(CameraUpdate.newCameraPosition(etaCamera));
      showEta = true;
    }
    setState(() {});
  }

  // void fetchCurrentLoc() async {
  //   prefs = await SharedPreferences.getInstance();
  //   Response response = await MediaRepository()
  //       .fetchCurrentUserLocation(prefs.getString(rkEmailUser)!, widget.email);
  //   print('response request current loc ${response.body}');
  // }

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
        title: Text("Notifikasi SOS", style: TextStyle(color: cOrtuWhite)),
        backgroundColor: Colors.red[900],
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: cOrtuWhite),
          onPressed: () => Navigator.of(context).pop(),
        ),
        elevation: 0,
      ),
      body: FutureBuilder(
          future: loadMarker,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done)
              return wProgressIndicator();
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
                          child: Text(
                              dateFormat_EDMYHM(widget.inboxNotif.createAt),
                              style: TextStyle(color: cOrtuWhite)),
                        ),
                        Row(
                          children: [
                            IconButton(
                              color: cOrtuWhite,
                              icon: Icon(Icons.directions),
                              onPressed: () async {
                                showLoadingOverlay();
                                // await getRoute();
                                await getLocationMatrix();
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
                            gestureRecognizers:
                                <Factory<OneSequenceGestureRecognizer>>[
                              new Factory<OneSequenceGestureRecognizer>(
                                () => new EagerGestureRecognizer(),
                              ),
                            ].toSet()),
                      ),
                    ),
                    showEta
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                                Text('ETA: $etaDuration',
                                    style: TextStyle(
                                        fontSize: 20, color: cOrtuWhite)),
                                Text('Distance: $etaDistance',
                                    style: TextStyle(
                                        fontSize: 20, color: cOrtuWhite))
                              ])
                        : Container(),
                    Container(
                      padding: EdgeInsets.only(top: 10, bottom: 15),
                      child: Text(
                        _myLocationPlace != ''
                            ? 'Dikirim oleh ${widget.inboxNotif.message.childEmail!} \nNama lokasi: $_myLocationPlace'
                            : '',
                        style: TextStyle(fontSize: 16, color: cOrtuWhite),
                      ),
                    ),
                    // Divider(
                    //   thickness: 1,
                    //   color: cOrtuWhite,
                    // ),
                    // Container(
                    //   margin: EdgeInsets.all(10.0),
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //     children: [
                    //       Text(
                    //         'Timeline',
                    //         style: TextStyle(fontSize: 16, color: cOrtuWhite),
                    //       ),
                    //       SizedBox(width: 10),
                    //       Flexible(
                    //         child: GestureDetector(
                    //           child: Text(
                    //             '$tanggal',
                    //             maxLines: 2,
                    //             textAlign: TextAlign.right,
                    //             style:
                    //                 TextStyle(fontSize: 16, color: cOrtuBlue),
                    //           ),
                    //           onTap: () async {
                    //             showLoadingOverlay();
                    //             final pickedRange = await showDateRangePicker(
                    //                 context: context,
                    //                 confirmText: 'Confirm Text',
                    //                 firstDate: DateTime.now().subtract(
                    //                     const Duration(days: 365 * 3)),
                    //                 lastDate: DateTime.now()
                    //                     .add(const Duration(days: 365)),
                    //                 initialDateRange: selectedRange,
                    //                 initialEntryMode:
                    //                     DatePickerEntryMode.calendarOnly,
                    //                 builder: (ctx, child) {
                    //                   return Theme(
                    //                     data: ThemeData.dark(),
                    //                     child: child!,
                    //                   );
                    //                 });
                    //             if (pickedRange != null) {
                    //               selectedRange = pickedRange;
                    //               selectedDates = [
                    //                 pickedRange.start,
                    //                 pickedRange.end
                    //               ];
                    //               tanggal = selectedDates.first ==
                    //                       selectedDates.last
                    //                   ? '${dateFormat_EDMY(selectedDates.first)}'
                    //                   : '${dateFormat_EDMY(selectedDates.first)} -\n ${dateFormat_EDMY(selectedDates.last)}';
                    //               fetchFilterMarker(selectedDates);
                    //               setState(() {});
                    //             }
                    //             closeOverlay();
                    //           },
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    Divider(
                      thickness: 1,
                      color: cOrtuWhite,
                    ),
                    // Flexible(
                    //   child: ListView.builder(
                    //     itemCount: listLocationChild.length,
                    //     itemBuilder: (context, index) {
                    //       final data = listLocationChild[index];
                    //       return ListTile(
                    //         title: Text(
                    //           data.location.place,
                    //           style: TextStyle(fontSize: 16, color: cOrtuWhite),
                    //         ),
                    //         // isThreeLine: true,
                    //         // subtitle: Text(
                    //         //   'on Jln $index where in indonesia',
                    //         //   style: TextStyle(fontSize: 16, color: cOrtuWhite),
                    //         // ),
                    //         trailing: Text(
                    //           data.dateHistory,
                    //           style: TextStyle(fontSize: 16, color: cOrtuWhite),
                    //         ),
                    //         onTap: () async {
                    //           _myLocationPlace = data.location.place;
                    //           _myLocationLatLng = CameraPosition(
                    //             target: LatLng(
                    //               double.parse(data.location.coordinates[0]),
                    //               double.parse(data.location.coordinates[1]),
                    //             ),
                    //             zoom: 15.0,
                    //           );
                    //           final GoogleMapController controller =
                    //               await _controller.future;
                    //           controller.animateCamera(
                    //               CameraUpdate.newCameraPosition(
                    //                   _myLocationLatLng));

                    //           setState(() {});
                    //         },
                    //       );
                    //     },
                    //   ),
                    // ),
                    Container(
                        alignment: Alignment.bottomCenter,
                        margin: EdgeInsets.all(20),
                        child: roElevatedButton(
                          cColor: Colors.red,
                          radius: 10,
                          text: Padding(
                              padding: EdgeInsets.all(10),
                              child: Text(
                                "Lihat Panic Video",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              )),
                          onPress: () {
                            final String videoUrl =
                                widget.inboxNotif.message.videoUrl != null
                                    ? widget.inboxNotif.message.videoUrl
                                        .toString()
                                    : "";
                            if (videoUrl != '') {
                              showUrl(videoUrl, "Panic Video");
                            }
                          },
                        ))
                  ],
                ));
          }),
    );
  }
}
