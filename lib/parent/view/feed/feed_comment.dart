import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ruangkeluarga/global/global.dart';
import 'package:ruangkeluarga/parent/view/feed/feed_controller.dart';
import 'package:ruangkeluarga/utils/repository/media_repository.dart';
import 'package:ruangkeluarga/utils/rk_webview.dart';
import 'dart:convert';
import 'dart:typed_data';

class FeedComment extends StatefulWidget {
  @override
  _FeedComment createState() => _FeedComment();
  final String emailUser;
  final String contentId;
  final String contentName;

  FeedComment(
      {Key? key,
      required this.emailUser,
      required this.contentId,
      required this.contentName})
      : super(key: key);
}

class ContentCommentModel {
  String id;
  String contentId;
  String emailUser;
  String comment;
  String status;
  DateTime dateCreated;

  ContentCommentModel(
      {required this.id,
      required this.contentId,
      required this.emailUser,
      required this.comment,
      required this.status,
      required this.dateCreated});
  factory ContentCommentModel.fromJson(Map<String, dynamic> json) {
    return ContentCommentModel(
        id: json["_id"],
        contentId: json["contentId"],
        emailUser: json["emailUser"],
        comment: json["comment"],
        status: json["status"],
        dateCreated: DateTime.parse(json["dateCreated"]).toUtc().toLocal());
  }
}

class _FeedComment extends State<FeedComment> {
  int totalComment = 0;
  late List<ContentCommentModel> listComment;
  Future<List<ContentCommentModel>>? fGetListComment;
  String writtenComment = '';
  final api = MediaRepository();
  final TextEditingController tec = TextEditingController();
  final FocusNode focusNode = FocusNode();
  var outputFormat = DateFormat('dd LLL yyyy, HH:mm');

  Future<List<ContentCommentModel>> getComment() async {
    final res = await api.fetchContentComment(widget.contentId);
    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);
      if (json['resultCode'] == "OK") {
        List comments = json['resultData'];
        final result =
            comments.map((e) => ContentCommentModel.fromJson(e)).toList();
        print('result: $result');
        setState(() {
          totalComment = result.length;
          listComment = result;
        });
        return result;
      }
    }
    print('Error fetchContentComment: ${res.statusCode}');
    return [];
  }

  @override
  void initState() {
    super.initState();
    fGetListComment = getComment();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('${widget.contentName}'),
          elevation: 0,
          backgroundColor: cTopBg,
          iconTheme: IconThemeData(color: cOrtuWhite),
        ),
        body: Container(
            color: cPrimaryBg,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                      color: cAsiaBlue,
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Text('$totalComment Komentar',
                          style: TextStyle(color: cOrtuWhite, fontSize: 20),
                          textAlign: TextAlign.center)),
                  Expanded(
                      child: Container(
                          padding: EdgeInsets.all(10),
                          child: FutureBuilder(
                              future: fGetListComment,
                              builder: (context,
                                  AsyncSnapshot<List<ContentCommentModel>>
                                      snapshot) {
                                if (!snapshot.hasData)
                                  return wProgressIndicator();
                                final listComment = snapshot.data ?? [];
                                if (listComment.length == 0)
                                  return Center(
                                      child: Text(
                                          'Belum ada komentar. Tulis komentar Anda tentang konten yang telah Anda lihat.'));
                                return ListView.builder(
                                    itemCount: listComment.length,
                                    itemBuilder: (ctx, idx) {
                                      final comment = listComment[idx];
                                      final String nameInitial = comment
                                          .emailUser
                                          .substring(0, 1)
                                          .toUpperCase();
                                      final String userName =
                                          comment.emailUser.split('@')[0];
                                      return Container(
                                          margin: EdgeInsets.all(12),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                  margin: EdgeInsets.only(
                                                      right: 10),
                                                  padding: EdgeInsets.all(10),
                                                  decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: cOrtuGrey),
                                                  child: Text(nameInitial,
                                                      style: TextStyle(
                                                          color: cOrtuWhite,
                                                          fontSize: 16))),
                                              Expanded(
                                                  child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceAround,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                    Text(userName,
                                                        style: TextStyle(
                                                            color:
                                                                cOrtuDarkGrey)),
                                                    Container(
                                                        padding:
                                                            EdgeInsets.all(10),
                                                        decoration: BoxDecoration(
                                                            color:
                                                                cOrtuLightGrey,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5)),
                                                        child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .stretch,
                                                            children: [
                                                              Text(comment
                                                                  .comment),
                                                              SizedBox(
                                                                  height: 15),
                                                              Align(
                                                                  alignment:
                                                                      Alignment
                                                                          .bottomRight,
                                                                  child: Text(
                                                                      outputFormat.format(
                                                                          comment
                                                                              .dateCreated),
                                                                      style: TextStyle(
                                                                          color:
                                                                              cOrtuDarkGrey,
                                                                          fontSize:
                                                                              10)))
                                                            ]))
                                                  ]))
                                            ],
                                          ));
                                    });
                              }))),
                  Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                          margin: EdgeInsets.all(5),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Expanded(
                                    child: TextField(
                                        focusNode: focusNode,
                                        controller: tec,
                                        decoration: InputDecoration(
                                            hintText: 'Tulis komentar...',
                                            border: OutlineInputBorder()),
                                        minLines: 1,
                                        maxLines: 3,
                                        onChanged: (text) {
                                          writtenComment = text;
                                        })),
                                ElevatedButton(
                                    child: Icon(Icons.send),
                                    style: ElevatedButton.styleFrom(
                                        primary: cAsiaBlue,
                                        shape: CircleBorder(),
                                        padding: EdgeInsets.all(2)),
                                    onPressed: () async {
                                      focusNode.unfocus();
                                      showLoadingOverlay();
                                      final response =
                                          await api.addContentComment(
                                              widget.contentId,
                                              widget.emailUser,
                                              writtenComment);
                                      if (response.statusCode == 200) {
                                        tec.clear();
                                        showToastSuccess(
                                            ctx: context,
                                            successText:
                                                'Komentar berhasil terkirim!');
                                        fGetListComment = getComment();
                                        await getComment();
                                        closeOverlay();
                                      } else {
                                        closeOverlay();
                                        showToastFailed(
                                            ctx: context,
                                            failedText:
                                                'Gagal mengirim komentar. Coba beberapa saat lagi.');
                                      }
                                    })
                              ])))
                ])));
  }
}
