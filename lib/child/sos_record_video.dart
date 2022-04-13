import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:location/location.dart';
import 'package:ruangkeluarga/child/child_controller.dart';
import 'package:ruangkeluarga/child/home_child.dart';
import 'package:ruangkeluarga/global/custom_widget/global_widget.dart';
import 'package:ruangkeluarga/global/global.dart';
import 'package:ruangkeluarga/utils/repository/media_repository.dart';

class CameraApp extends StatefulWidget {
  @override
  _CameraAppState createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> with TickerProviderStateMixin {
  late CameraController controller;
  int cancelSOSCountDown = 0;
  int startSOSCountDown = 0;
  int recordingDuration = 10;
  late Timer cancelSOSTimer;
  late Timer startSOSTimer;
  bool finishRecording = false;
  ChildController _childController = Get.find();

  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 500),
    vsync: this,
  );
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.fastOutSlowIn,
  );

  void initAsync() async {
    controller = CameraController(cameras[0], ResolutionPreset.medium);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        startCancelTimer();
      });
    });
  }

  @override
  void initState() {
    super.initState();
    initAsync();
  }

  @override
  void dispose() {
    controller.dispose();
    cancelSOSTimer.cancel();
    startSOSTimer.cancel();
    super.dispose();
  }

  void startCancelTimer() {
    print('startCancelTimer()');
    cancelSOSTimer = Timer.periodic(Duration(seconds: 1), (timer) async {
      if (cancelSOSCountDown == 0) {
        cancelSOSTimer.cancel();
        startRecordTimer();
      } else
        cancelSOSCountDown--;
      setState(() {});
    });
  }

  void startRecordTimer() {
    print('start Recording');
    controller.startVideoRecording();
    startSOSTimer = Timer.periodic(Duration(seconds: 1), (timer) async {
      if (startSOSCountDown == recordingDuration) {
        startSOSTimer.cancel();
        final recording = await controller.stopVideoRecording();
        _childController.sentPanicSOS(recording);
        setState(() {
          finishRecording = true;
          _controller.forward();
        });
        //Navigator.pop(context);
      } else {
        startSOSCountDown++;
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Container();
    }
    return WillPopScope(
      onWillPop: () => Future<bool>.value(false),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: cPrimaryBg,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Flexible(
                child: Container(
                    margin: EdgeInsets.all(0),
                    // decoration: BoxDecoration(
                    //   borderRadius: BorderRadius.all(Radius.circular(15)),
                    // ),
                    child: !finishRecording
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(1.0),
                            child: CameraPreview(
                              controller,
                              child: cancelSOSCountDown > 0 &&
                                      startSOSCountDown < recordingDuration
                                  ? null
                                  : Align(
                                      alignment: Alignment.topRight,
                                      child: Container(
                                        margin: EdgeInsets.all(10),
                                        child: Icon(
                                          Icons.videocam_rounded,
                                          color: Colors.red,
                                          size: 50,
                                        ),
                                      ),
                                    ),
                            ))
                        : ScaleTransition(
                            scale: _animation,
                            child: Container(
                                margin: EdgeInsets.all(10),
                                padding: EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15.0),
                                    color: cAsiaBlue),
                                child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                          padding: EdgeInsets.all(15),
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: cOrtuWhite),
                                          child: Icon(Icons.check_sharp,
                                              color: cAsiaBlue, size: 40)),
                                      Text(
                                          'KAMI SUDAH MENGHUBUNGI ORANGTUA KAMU',
                                          style: TextStyle(
                                              color: cOrtuWhite,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.center),
                                      Text(
                                          'Orangtua kamu sudah dihubungi tentang situasi kamu dan mengirimkan lokasi kamu berada saat ini. Mereka sedang menuju ke tempat kamu.',
                                          style: TextStyle(color: cOrtuWhite),
                                          textAlign: TextAlign.justify),
                                      RichText(
                                          text: TextSpan(
                                              text: 'Jangan Panik. ',
                                              style: TextStyle(
                                                  color: cOrtuWhite,
                                                  fontWeight: FontWeight.bold),
                                              children: <TextSpan>[
                                                TextSpan(
                                                    text:
                                                        'Ingat, panik tidak akan membantu apapun. Panik adalah musuhmu dalam melawan perlombaan waktu ini.',
                                                    style: TextStyle(
                                                        color: cOrtuWhite,
                                                        fontWeight:
                                                            FontWeight.normal))
                                              ]),
                                          textAlign: TextAlign.justify),
                                      RichText(
                                          text: TextSpan(
                                              text: 'Tetap tenang. ',
                                              style: TextStyle(
                                                  color: cOrtuWhite,
                                                  fontWeight: FontWeight.bold),
                                              children: <TextSpan>[
                                                TextSpan(
                                                    text:
                                                        'Sangat penting untuk tetap tenang saat ini. Semua akan baik-baik saja jika kita tetap tenang dalam situasi apapun.',
                                                    style: TextStyle(
                                                        color: cOrtuWhite,
                                                        fontWeight:
                                                            FontWeight.normal)),
                                              ]),
                                          textAlign: TextAlign.justify),
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            ElevatedButton(
                                                child: Text('Kirim Ulang',
                                                    style: TextStyle(
                                                        color: cAsiaBlue,
                                                        fontSize: 16)),
                                                style: ElevatedButton.styleFrom(
                                                    primary: cOrtuWhite,
                                                    padding:
                                                        EdgeInsets.all(20)),
                                                onPressed: (() {
                                                  initAsync();
                                                  setState(() {
                                                    startSOSCountDown = 0;
                                                    finishRecording = false;
                                                    _controller.reverse();
                                                  });
                                                  startCancelTimer();
                                                })),
                                            ElevatedButton(
                                                child: Text('Tutup',
                                                    style: TextStyle(
                                                        color: cAsiaBlue,
                                                        fontSize: 16)),
                                                style: ElevatedButton.styleFrom(
                                                    primary: cOrtuWhite,
                                                    padding:
                                                        EdgeInsets.all(20)),
                                                onPressed: (() =>
                                                    {Navigator.pop(context)}))
                                          ])
                                    ])))),
              ),
              !finishRecording
                  ? Container(
                      height: 50,
                      margin: EdgeInsets.only(left: 10, right: 10),
                      // child: !finishRecording
                      //     ? roElevatedButton(
                      //         cColor: Colors.white,
                      //         radius: 50,
                      //         text: Text(
                      //           cancelSOSCountDown > 0
                      //               ? 'Batalkan SOS ($cancelSOSCountDown)'
                      //               : 'Merekam SOS ($startSOSCountDown)',
                      //           style: TextStyle(
                      //               color: Colors.red,
                      //               fontSize: 18,
                      //               fontWeight: FontWeight.bold),
                      //         ),
                      //         onPress: cancelSOSCountDown > 0
                      //             ? () async {
                      //                 // showLoadingOverlay();
                      //                 // await controller.stopVideoRecording();
                      //                 // closeOverlay();
                      //                 // controller.dispose();
                      //                 Navigator.pop(context);
                      //               }
                      //             : null,
                      //       )
                      //     : Container(),
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                                flex: 7,
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Tetap tenang!',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      Text(
                                          'Rekam video sekitar kamu untuk dikirimkan ke orangtua.')
                                    ])),
                            Expanded(
                                flex: 3,
                                child: Text('${startSOSCountDown}s',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 30),
                                    textAlign: TextAlign.center))
                          ]))
                  : SizedBox.shrink()
              // Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              //   Container(
              //     padding: EdgeInsets.only(left: 10, right: 10),
              //     margin: EdgeInsets.all(10),
              //     decoration: BoxDecoration(
              //       color: cancelSOSCountDown > 0 ? Colors.red : cPrimaryBg,
              //       borderRadius: BorderRadius.all(Radius.circular(50)),
              //     ),
              //     child: Container(
              //       height: 50,
              //       margin: EdgeInsets.all(10),
              //       child: roElevatedButton(
              //         cColor: Colors.white,
              //         radius: 50,
              //         text: Text(
              //           cancelSOSCountDown > 0
              //               ? 'Batalkan SOS ($cancelSOSCountDown)'
              //               : 'Merekam SOS ($startSOSCountDown)',
              //           style: TextStyle(
              //               color: Colors.red,
              //               fontSize: 18,
              //               fontWeight: FontWeight.bold),
              //         ),
              //         onPress: cancelSOSCountDown > 0
              //             ? () async {
              //                 // showLoadingOverlay();
              //                 // await controller.stopVideoRecording();
              //                 // closeOverlay();
              //                 // controller.dispose();
              //                 Navigator.pop(context);
              //               }
              //             : null,
              //       ),
              //     ),
              //   ),
              //   // Container(
              //   //   padding: EdgeInsets.all(2),
              //   //   margin: EdgeInsets.all(10),
              //   //   decoration: BoxDecoration(
              //   //     color: Colors.red,
              //   //     borderRadius: BorderRadius.all(Radius.circular(50)),
              //   //   ),
              //   //   child: Container(
              //   //     height: 50,
              //   //     margin: EdgeInsets.all(10),
              //   //     child: roElevatedButton(
              //   //         cColor: Colors.white,
              //   //         radius: 50,
              //   //         text: Text(
              //   //           'Batalkan SOS',
              //   //           style: TextStyle(
              //   //               color: Colors.red,
              //   //               fontSize: 18,
              //   //               fontWeight: FontWeight.bold),
              //   //         ),
              //   //         onPress: () async {
              //   //           // showLoadingOverlay();
              //   //           // await controller.stopVideoRecording();
              //   //           // closeOverlay();
              //   //           // controller.dispose();
              //   //           Navigator.pop(context);
              //   //         }),
              //   //   ),
              //   // )
              // ]),
            ],
          ),
        ),
      ),
    );
  }
}
