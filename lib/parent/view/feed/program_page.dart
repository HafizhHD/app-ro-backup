import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ruangkeluarga/global/global.dart';
import 'package:ruangkeluarga/model/cobrand_program_content_model.dart';
import 'package:ruangkeluarga/model/rk_child_model.dart';
import 'package:ruangkeluarga/parent/view/feed/feed_controller.dart';
import 'package:ruangkeluarga/parent/view/feed/program_child_response.dart';
import 'package:ruangkeluarga/parent/view/feed/program_child_test_detail.dart';
import 'package:ruangkeluarga/parent/view/main/parent_controller.dart';
import 'package:ruangkeluarga/parent/view/main/parent_model.dart';
import 'package:ruangkeluarga/utils/repository/media_repository.dart';
import 'package:ruangkeluarga/utils/rk_webview.dart';
import 'package:ruangkeluarga/parent/view/inbox/inbox_page_detail.dart';

import 'feed_pdf.dart';

class ProgramxPage extends StatefulWidget {
  @override
  _ProgramxPage createState() => _ProgramxPage();

  final String programId;
  final String emailUser;
  final String userType;
  final String programName;
  final List<String> category;

  ProgramxPage(
      {Key? key,
      required this.programId,
      required this.emailUser,
      required this.userType,
      required this.programName,
      required this.category})
      : super(key: key);
}

class _ProgramxPage extends State<ProgramxPage> {
  late List<ContentResponseModel> listResponse;
  Future<bool>? fGetListResponse;
  final api = MediaRepository();
  late ParentProfile parentData;
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
    if (widget.userType == 'parent') {
      parentData = Get.find<ParentController>().parentProfile;
      children = parentData.children ?? [];
      List<String> childrenEmail = [];
      children.forEach((x) {
        if (x.email != null) childrenEmail.add(x.email!);
      });
      fGetListResponse = getContentResponse(childrenEmail);
    }
    setState(() {});
  }

  Future<bool> getContentResponse(List<String>? emailUser) async {
    List<String> emailList = [];
    if (emailUser != null) emailList = emailUser;
    final res2 =
        await api.fetchContentResponseWithProgram(widget.programId, emailList);
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
    return SafeArea(
      child: Scaffold(
        backgroundColor: cPrimaryBg,
        appBar: AppBar(
          backgroundColor: cTopBg,
          title: Text(widget.programName, style: TextStyle(color: cOrtuWhite)),
          elevation: 0,
        ),
        body: GetBuilder<FeedController>(
          builder: (controller) => RefreshIndicator(
            onRefresh: () =>
                controller.getProgramContents(programId: widget.programId),
            child: controller.listProgramContent.length > 0
                ? _body(context, controller)
                : CustomScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    slivers: [
                        SliverFillRemaining(
                          child: Center(
                              child: Text('Isi Program Kosong',
                                  style: TextStyle(color: cOrtuText))),
                        )
                      ]),
          ),
        ),
      ),
    );
  }

  Widget _body(BuildContext context, FeedController controller) {
    final inbox = controller.listProgramContent;
    contentContainer(ScrollPhysics scrollphysics) {
      return Container(
        child: ListView.builder(
          physics: scrollphysics,
          shrinkWrap: true,
          itemCount: inbox.length,
          itemBuilder: (ctx, idx) {
            final contentData = inbox[idx];
            String Nomor = contentData.nomerUrutTahapan.toString() + '. ';
            String strContent = Nomor + contentData.contentName;
            return Dismissible(
              key: Key(contentData.id),
              // direction: if == '' ? DismissDirection.horizontal : DismissDirection.none,
              confirmDismiss: (_) async {
                // return await controller.deleteData(contentData.id);
              },
              child: Container(
                decoration: BoxDecoration(
                    color: cOrtuGrey,
                    borderRadius: BorderRadius.all(Radius.circular(15))),
                margin: EdgeInsets.all(5),
                padding: EdgeInsets.only(top: 5, bottom: 2),
                child: ListTile(
                  onTap: () async {
                    if (widget.userType == 'parent') {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => ProgramChildResponse(
                              emailUser: widget.emailUser,
                              contentData: contentData,
                              contentId: contentData.id,
                              contentName: contentData.contentName)));
                    } else {
                      if (contentData.contentType == ContentType.artikel) {
                        String imgData = '';
                        if (contentData.contentThumbnail != null)
                          imgData = contentData.contentThumbnail!;
                        showContent(
                            context,
                            widget.emailUser,
                            contentData.id,
                            contentData.contents,
                            contentData.contentName,
                            imgData,
                            '',
                            contentData.contentSource,
                            contentData.response);
                      } else if (contentData.contentType == ContentType.video) {
                        showContent(
                            context,
                            widget.emailUser,
                            contentData.id,
                            contentData.contents,
                            contentData.contentName,
                            '',
                            contentData.contentDescription,
                            contentData.contentSource,
                            contentData.response);
                      } else if (contentData.contentType == ContentType.pdf) {
                        Navigator.push(
                            context,
                            leftTransitionRoute(FeedPdf(
                                contentModel: contentData,
                                emailUser: widget.emailUser)));
                      } else {
                        showContent(
                            context,
                            widget.emailUser,
                            contentData.id,
                            contentData.contents,
                            contentData.contentName,
                            '',
                            '',
                            contentData.contentSource,
                            contentData.response);
                      }
                    }
                  },
                  title: Text(
                    strContent,
                    style: TextStyle(
                        fontWeight: contentData.status
                            ? FontWeight.normal
                            : FontWeight.bold),
                  ),
                  subtitle:
                      Text('\n${dateFormat_EDMYHM(contentData.dateCreated)}'),
                ),
              ),
            );
          },
        ),
      );
    }

    if (widget.userType == 'parent' &&
        (widget.category.contains("ujian") ||
            widget.category.contains("Ujian")))
      return SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(children: [
            Text('Hasil Ujian Anak Anda', style: TextStyle(fontSize: 30)),
            Container(
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
                          List<ContentResponseModel> l = [];
                          int skor = 0;
                          int totalSkor = 0;
                          for (int i = 0; i < listResponse.length; i++) {
                            if (listResponse[i].emailUser == childData.email) {
                              skor += listResponse[i].point;
                              totalSkor++;
                              l.add(listResponse[i]);
                            }
                          }
                          print('Jumlah yang dijawab: ${l.length}');
                          int totalSoal = inbox.length;
                          int finalSkor = 0;
                          if (totalSkor != 0) {
                            finalSkor = (skor / totalSoal * 100).toInt();
                          }
                          print('Nama: ${childData.name}');
                          print('Nilai: $finalSkor');
                          return responseContainer(
                              email: widget.emailUser,
                              name: childData.name ?? 'Nama Anak',
                              correct: skor,
                              incorrect: totalSkor - skor,
                              unanswered: totalSoal - totalSkor,
                              score: finalSkor,
                              listJawaban: l,
                              listStep: inbox,
                              context: context);
                        },
                      ));
                    })),
          ]));
    else
      return contentContainer(AlwaysScrollableScrollPhysics());
  }

  Widget responseContainer(
      {required String email,
      required String name,
      required int correct,
      required int incorrect,
      required int unanswered,
      required int score,
      required List<ContentResponseModel> listJawaban,
      required List<ContentModel> listStep,
      required BuildContext context}) {
    return Container(
      margin: EdgeInsets.all(5),
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: cOrtuGrey,
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => ProgramChildTestDetail(
                  emailUser: email,
                  listResponse: listJawaban,
                  listStep: listStep)));
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
                        margin: EdgeInsets.all(10),
                        child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$name',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    'Nilai: $score',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Jawaban Benar: $correct',
                                  ),
                                  Text(
                                    'Jawaban Salah: $incorrect',
                                  ),
                                  Text(
                                    'Belum Dijawab: $unanswered',
                                  )
                                ],
                              ),
                            ])),
                  ),
                ],
              )),
            ]),
      ),
    );
  }
}
