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
import 'package:ruangkeluarga/utils/rk_webview.dart';

class ProgramChildTestDetail extends StatefulWidget {
  @override
  _ProgramChildTestDetail createState() => _ProgramChildTestDetail();
  final String emailUser;
  final List<ContentResponseModel> listResponse;
  final List<ContentModel> listStep;

  ProgramChildTestDetail(
      {Key? key,
      required this.emailUser,
      required this.listResponse,
      required this.listStep})
      : super(key: key);
}

class _ProgramChildTestDetail extends State<ProgramChildTestDetail> {
  int totalComment = 0;
  final api = MediaRepository();
  var outputFormat = DateFormat('dd LLL yyyy, HH:mm');

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cPrimaryBg,
      appBar: AppBar(
        backgroundColor: cTopBg,
        title: Text('Detail Jawaban', style: TextStyle(color: cOrtuWhite)),
        elevation: 0,
      ),
      body: Column(mainAxisSize: MainAxisSize.max, children: [
        Expanded(
            child: Container(
                // color: ,
                padding: EdgeInsets.all(5),
                child: SingleChildScrollView(
                    child: ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: widget.listStep.length,
                  itemBuilder: (ctx, idx) {
                    final contentData = widget.listStep[idx];
                    String respon = "-";
                    for (int i = 0; i < widget.listResponse.length; i++) {
                      if (contentData.id == widget.listResponse[i].contentId) {
                        respon = widget.listResponse[i].respon;
                      }
                    }
                    return responseContainer(
                        nomor: idx,
                        emailUser: widget.emailUser,
                        name: contentData.contentName,
                        respon: respon,
                        answerKey: contentData.answerKey,
                        context: context,
                        contentData: contentData);
                  },
                )))),
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

  Widget responseContainer(
      {required int nomor,
      required String emailUser,
      required String name,
      required String respon,
      required String answerKey,
      required BuildContext context,
      required ContentModel contentData}) {
    String namaKonten = '${nomor + 1}. ' + contentData.contentName;
    return Container(
      margin: EdgeInsets.all(5),
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: cOrtuGrey,
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: InkWell(
        onTap: () {
          showContent(context, emailUser, contentData.id, contentData.contents,
              contentData.contentName, '', '', '', contentData.response,
              userType: 'parent');
        },
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
                            '$namaKonten',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Jawaban yang Dipilih: $respon',
                            // style: TextStyle(fontSize: 20),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Kunci Jawaban: $answerKey',
                            // style: TextStyle(fontSize: 20),
                          ),
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
