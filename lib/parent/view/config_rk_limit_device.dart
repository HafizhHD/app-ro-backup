import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

import 'package:intl/intl.dart';
import 'package:ruangkeluarga/global/global.dart';
import 'package:ruangkeluarga/model/rk_schedule_model.dart';
import 'package:ruangkeluarga/utils/repository/media_repository.dart';
import 'package:http/http.dart';

class RKConfigLimitDevicePage extends StatefulWidget {
  // List<charts.Series> seriesList;
  @override
  _RKConfigLimitDevicePageState createState() =>
      _RKConfigLimitDevicePageState();
  final String title;
  final String name;
  final String email;

  RKConfigLimitDevicePage(
      {Key? key, required this.title, required this.name, required this.email})
      : super(key: key);
}

class _RKConfigLimitDevicePageState extends State<RKConfigLimitDevicePage> {
  TextEditingController cTitle = TextEditingController();
  TextEditingController cDesc = TextEditingController();
  String sStartDateTime = '00:00';
  String sEndDateTime = '00:00';

  Map<String, bool> selectedDay = {
    weekdayToDayName(0): false,
    weekdayToDayName(1): false,
    weekdayToDayName(2): false,
    weekdayToDayName(3): false,
    weekdayToDayName(4): false,
    weekdayToDayName(5): false,
    weekdayToDayName(6): false,
  };

  int selectedScheduleType = 0;

  late Future<List<DeviceUsageSchedules>> fListSchedule;
  List<DeviceUsageSchedules> listSchedule = [];
  List<DeviceUsageSchedules> searchlistSchedule = [];

  Future<List<DeviceUsageSchedules>> fetchListSchedule() async {
    Response response = await MediaRepository().fetchUserSchedule(widget.email);
    // print('isi response fetch deviceUsageSchedules : ${response.body}');
    if (response.statusCode == 200) {
      print('isi response fetch deviceUsageSchedules 200');
      var json = jsonDecode(response.body);
      final List data = json['deviceUsageSchedules'];
      final res = data.map((e) => DeviceUsageSchedules.fromJson(e)).toList();
      setState(() {
        listSchedule = res;
        searchlistSchedule = res;
      });
      return res;
    } else {
      print('isi failed fetch deviceUsageSchedules : ${response.statusCode}');
      return [];
    }
  }

  Future<Response> onSaveSchedule(String status) async {
    final type = selectedScheduleType == 0
        ? ScheduleType.harian
        : ScheduleType.terjadwal;
    List<String> listSelectedDays = [];
    if (type == ScheduleType.harian) {
      selectedDay.forEach((key, value) {
        if (value) listSelectedDays.add(key);
      });
    }
    final data = DeviceUsageSchedules(
      emailUser: widget.email,
      scheduleName: cTitle.text,
      scheduleType: type,
      scheduleDescription: cDesc.text,
      deviceUsageStartTime: sStartDateTime,
      deviceUsageEndTime: sEndDateTime,
      deviceUsageDays: listSelectedDays,
      status: status,
    );

    Response response = await MediaRepository().saveSchedule(data);
    return response;
  }

  Future<Response> onUpdateSchedule(String status, String id) async {
    final type = selectedScheduleType == 0
        ? ScheduleType.harian
        : ScheduleType.terjadwal;
    List<String> listSelectedDays = [];
    if (type == ScheduleType.harian) {
      selectedDay.forEach((key, value) {
        if (value) listSelectedDays.add(key);
      });
    }
    final data = DeviceUsageSchedules(
      id: id,
      emailUser: widget.email,
      scheduleName: cTitle.text,
      scheduleType: type,
      scheduleDescription: cDesc.text,
      deviceUsageStartTime: sStartDateTime,
      deviceUsageEndTime: sEndDateTime,
      deviceUsageDays: listSelectedDays,
      status: status,
    );

    Response response = await MediaRepository().scheduleUpdate(data);
    return response;
  }

  @override
  void initState() {
    super.initState();
    fListSchedule = fetchListSchedule();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cPrimaryBg,
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.title, style: TextStyle(color: cOrtuWhite)),
        backgroundColor: cTopBg,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: cOrtuWhite),
          onPressed: () => Navigator.of(context).pop(),
        ),
        elevation: 0,
      ),
      body: Container(
        padding: EdgeInsets.only(left: 15, right: 10, top: 5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            WSearchBar(
              fOnChanged: (v) {
                searchlistSchedule = listSchedule
                    .where((e) =>
                        e.scheduleName!.toLowerCase().contains(v.toLowerCase()))
                    .toList();
              },
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
              child: FutureBuilder(
                  future: fListSchedule,
                  builder: (context,
                      AsyncSnapshot<List<DeviceUsageSchedules>> snapshot) {
                    if (!snapshot.hasData) return wProgressIndicator();

                    final listSchedule = snapshot.data ?? [];
                    if (listSchedule.length <= 0)
                      return Center(
                          child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Image.asset(
                                        'assets/images/icon/undraw_select_re_3kbd.png',
                                        height:
                                            MediaQuery.of(context).size.height /
                                                4,
                                        fit: BoxFit.fill),
                                    SizedBox(height: 5),
                                    Text(
                                        'Mulai membuat jadwal penggunaan pada perangkat anak anda di waktu-waktu tertentu seperti jam belajar dan lainnya, supaya anak lebih disiplin dalam bermain gadget',
                                        style: TextStyle(fontSize: 16),
                                        textAlign: TextAlign.center),
                                    SizedBox(height: 3),
                                    FlatButton(
                                        color: cAsiaBlue,
                                        child: Text(
                                            'Mulai Buat Jadwal Penggunaan',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: cOrtuWhite)),
                                        onPressed: () {
                                          addEditScheduleDialog(null);
                                        })
                                  ])));

                    return ListView.builder(
                        itemCount: searchlistSchedule.length,
                        itemBuilder: (ctx, index) {
                          final schedule = searchlistSchedule[index];
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(
                                margin: EdgeInsets.all(5),
                                padding: EdgeInsets.all(5).copyWith(left: 10),
                                decoration: BoxDecoration(
                                    color: Colors.grey.shade700,
                                    borderRadius: BorderRadius.circular(10)),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      child: Container(
                                        margin: EdgeInsets.all(5),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            RichText(
                                              text: TextSpan(
                                                text: schedule.scheduleName,
                                                style: TextStyle(
                                                    color: cOrtuWhite),
                                                children: <TextSpan>[
                                                  TextSpan(
                                                    text:
                                                        '   ${schedule.scheduleType.toEnumString()}',
                                                    style: TextStyle(
                                                      color: Colors.white30,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(height: 5),
                                            if (schedule.scheduleDescription !=
                                                    null &&
                                                schedule.scheduleDescription !=
                                                    '')
                                              Flexible(
                                                child: Padding(
                                                  padding: EdgeInsets.only(
                                                      bottom: 5),
                                                  child: Text(
                                                    '${schedule.scheduleDescription}',
                                                    style: TextStyle(
                                                        color: cOrtuWhite),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 2,
                                                  ),
                                                ),
                                              ),
                                            Flexible(
                                              child: Text(
                                                '${schedule.deviceUsageStartTime} - ${schedule.deviceUsageEndTime}',
                                                style: TextStyle(
                                                    color: cOrtuWhite),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 2,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                            onPressed: () async {
                                              showLoadingOverlay();
                                              final status = schedule.status
                                                      ?.toLowerCase() ==
                                                  'aktif';
                                              final response =
                                                  await MediaRepository()
                                                      .scheduleUpdateStatus(
                                                          status ? '' : 'Aktif',
                                                          schedule.id!);
                                              if (response.statusCode == 200) {
                                                await fetchListSchedule();
                                                closeOverlay();
                                                showToastSuccess(
                                                    ctx: context,
                                                    successText:
                                                        'Berhasil Ubah Status Jadwal Penggunaan!');
                                              } else {
                                                closeOverlay();
                                                showToastFailed(
                                                    ctx: context,
                                                    failedText:
                                                        'Gagal Ubah Status Jadwal Penggunaan!');
                                              }
                                            },
                                            icon: Icon(
                                              Icons.radio_button_checked,
                                              color: schedule.status
                                                          ?.toLowerCase() ==
                                                      'aktif'
                                                  ? cAsiaBlue
                                                  : cOrtuWhite,
                                            )),
                                        IconButton(
                                            onPressed: () {
                                              addEditScheduleDialog(schedule);
                                            },
                                            icon: Icon(
                                              Icons.edit,
                                              color: cOrtuWhite,
                                            )),
                                        IconButton(
                                            onPressed: () async {
                                              showLoadingOverlay();
                                              final response =
                                                  await MediaRepository()
                                                      .scheduleRemove(
                                                          schedule.id!);
                                              if (response.statusCode == 200) {
                                                showToastSuccess(
                                                    ctx: context,
                                                    successText:
                                                        'Berhasil Menghapus Jadwal Penggunaan!');
                                                fListSchedule =
                                                    fetchListSchedule();
                                                await fetchListSchedule();
                                                closeOverlay();
                                              } else {
                                                closeOverlay();
                                                showToastFailed(
                                                    ctx: context,
                                                    failedText:
                                                        'Gagal Menghapus Jadwal Penggunaan!');
                                              }
                                            },
                                            icon: Icon(
                                              Icons.close,
                                              color: cOrtuWhite,
                                            )),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              if (index == searchlistSchedule.length - 1)
                                Container(
                                  margin: EdgeInsets.all(5),
                                  padding: EdgeInsets.all(5).copyWith(left: 10),
                                  child: ListTile(),
                                )
                            ],
                          );
                        });
                  }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: cAsiaBlue,
        child: Icon(Icons.add, color: cPrimaryBg),
        onPressed: () {
          addEditScheduleDialog(null);
        },
      ),
    );
  }

  void resetInputValue() {
    cTitle.text = '';
    cDesc.text = '';
    sStartDateTime = '00:00';
    sEndDateTime = '00:00';
    selectedDay = {
      weekdayToDayName(0): false,
      weekdayToDayName(1): false,
      weekdayToDayName(2): false,
      weekdayToDayName(3): false,
      weekdayToDayName(4): false,
      weekdayToDayName(5): false,
      weekdayToDayName(6): false,
    };
    setState(() {});
  }

  void setInputValue(DeviceUsageSchedules data) {
    cTitle.text = data.scheduleName!;
    cDesc.text = data.scheduleDescription!;
    sStartDateTime = data.deviceUsageStartTime!;
    sEndDateTime = data.deviceUsageEndTime!;
    selectedScheduleType = data.scheduleType == ScheduleType.harian ? 0 : 1;
    selectedDay = {
      weekdayToDayName(0): false,
      weekdayToDayName(1): false,
      weekdayToDayName(2): false,
      weekdayToDayName(3): false,
      weekdayToDayName(4): false,
      weekdayToDayName(5): false,
      weekdayToDayName(6): false,
    };
    print(data.deviceUsageDays);
    data.deviceUsageDays?.forEach((element) => selectedDay[element] = true);

    setState(() {});
  }

  void addEditScheduleDialog(DeviceUsageSchedules? data) {
    final bool hasData = data != null;
    if (hasData)
      setInputValue(data);
    else
      resetInputValue();
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Material(
            child: Theme(
              data: ThemeData.light(),
              child: Container(
                  color: cPrimaryBg,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: StatefulBuilder(builder: (context, sbSetState) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AppBar(
                                backgroundColor: Colors.transparent,
                                title: Text(
                                    '${hasData ? 'Ubah' : 'Tambah'} Jadwal Penggunaan',
                                    style: TextStyle(color: cOrtuText)),
                                leading: IconButton(
                                  icon: Icon(Icons.arrow_back_ios,
                                      color: cOrtuText),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                                elevation: 0,
                              ),
                              Container(
                                padding: EdgeInsets.all(10),
                                child: TextField(
                                  style: TextStyle(
                                      fontSize: 16.0, color: Colors.black),
                                  keyboardType: TextInputType.text,
                                  minLines: 1,
                                  maxLines: 1,
                                  controller: cTitle,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: cOrtuLightGrey,
                                    hintText: 'Judul Jadwal, cth: Jam Belajar',
                                    contentPadding: const EdgeInsets.only(
                                        left: 14.0, bottom: 8.0, top: 8.0),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.transparent),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.transparent),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.all(10),
                                child: TextField(
                                  style: TextStyle(
                                      fontSize: 16.0, color: Colors.black),
                                  keyboardType: TextInputType.multiline,
                                  minLines: 3,
                                  maxLines: 6,
                                  controller: cDesc,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: cOrtuLightGrey,
                                    hintText: 'Deskripsi Jadwal',
                                    contentPadding: const EdgeInsets.only(
                                        left: 14.0, bottom: 8.0, top: 8.0),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.transparent),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.transparent),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.only(
                                    left: 10, right: 10, top: 20),
                                width: MediaQuery.of(context).size.width,
                                child: ToggleBar(
                                  textColor: cOrtuLightGrey,
                                  selectedTextColor: cAsiaBlue,
                                  initialValue: selectedScheduleType,
                                  labels: ['Harian', 'Terjadwal'],
                                  onSelectionUpdated: (index) {
                                    selectedScheduleType = index;

                                    if (index == 0) {
                                      sStartDateTime = '00:00';
                                      sEndDateTime = '00:00';
                                    } else {
                                      sStartDateTime =
                                          dateFormat_EDMYHM(DateTime.now());
                                      sEndDateTime =
                                          dateFormat_EDMYHM(DateTime.now());
                                    }
                                    setState(() {});
                                    sbSetState(() {});
                                  },
                                ),
                              ),
                              Flexible(
                                child: selectedScheduleType == 0
                                    ? harianPicker(sbSetState)
                                    : jadwalPicker(sbSetState),
                              ),
                            ],
                          );
                        }),
                      ),
                      Container(
                        padding: EdgeInsets.all(10),
                        child: FlatButton(
                          height: 50,
                          minWidth: 300,
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(15.0)),
                          onPressed: () async {
                            showLoadingOverlay();
                            if (hasData) {
                              final response =
                                  await onUpdateSchedule('aktif', data.id!);
                              if (response.statusCode == 200) {
                                closeOverlay();
                                closeOverlay();
                                showToastSuccess(
                                    ctx: context,
                                    successText:
                                        'Berhasil Ubah Jadwal Penggunaan!');
                                fListSchedule = fetchListSchedule();
                                await fetchListSchedule();
                              } else {
                                showToastFailed(
                                    ctx: context,
                                    failedText:
                                        'Gagal Ubah Jadwal Penggunaan!');
                              }
                            } else {
                              final response = await onSaveSchedule('aktif');
                              if (response.statusCode == 200) {
                                closeOverlay();
                                closeOverlay();
                                showToastSuccess(
                                    ctx: context,
                                    successText:
                                        'Berhasil Tambah Jadwal Penggunaan!');
                                fListSchedule = fetchListSchedule();
                                await fetchListSchedule();
                              } else {
                                showToastFailed(
                                    ctx: context,
                                    failedText:
                                        'Gagal Tambah Jadwal Penggunaan!');
                              }
                            }
                          },
                          color: cAsiaBlue,
                          child: Text(
                            "SIMPAN",
                            style: TextStyle(
                              color: cOrtuWhite,
                              fontFamily: 'Raleway',
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0,
                            ),
                          ),
                        ),
                      )
                    ],
                  )),
            ),
          );
        });
  }

  Widget harianPicker(StateSetter sbSetState) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Flexible(
                child: ListTile(
                  title: Text(
                    'Jam mulai',
                    style: TextStyle(color: cOrtuText),
                  ),
                  subtitle: Text(sStartDateTime,
                      style: TextStyle(
                          color: cOrtuText,
                          fontSize: 30,
                          fontWeight: FontWeight.bold)),
                  onTap: () async {
                    final res = await timePickerModal();
                    sStartDateTime = res;
                    setState(() {});
                    sbSetState(() {});
                  },
                ),
              ),
              Flexible(
                child: ListTile(
                  title: Text(
                    'Jam selesai',
                    style: TextStyle(color: cOrtuText),
                  ),
                  subtitle: Text(sEndDateTime,
                      style: TextStyle(
                          color: cOrtuText,
                          fontSize: 30,
                          fontWeight: FontWeight.bold)),
                  onTap: () async {
                    final res = await timePickerModal();
                    sEndDateTime = res;
                    setState(() {});
                    sbSetState(() {});
                  },
                ),
              ),
            ],
          ),
          Flexible(
            child: Container(
              padding: EdgeInsets.only(top: 20, bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  dayButton(
                      dayText: 'S',
                      selected: selectedDay[weekdayToDayName(0)]!,
                      onTap: () {
                        setState(() {
                          selectedDay[weekdayToDayName(0)] =
                              !(selectedDay[weekdayToDayName(0)] ?? false);
                        });
                        sbSetState(() {});
                      }),
                  dayButton(
                      dayText: 'M',
                      selected: selectedDay[weekdayToDayName(1)]!,
                      onTap: () {
                        setState(() {
                          selectedDay[weekdayToDayName(1)] =
                              !(selectedDay[weekdayToDayName(1)] ?? false);
                        });
                        sbSetState(() {});
                      }),
                  dayButton(
                      dayText: 'T',
                      selected: selectedDay[weekdayToDayName(2)]!,
                      onTap: () {
                        setState(() {
                          selectedDay[weekdayToDayName(2)] =
                              !(selectedDay[weekdayToDayName(2)] ?? false);
                        });
                        sbSetState(() {});
                      }),
                  dayButton(
                      dayText: 'W',
                      selected: selectedDay[weekdayToDayName(3)]!,
                      onTap: () {
                        setState(() {
                          selectedDay[weekdayToDayName(3)] =
                              !(selectedDay[weekdayToDayName(3)] ?? false);
                        });
                        sbSetState(() {});
                      }),
                  dayButton(
                      dayText: 'T',
                      selected: selectedDay[weekdayToDayName(4)]!,
                      onTap: () {
                        setState(() {
                          selectedDay[weekdayToDayName(4)] =
                              !(selectedDay[weekdayToDayName(4)] ?? false);
                        });
                        sbSetState(() {});
                      }),
                  dayButton(
                      dayText: 'F',
                      selected: selectedDay[weekdayToDayName(5)]!,
                      onTap: () {
                        setState(() {
                          selectedDay[weekdayToDayName(5)] =
                              !(selectedDay[weekdayToDayName(5)] ?? false);
                        });
                        sbSetState(() {});
                      }),
                  dayButton(
                      dayText: 'S',
                      selected: selectedDay[weekdayToDayName(6)]!,
                      onTap: () {
                        setState(() {
                          selectedDay[weekdayToDayName(6)] =
                              !(selectedDay[weekdayToDayName(6)] ?? false);
                        });
                        sbSetState(() {});
                      }),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget dayButton(
      {required bool selected,
      required String dayText,
      required Function() onTap}) {
    return InkWell(
      child: CircleAvatar(
        backgroundColor: selected ? cAsiaBlue : cOrtuText,
        child: Text('$dayText', style: TextStyle(color: cPrimaryBg)),
      ),
      onTap: onTap,
    );
  }

  Widget jadwalPicker(StateSetter sbSetState) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: ListTile(
              title: Container(
                padding: EdgeInsets.only(bottom: 5),
                child: Text(
                  'Tanggal mulai',
                  style: TextStyle(color: cOrtuText),
                ),
              ),
              subtitle: Text(sStartDateTime,
                  style: TextStyle(
                      color: cOrtuText,
                      fontSize: 25,
                      fontWeight: FontWeight.bold)),
              onTap: () async {
                final res = await timePickerModal(
                    mode: CupertinoDatePickerMode.dateAndTime);
                sStartDateTime = res;
                setState(() {});
                sbSetState(() {});
              },
            ),
          ),
          SizedBox(height: 10),
          Flexible(
            child: ListTile(
              title: Container(
                padding: EdgeInsets.only(bottom: 5),
                child: Text(
                  'Tanggal selesai',
                  style: TextStyle(color: cOrtuText),
                ),
              ),
              subtitle: Text(sEndDateTime,
                  style: TextStyle(
                      color: cOrtuText,
                      fontSize: 25,
                      fontWeight: FontWeight.bold)),
              onTap: () async {
                final res = await timePickerModal(
                    mode: CupertinoDatePickerMode.dateAndTime);
                sEndDateTime = res;
                setState(() {});
                sbSetState(() {});
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<String> timePickerModal(
      {CupertinoDatePickerMode mode = CupertinoDatePickerMode.time}) async {
    String newTime = '00:00';
    final res = await showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
              height: MediaQuery.of(context).size.height / 3,
              color: cOrtuGrey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Theme(
                      data: ThemeData.light(),
                      child: CupertinoDatePicker(
                        mode: mode,
                        initialDateTime: DateTime.now(),
                        use24hFormat: true,
                        onDateTimeChanged: (dt) {
                          if (mode == CupertinoDatePickerMode.time) {
                            final h = dt.hour.toString().padLeft(2, '0');
                            final m = dt.minute.toString().padLeft(2, '0');
                            newTime = '$h:$m';
                          } else {
                            newTime = dateFormat_EDMYHM(dt);
                          }
                        },
                      ),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width / 2 - 10,
                    padding: EdgeInsets.all(5),
                    child: roElevatedButton(
                      onPress: () async {
                        Navigator.of(context).pop(newTime);
                      },
                      text: Text('Pilih', style: TextStyle(color: cPrimaryBg)),
                    ),
                  )
                ],
              ));
        });

    return newTime;
  }
}
