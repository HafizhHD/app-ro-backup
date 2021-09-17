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

class _CameraAppState extends State<CameraApp> {
  late CameraController controller;
  int cancelSOSCountDown = 5;
  int startSOSCountDown = 0;
  int recordingDuration = 10;
  late Timer cancelSOSTimer;
  late Timer startSOSTimer;
  ChildController _childController = Get.find();

  void initAsync() async {
    controller = CameraController(cameras[0], ResolutionPreset.max);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    initAsync();
    startCancelTimer();
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

        Navigator.pop(context);
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
                  margin: EdgeInsets.all(10),
                  // decoration: BoxDecoration(
                  //   borderRadius: BorderRadius.all(Radius.circular(15)),
                  // ),
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(15.0),
                      child: CameraPreview(
                        controller,
                        child: cancelSOSCountDown > 0 && startSOSCountDown < recordingDuration
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
                      )),
                ),
              ),
              Container(
                padding: EdgeInsets.only(left: 10, right: 10),
                margin: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: cancelSOSCountDown > 0 ? Colors.red : cPrimaryBg,
                  borderRadius: BorderRadius.all(Radius.circular(50)),
                ),
                child: Container(
                  height: 50,
                  margin: EdgeInsets.all(10),
                  child: roElevatedButton(
                    cColor: Colors.white,
                    radius: 50,
                    text: Text(
                      cancelSOSCountDown > 0 ? 'Batalkan SOS ($cancelSOSCountDown)' : 'Merekam SOS ($startSOSCountDown)',
                      style: TextStyle(color: Colors.red, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    onPress: cancelSOSCountDown > 0
                        ? () async {
                            // showLoadingOverlay();
                            // await controller.stopVideoRecording();
                            // closeOverlay();
                            // controller.dispose();
                            Navigator.pop(context);
                          }
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
