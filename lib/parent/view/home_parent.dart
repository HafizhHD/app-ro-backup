import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart' hide Response;

import 'package:flutter/material.dart';

import 'package:ruangkeluarga/model/rk_child_model.dart';
import 'package:ruangkeluarga/parent/view/detail_child_view.dart';
import 'package:ruangkeluarga/parent/view/main/parent_controller.dart';
import 'package:ruangkeluarga/parent/view/setup_invite_child.dart';
import 'package:ruangkeluarga/plugin_device_app.dart';
import 'package:ruangkeluarga/global/global.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ruangkeluarga/model/mitran_model.dart';
import 'package:ruangkeluarga/utils/repository/media_repository.dart';
import 'dart:convert';

class HomeParentPage extends StatefulWidget {
  @override
  _HomeParentPageState createState() => _HomeParentPageState();
}

class _HomeParentPageState extends State<HomeParentPage> {
  late SharedPreferences prefs;
  bool flag = false;
  late Future<List<Application>> apps;
  List<Application> itemsApp = [];
  List<Child> childsList = [];
  String childName = '';
  String userName = '';
  String emailUser = '';
  String midtranToken = '';
  late Future fLogin;
  final parentController = Get.find<ParentController>();
  final api = MediaRepository();

  // void getUsageStats() async {
  //   try {
  //     DateTime endDate = new DateTime.now();
  //     DateTime startDate = endDate.subtract(Duration(hours: 1));
  //     List<AppUsageInfo> infoList =
  //         await AppUsage.getAppUsage(startDate, endDate);
  //     setState(() {
  //       _infos = infoList;
  //       log('list info $infoList');
  //     });

  //     for (var info in infoList) {
  //       print(info.toString());
  //     }
  //   } on AppUsageException catch (exception) {
  //     print(exception);
  //   }
  // }

  // void getListApps() async {
  //   try {
  //     List<Application> appData = await DeviceApps.getInstalledApplications(
  //         includeAppIcons: true,
  //         includeSystemApps: true,
  //         onlyAppsWithLaunchIntent: true);
  //     SharedPreferences prefs = await SharedPreferences.getInstance();
  //     itemsApp = appData;
  //     prefs.setString("appsLists", json.encode(itemsApp));
  //     prefs.commit();

  //     // return appData;
  //   } catch (exception) {
  //     print(exception);
  //     // return [];
  //   }
  // }

  void setBindingData() async {
    prefs = await SharedPreferences.getInstance();
    userName = prefs.getString(rkUserName)!;
    emailUser = prefs.getString(rkEmailUser)!;
    if (prefs.getString("rkChildName") != null) {
      childName = prefs.getString("rkChildName")!;
      setState(() {
        flag = true;
      });
    }

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    setBindingData();
    fLogin = parentController.futureHasLogin();
  }

  Future<List<MidtranAuthModel>> getMidtranToken() async {
    final res = await api.authMidtrans();
    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);
      if (json['resultCode'] == "OK") {
        List comments = json['resultData'];
        final result =
        comments.map((e) => MidtranAuthModel.fromJson(e)).toList();
        print('result: $result');
        setState(() {
          midtranToken = result[0].token.toString();
        });
        return result;
      }
    }
    print('Error fetchContentComment: ${res.statusCode}');
    return [];
  }

  Future<List<MidtranAuthModel>> StratMidtranTransaction() async {
    final res = await api.authMidtrans();
    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);
      if (json['resultCode'] == "OK") {
        List comments = json['resultData'];
        final result =
        comments.map((e) => MidtranAuthModel.fromJson(e)).toList();
        print('result: $result');
        setState(() {
          midtranToken = result[0].token.toString();
        });
        return result;
      }
    }
    print('Error fetchContentComment: ${res.statusCode}');
    return [];
  }
  void showSelectUserType(context) async {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          backgroundColor: Colors.transparent,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 10.0, right: 10.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "",
                      style: TextStyle(fontSize: 14.0),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    color: cOrtuWhite,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  )
                ],
              ),
            ),
            Divider(),
            Padding(
              padding: EdgeInsets.all(10.0),
              child: InkWell(
                onTap: () async {
                  Navigator.of(context, rootNavigator: true).pop();
                  final res = await Navigator.push(
                    context,
                    MaterialPageRoute<Object>(
                        builder: (BuildContext context) =>
                            SetupInviteChildPage(
                                address: parentController.parentProfile
                                    .address!,
                                userTypeStr: "child")),
                  );
                  print('Add Child Response: $res');
                  if (childsList.length >= 1) {
                    await getMidtranToken();
                    showPaymentPeriode(context);
                  } else {
                    if (res.toString().toLowerCase() == 'addchild')
                      setState(() {
                        parentController.getParentChildData();
                      });
                  }
                },
                child: Image.asset('assets/images/invitation_anak.png'),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10.0),
              child: InkWell(
                onTap: () async {
                  Navigator.of(context, rootNavigator: true).pop();
                  final res = await Navigator.push(
                    context,
                    MaterialPageRoute<Object>(
                        builder: (BuildContext context) => SetupInviteChildPage(
                            address: parentController.parentProfile.address!,
                            userTypeStr: "parent")),
                  );
                  print('Add Child Response: $res');
                  if (res.toString().toLowerCase() == 'addchild')
                    setState(() {
                      parentController.getParentChildData();
                    });
                },
                child: Image.asset('assets/images/invitation_parent.png'),
              ),
            )
          ],
        );
      },
    );
  }

  void showPaymentPeriode(context) async {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          backgroundColor: Colors.transparent,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 10.0, right: 10.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "",
                      style: TextStyle(fontSize: 14.0),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    color: cOrtuWhite,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  )
                ],
              ),
            ),
            Divider(),
            Padding(
              padding: EdgeInsets.all(10.0),
              child: InkWell(
                onTap: () async {
                  await getMidtranToken();
                  if (midtranToken != "") {

                  }
                },
                child: Image.asset('assets/images/enam_bulan.png'),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10.0),
              child: InkWell(
                onTap: () async {
                  Navigator.of(context, rootNavigator: true).pop();
                  final res = await Navigator.push(
                    context,
                    MaterialPageRoute<Object>(
                        builder: (BuildContext context) => SetupInviteChildPage(
                            address: parentController.parentProfile.address!,
                            userTypeStr: "parent")),
                  );
                  print('Add Child Response: $res');
                  if (res.toString().toLowerCase() == 'addchild')
                    setState(() {
                      parentController.getParentChildData();
                    });
                },
                child: Image.asset('assets/images/satu_tahun.png'),
              ),
            )
          ],
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return FutureBuilder(
        future: fLogin,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done)
            return wProgressIndicator();

          return RefreshIndicator(
            onRefresh: () async {
              await parentController.getParentChildData();
              setState(() {
                parentController.getWeeklyUsageStatistic();
              });
            },
            child:
                // Flexible(
                //   flex: 1,
                //   child: Container(
                //     margin: const EdgeInsets.all(10.0), //Same as `blurRadius` i guess
                //     child: ListView.builder(
                //       padding: EdgeInsets.all(5.0),
                //       shrinkWrap: false,
                //       scrollDirection: Axis.horizontal,
                //       itemCount: 2,
                //       itemBuilder: (BuildContext context, int index) => Card(
                //         shape: RoundedRectangleBorder(
                //           borderRadius: BorderRadius.circular(10.0),
                //         ),
                //         child: GestureDetector(
                //           child: Row(
                //             children: [
                //               Container(
                //                 decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0)),
                //                 // child: Center(child: Text('Dummy Card Text', style: TextStyle(color: Colors.black)))
                //                 child: Image.asset('assets/images/hkbpgo.png'),
                //               ),
                //             ],
                //           ),
                //           onTap: () => parentController.setBottomNavIndex(1),
                //         ),
                //       ),
                //     ),
                //   ),
                // ),
                _childDataLayout(),
            // Flexible(
            //   flex: 2,
            //   child: ListView.builder(
            //     physics: BouncingScrollPhysics(),
            //     scrollDirection: Axis.horizontal,
            //     itemCount: _ids.length,
            //     itemBuilder: (BuildContext context, int position) {
            //       return Container(
            //         width: screenSize.width / 2,
            //         height: screenSize.height / 4,
            //         color: Colors.transparent,
            //         margin: const EdgeInsets.all(10),
            //         child: _coBrandContent(
            //           _ids[position],
            //           'Title Here',
            //           'Content: Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
            //           () {},
            //           screenSize.height / 4 / 2,
            //         ),
            //       );
            //     },
            //   ),
            // ),
          );
        });
  }

  Widget _coBrandContent(String imagePath, String title, String content,
      Function onTap, double screenHeight) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
        image: DecorationImage(
          image: AssetImage('assets/images/$imagePath'),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(height: screenHeight + 50),
          Flexible(
            child: Container(
              padding: EdgeInsets.all(10).copyWith(bottom: 0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.0),
                color: Colors.black54,
              ),
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$title',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: cOrtuText),
                  ),
                  Text(
                    '$content',
                    softWrap: true,
                    style: TextStyle(color: cOrtuText),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _childDataLayout() {
    final screenSize = MediaQuery.of(context).size;

    return FutureBuilder<List<Child>>(
        future: parentController.fChildList.value,
        builder: (BuildContext context, AsyncSnapshot<List<Child>> data) {
          if (!data.hasData) return wProgressIndicator();
          childsList = data.data!;
          flag = childsList.length > 0;
          if (childsList.length == 0) {
            return Container(
              margin: const EdgeInsets.all(10), //Same as `blurRadius` i guess
              padding: EdgeInsets.all(10),
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width - 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: cAsiaBlue,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Hanya 10 Menit!\nUntuk membuat Akun Anak Anda',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: cOrtuWhite),
                    textAlign: TextAlign.left,
                  ),
                  Container(
                      padding: EdgeInsets.all(5),
                      child: Image.asset(
                          'assets/images/icon/undraw_connection_re_lcud.png',
                          height: 150,
                          fit: BoxFit.fitHeight)),
                  Container(
                    padding: EdgeInsets.all(5),
                    child: Text(
                      'Hubungkan perangkat anak Anda untuk melakukan Pengawasan & Kontrol',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: cOrtuWhite),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 10, left: 20, right: 20),
                    child: ElevatedButton(
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all(
                            (RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)))),
                        backgroundColor:
                            MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                            if (states.contains(MaterialState.disabled))
                              return cDisabled;
                            return cOrtuWhite;
                          },
                        ),
                        elevation: MaterialStateProperty.resolveWith((states) {
                          if (states.contains(MaterialState.disabled) ||
                              states.contains(MaterialState.pressed)) return 0;
                          if (states.contains(MaterialState.hovered)) return 6;
                          return 4;
                        }),
                      ),
                      child: Text('DAFTAR AKUN ANAK ANDA',
                          style: TextStyle(
                            color: cAsiaBlue,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          )),
                      onPressed: () async {
                        final res = await Navigator.push(
                          context,
                          MaterialPageRoute<Object>(
                              builder: (BuildContext context) =>
                                  SetupInviteChildPage(
                                      address: parentController
                                          .parentProfile.address!,
                                      userTypeStr: "child")),
                        );
                        print('Add Child Response: $res');
                        if (res.toString().toLowerCase() == 'addchild')
                          setState(() {
                            parentController.getParentChildData();
                          });
                      },
                    ),
                  ),
                  // SizedBox(height: 10),
                  // Container(
                  //   padding: EdgeInsets.all(10),
                  //   child: Text(
                  //     'waktu yang di perlukan sekitar 10 menit',
                  //     textAlign: TextAlign.center,
                  //   ),
                  // ),
                  //
                ],
              ),
            );
          } else {
            return Container(
                margin: EdgeInsets.only(top: 5),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      flag == false
                          ? SizedBox.shrink()
                          : Container(
                              padding: EdgeInsets.only(left: 15, right: 15),
                              child: Container(
                                  child: TextButton(
                                      style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  cAsiaBlue)),
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.add_circle_rounded,
                                                color: cOrtuWhite),
                                            SizedBox(width: 10),
                                            Text('Tambah Anggota',
                                                style: TextStyle(
                                                    color: cOrtuWhite,
                                                    fontSize: 16))
                                          ]),
                                      onPressed: () async {
                                        showSelectUserType(context);
                                      })
                              )
                      ),
                      Expanded(
                          child: ListView.builder(
                              // physics: NeverScrollableScrollPhysics(),
                              physics: AlwaysScrollableScrollPhysics(),
                              shrinkWrap: true,
                              scrollDirection:
                                  Axis.vertical,
                              itemCount: childsList.length,
                              itemBuilder: (BuildContext context, int index) {
                                parentController.setModeAsuh(
                                    childsList[index].childOfNumber ?? 0, 1);
                                final thisChild = childsList[index];
                                return Container(
                                  margin: EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 15),
                                  // constraints: BoxConstraints(maxHeight: screenSize.height / 3, maxWidth: screenSize.width),
                                  child: ChildCardWithBottomSheet(
                                      childData: thisChild,
                                      childIndex: index,
                                      prefs: prefs),
                                );
                              }))
                    ]));
          }
        });
  }
}

class ChildCardWithBottomSheet extends StatelessWidget {
  final Child childData;
  final int childIndex;
  final SharedPreferences prefs;

  final parentController = Get.find<ParentController>();

  ChildCardWithBottomSheet(
      {required this.childData, required this.childIndex, required this.prefs});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final double paddingValue = 8;
    final bool hasPhoto =
        childData.imgPhoto != null && childData.imgPhoto != '';
    final colorVariant = [
      Color(0x99990000),
      Color(0x99009900),
      Color(0x99000099)
    ];

    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
        // margin: EdgeInsets.all(paddingValue),
        width: screenSize.width - paddingValue * 2,
        decoration: BoxDecoration(
          color: colorVariant[childIndex % 3],
          borderRadius: childData.status == 'invitation'
              ? BorderRadius.circular(10)
              : BorderRadius.only(
                  topLeft: Radius.circular(10), topRight: Radius.circular(10)),
        ),
        constraints: BoxConstraints(maxHeight: screenSize.height * 0.25),
        child: Stack(
          children: [
            hasPhoto
                ? Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15.0),
                      child: Image.network(
                        childData.imgPhoto!,
                        fit: BoxFit.cover,
                        loadingBuilder: (BuildContext context, Widget child,
                            ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              color: cOrtuOrange,
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                      ),
                    ),
                  )
                : Align(
                    alignment: Alignment.center,
                    child: Container(
                      child: Icon(
                        Icons.person,
                        size: 100,
                        color: cOrtuWhite,
                      ),
                    ),
                  ),
            Align(
                alignment: Alignment.topLeft,
                child: Container(
                    margin: EdgeInsets.only(left: 20, top: 20),
                    child: Text(childData.name ?? '',
                        style: TextStyle(
                            color: cOrtuWhite,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)))),
            // Align(
            //   alignment: Alignment.topRight,
            //   child: Container(
            //     margin: EdgeInsets.only(right: 4, top: 4),
            //     child: IconButton(
            //       color: Colors.black,
            //       iconSize: 40,
            //       padding: EdgeInsets.all(0),
            //       icon: Icon(Icons.add_circle_outline_rounded),
            //       onPressed: () async {
            //         showSelectUserType(context);
            //       },
            //     ),
            //   ),
            // ),
            childData.status == 'invitation'
                ? SizedBox.shrink()
                : Align(
                    alignment: Alignment.bottomCenter,
                    child: DraggableScrollableSheet(
                      expand: false,
                      initialChildSize: 0.3,
                      minChildSize: 0.3,
                      maxChildSize: 0.3,
                      builder: (BuildContext context,
                          ScrollController scrollController) {
                        return Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.only(left: 5, right: 5),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.zero,
                          ),
                          width: screenSize.width,
                          child: NotificationListener(
                            onNotification:
                                (OverscrollIndicatorNotification overscroll) {
                              overscroll.disallowGlow();
                              return true;
                            },
                            child: Column(
                              children: [
                                // Center(
                                //   child: Container(
                                //     margin: EdgeInsets.only(top: 5),
                                //     width: screenSize.width / 6,
                                //     height: 5,
                                //     decoration: BoxDecoration(
                                //         color: cOrtuGrey,
                                //         borderRadius:
                                //             BorderRadius.all(Radius.circular(15))),
                                //   ),
                                // ),
                                Flexible(
                                  child: Container(
                                    alignment: Alignment.center,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        // Container(
                                        //   margin: EdgeInsets.only(
                                        //       top: 5, left: 10.0, right: 10),
                                        //   child: Text(
                                        //     '${childData.name}',
                                        //     style: TextStyle(
                                        //         color: Colors.white,
                                        //         fontSize: 24,
                                        //         fontWeight: FontWeight.bold),
                                        //   ),
                                        // ),
                                        Container(
                                          margin: EdgeInsets.only(
                                              left: 5, right: 10),
                                          child: childData.status ==
                                                  'invitation'
                                              ? Container(
                                                  margin: EdgeInsets.all(5),
                                                  child: Text(
                                                    ' ',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16),
                                                  ))
                                              : GetBuilder<ParentController>(
                                                  builder: (ctrl) {
                                                    final thisScreenTime =
                                                        ctrl.mapChildScreentime[
                                                            childData.email];
                                                    final thisSTGaming =
                                                        ctrl.mapChildScreentimeGaming[
                                                            childData.email];
                                                    final thisSTSocial =
                                                        ctrl.mapChildScreentimeSocial[
                                                            childData.email];
                                                    return Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        contentTime(
                                                            'Screen Time',
                                                            thisScreenTime ??
                                                                '0s'),
                                                        contentTime(
                                                            'Gaming',
                                                            thisSTGaming ??
                                                                '0s'),
                                                        contentTime(
                                                            'Social Media',
                                                            thisSTSocial ??
                                                                '0s'),
                                                      ],
                                                    );
                                                  },
                                                ),
                                        ),
                                        // childData.status == 'invitation'
                                        //     ? Container(
                                        //         margin: EdgeInsets.only(
                                        //             left: 15,
                                        //             right: 15,
                                        //             top: 5,
                                        //             bottom: 5),
                                        //         child: FlatButton(
                                        //           height: 35,
                                        //           minWidth: 100,
                                        //           shape:
                                        //               new RoundedRectangleBorder(
                                        //             borderRadius:
                                        //                 new BorderRadius
                                        //                     .circular(15.0),
                                        //           ),
                                        //           onPressed: () async {
                                        //             await Future(() {
                                        //               Navigator.of(context).push(
                                        //                   MaterialPageRoute(
                                        //                       builder: (context) =>
                                        //                           InviteChildQR(
                                        //                               allData: [
                                        //                                 prefs.getString(rkEmailUser) !=
                                        //                                         null
                                        //                                     ? prefs.getString(rkEmailUser)!
                                        //                                     : '',
                                        //                                 childData.email !=
                                        //                                         null
                                        //                                     ? childData.email!
                                        //                                     : '',
                                        //                                 childData.phone !=
                                        //                                         null
                                        //                                     ? childData.phone!
                                        //                                     : '',
                                        //                                 childData.name !=
                                        //                                         null
                                        //                                     ? childData.name!
                                        //                                     : '',
                                        //                                 childData.age !=
                                        //                                         null
                                        //                                     ? childData.age!
                                        //                                     : 10,
                                        //                                 childData.status !=
                                        //                                         null
                                        //                                     ? childData.status!
                                        //                                     : '',
                                        //                                 childData.childOfNumber !=
                                        //                                         null
                                        //                                     ? childData.childOfNumber!
                                        //                                     : 1,
                                        //                                 childData.childNumber !=
                                        //                                         null
                                        //                                     ? childData.childNumber!
                                        //                                     : 1,
                                        //                                 childData.imgPhoto !=
                                        //                                         null
                                        //                                     ? childData.imgPhoto!
                                        //                                     : '',
                                        //                                 childData.birdDate !=
                                        //                                         null
                                        //                                     ? childData.birdDate!.toIso8601String()
                                        //                                     : '',
                                        //                                 childData.address !=
                                        //                                         null
                                        //                                     ? childData.address!
                                        //                                     : '',
                                        //                                 'child'
                                        //                               ],
                                        //                               prefs:
                                        //                                   prefs)));
                                        //             });
                                        //           },
                                        //           color: cOrtuWhite,
                                        //           child: Text(
                                        //             "MENUNGGU AKTIVASI",
                                        //             style: TextStyle(
                                        //               fontFamily: 'Raleway',
                                        //               fontWeight:
                                        //                   FontWeight.bold,
                                        //               fontSize: 15,
                                        //             ),
                                        //           ),
                                        //         ))
                                        // : Container(
                                        Container(
                                            // child: Row(
                                            //   mainAxisAlignment:
                                            //       MainAxisAlignment.spaceBetween,
                                            //   children: [
                                            //     // GetBuilder<ParentController>(builder: (ctrl) {
                                            //     //   return Row(
                                            //     //     children: [
                                            //     //       GestureDetector(
                                            //     //         onTap: () => ctrl.setModeAsuh(childData.childOfNumber ?? 0, 1),
                                            //     //         child: Icon(
                                            //     //           ctrl.getmodeAsuh(childData.childOfNumber ?? 0) >= 1 ? Icons.looks_one : Icons.looks_one_outlined,
                                            //     //           color: cOrtuBlue,
                                            //     //           size: 35,
                                            //     //         ),
                                            //     //       ),
                                            //     //       GestureDetector(
                                            //     //         onTap: () => ctrl.setModeAsuh(childData.childOfNumber ?? 0, 2),
                                            //     //         child: Icon(
                                            //     //           ctrl.getmodeAsuh(childData.childOfNumber ?? 0) >= 2 ? Icons.looks_two : Icons.looks_two_outlined,
                                            //     //           color: cOrtuBlue,
                                            //     //           size: 35,
                                            //     //         ),
                                            //     //       ),
                                            //     //       GestureDetector(
                                            //     //         onTap: () => ctrl.setModeAsuh(childData.childOfNumber ?? 0, 3),
                                            //     //         child: Icon(
                                            //     //           ctrl.getmodeAsuh(childData.childOfNumber ?? 0) == 3 ? Icons.looks_3 : Icons.looks_3_outlined,
                                            //     //           color: cOrtuBlue,
                                            //     //           size: 35,
                                            //     //         ),
                                            //     //       ),
                                            //     //     ],
                                            //     //   );
                                            //     // }),
                                            //     IconButton(
                                            //       iconSize: 35,
                                            //       onPressed: () {
                                            //         Navigator.of(context).push(
                                            //             MaterialPageRoute(
                                            //                 builder: (context) =>
                                            //                     DetailChildPage(
                                            //                       title: 'Lokasi',
                                            //                       name:
                                            //                           '${childData.name}',
                                            //                       email:
                                            //                           '${childData.email}',
                                            //                       toLocation:
                                            //                           true,
                                            //                     )));
                                            //       },
                                            //       icon: Icon(
                                            //         Icons.location_on_outlined,
                                            //         color: cOrtuBlue,
                                            //       ),
                                            //     ),
                                            //     IconButton(
                                            //       iconSize: 35,
                                            //       onPressed: () {
                                            //         parentController
                                            //             .setBottomNavIndex(1);
                                            //       },
                                            //       icon: Icon(
                                            //         Icons.notifications,
                                            //         color: cOrtuBlue,
                                            //       ),
                                            //     ),
                                            //     IconButton(
                                            //       iconSize: 35,
                                            //       onPressed: () {
                                            //         Navigator.of(context).push(
                                            //             MaterialPageRoute(
                                            //                 builder: (context) =>
                                            //                     DetailChildPage(
                                            //                       title:
                                            //                           'Kontrol dan Konfigurasi',
                                            //                       name:
                                            //                           '${childData.name}',
                                            //                       email:
                                            //                           '${childData.email}',
                                            //                     )));
                                            //       },
                                            //       icon: Icon(
                                            //         Icons.settings,
                                            //         color: cOrtuBlue,
                                            //       ),
                                            //     ),
                                            //   ],
                                            // ),
                                            )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
            childData.status == 'invitation'
                ? Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                        margin: EdgeInsets.only(
                            left: 15, right: 15, top: 5, bottom: 20),
                        child: FlatButton(
                          height: 35,
                          minWidth: 250,
                          shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(10.0),
                          ),
                          onPressed: () async {
                            await Future(() {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => InviteChildQR(allData: [
                                        prefs.getString(rkEmailUser) != null
                                            ? prefs.getString(rkEmailUser)!
                                            : '',
                                        childData.email != null
                                            ? childData.email!
                                            : '',
                                        childData.phone != null
                                            ? childData.phone!
                                            : '',
                                        childData.name != null
                                            ? childData.name!
                                            : '',
                                        childData.age != null
                                            ? childData.age!
                                            : 10,
                                        childData.status != null
                                            ? childData.status!
                                            : '',
                                        childData.childOfNumber != null
                                            ? childData.childOfNumber!
                                            : 1,
                                        childData.childNumber != null
                                            ? childData.childNumber!
                                            : 1,
                                        childData.imgPhoto != null
                                            ? childData.imgPhoto!
                                            : '',
                                        childData.birdDate != null
                                            ? childData.birdDate!
                                                .toIso8601String()
                                            : '',
                                        childData.address != null
                                            ? childData.address!
                                            : '',
                                        'child',
                                        ''
                                      ], prefs: prefs, userType: 'child')));
                            });
                          },
                          color: cOrtuWhite,
                          child: Text(
                            "MENUNGGU AKTIVASI",
                            style: TextStyle(
                              fontFamily: 'Raleway',
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        )))
                : SizedBox.shrink()
          ],
        ),
      ),
      childData.status == 'invitation'
          ? SizedBox.shrink()
          : Container(
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10))),
              height: 50,
              width: screenSize.width - paddingValue * 2,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    FlatButton(
                        height: 50,
                        minWidth: screenSize.width / 3 - paddingValue,
                        textColor: Colors.black,
                        // shape: RoundedRectangleBorder(
                        //     side: BorderSide(color: Colors.black),
                        //     borderRadius: BorderRadius.only(
                        //         bottomLeft: Radius.circular(10))),
                        child: Row(children: [
                          Icon(Icons.location_on_outlined, size: 30),
                          Text('Lokasi')
                        ]),
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => DetailChildPage(
                                    title: 'Lokasi',
                                    name: '${childData.name}',
                                    email: '${childData.email}',
                                    toLocation: true,
                                    subscription: childData.subscription,
                                  )));
                        }),
                    FlatButton(
                        height: 50,
                        minWidth: screenSize.width / 3 - paddingValue,
                        textColor: Colors.black,
                        // shape: RoundedRectangleBorder(
                        //     side: BorderSide(color: Colors.black),
                        //     borderRadius: BorderRadius.only(
                        //         bottomRight: Radius.circular(10))),
                        child: Row(children: [
                          Icon(Icons.settings_outlined, size: 30),
                          Text('Pengaturan')
                        ]),
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => DetailChildPage(
                                    title: 'Kontrol dan Konfigurasi',
                                    name: '${childData.name}',
                                    email: '${childData.email}',
                                    subscription: childData.subscription,
                                  )));
                        }),
                  ]))
    ]);
  }

  Widget contentTime(
    String title,
    String timeValue,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          Text(
            '$timeValue',
            style: TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // void showSelectUserType(context) async {
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return SimpleDialog(
  //         children: [
  //           Padding(
  //             padding: EdgeInsets.only(left: 10.0, right: 10.0),
  //             child: Row(
  //               children: [
  //                 Expanded(
  //                   child: Text(
  //                     "Pilih Jenis Akun",
  //                     style: TextStyle(fontSize: 20.0),
  //                   ),
  //                 ),
  //                 IconButton(
  //                   icon: Icon(Icons.close),
  //                   onPressed: () {
  //                     Navigator.pop(context);
  //                   },
  //                 )
  //               ],
  //             ),
  //           ),
  //           Divider(),
  //           Padding(
  //             padding: EdgeInsets.all(10.0),
  //             child: InkWell(
  //               onTap: () async {
  //                 Navigator.of(context, rootNavigator: true).pop();
  //                 final res = await Navigator.push(
  //                   context,
  //                   MaterialPageRoute<Object>(
  //                       builder: (BuildContext context) => SetupInviteChildPage(
  //                           address: parentController.parentProfile.address!,
  //                           userTypeStr: "child")),
  //                 );
  //                 print('Add Child Response: $res');
  //                 if (res.toString().toLowerCase() == 'addchild') onAddChild();
  //               },
  //               child: Image.asset('assets/images/invitation_anak.png'),
  //             ),
  //           ),
  //           Padding(
  //             padding: EdgeInsets.all(10.0),
  //             child: InkWell(
  //               onTap: () async {
  //                 Navigator.of(context, rootNavigator: true).pop();
  //                 final res = await Navigator.push(
  //                   context,
  //                   MaterialPageRoute<Object>(
  //                       builder: (BuildContext context) => SetupInviteChildPage(
  //                           address: parentController.parentProfile.address!,
  //                           userTypeStr: "parent")),
  //                 );
  //                 print('Add Child Response: $res');
  //                 if (res.toString().toLowerCase() == 'addchild') onAddChild();
  //               },
  //               child: Image.asset('assets/images/invitation_parent.png'),
  //             ),
  //           )
  //         ],
  //       );
  //     },
  //   );
  // }
}
