import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ruangkeluarga/global/global.dart';
import 'package:ruangkeluarga/model/cobrand_program_content_model.dart';
import 'package:ruangkeluarga/model/rk_child_model.dart';
import 'package:ruangkeluarga/parent/view/main/parent_controller.dart';
import 'package:ruangkeluarga/parent/view/main/parent_model.dart';
import 'package:ruangkeluarga/parent/view_model/sekolah_al_azhar_model.dart';
import 'package:ruangkeluarga/utils/base_service/service_controller.dart';
import 'package:ruangkeluarga/utils/repository/media_repository.dart';
import 'package:ruangkeluarga/parent/view/order/order.dart';

class ProgramChildResponse extends StatefulWidget {
  @override
  _ProgramChildResponse createState() => _ProgramChildResponse();
  final String contentId;

  ProgramChildResponse({Key? key, required this.contentId}) : super(key: key);
}

class _ProgramChildResponse extends State<ProgramChildResponse> {
  int totalComment = 0;
  late List<ContentResponseModel> listResponse;
  Future<bool>? fGetListResponse;
  final api = MediaRepository();
  ParentProfile parentData = Get.find<ParentController>().parentProfile;
  late List<Child> children;
  final TextEditingController tec = TextEditingController();
  final FocusNode focusNode = FocusNode();
  var outputFormat = DateFormat('dd LLL yyyy, HH:mm');

  @override
  void initState() {
    super.initState();
    initAsync();
  }

  void initAsync() {
    children = parentData.children ?? [];
    List<String> childrenEmail = [];
    children.forEach((x) {
      if (x.email != null) childrenEmail.add(x.email!);
    });
    fGetListResponse = getContentResponse(childrenEmail);
    setState(() {});
  }

  Future<bool> getContentResponse(List<String>? emailUser) async {
    List<String> emailList = [];
    if (emailUser != null) emailList = emailUser;
    final res2 = await api.fetchContentResponse(widget.contentId, emailList);
    if (res2.statusCode == 200) {
      // print('Print res fetchCoBrand: ${res2.body}');
      final json = jsonDecode(res2.body);
      if (json['resultCode'] == "OK") {
        List contentResponse = json['resultData'];
        listResponse = contentResponse
            .map((e) => ContentResponseModel.fromJson(e))
            .toList();
        return true;
      }
    }
    print('Error fetchContentResponse: $res2');
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(mainAxisSize: MainAxisSize.max, children: [
        Expanded(
            child: Container(
                // color: ,
                padding: EdgeInsets.all(5),
                child: FutureBuilder(
                    future: fGetListResponse,
                    builder: (context, AsyncSnapshot<bool> snapshot) {
                      if (!snapshot.hasData) return wProgressIndicator();
                      return SingleChildScrollView(
                          child: ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: children.length,
                        itemBuilder: (ctx, idx) {
                          final childData = children[idx];
                          String respon = "-";
                          for (int i = 0; i < listResponse.length; i++) {
                            if (listResponse[i].emailUser == childData.email) {
                              respon = listResponse[i].respon;
                              break;
                            }
                          }
                          print('Nama: ${childData.name}');
                          print('Respon: $respon');
                          return responseContainer(
                              name: childData.name ?? 'Nama Anak',
                              respon: respon);
                        },
                      ));
                    }))),
        // Align(
        //     alignment: Alignment.bottomLeft,
        //     child: Column(
        //     crossAxisAlignment: CrossAxisAlignment.stretch,
        //     children: [
        //       Text(''),
        //       InkWell(
        //         child: Text("  Kebijakan Privasi",
        //           style: TextStyle(
        //             color: Colors.blue
        //           ),
        //         ),
        //         onTap: () {showPrivacyPolicy();},
        //       ),
        //       Text(''),
        //       Text('  Versi ${appInfo.version}'),
        //     ]),
        // )
      ]),
    );
  }

  Widget responseContainer({required String name, required String respon}) {
    return Container(
      margin: EdgeInsets.all(5),
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: cOrtuGrey,
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: InkWell(
        child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                  child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: Container(
                      margin: EdgeInsets.all(5),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$name',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Respon: $respon',
                            // style: TextStyle(fontSize: 20),
                          ),
                          SizedBox(height: 5),
                        ],
                      ),
                    ),
                  ),
                ],
              )),
            ]),
      ),
    );
  }
}
