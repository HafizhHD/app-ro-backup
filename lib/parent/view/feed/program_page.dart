import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ruangkeluarga/global/global.dart';
import 'package:ruangkeluarga/parent/view/feed/feed_controller.dart';
import 'package:ruangkeluarga/parent/view/main/parent_controller.dart';
import 'package:ruangkeluarga/utils/rk_webview.dart';
import 'package:ruangkeluarga/parent/view/inbox/inbox_page_detail.dart';

import 'feed_pdf.dart';

class ProgramxPage extends StatelessWidget {
  ProgramxPage(this.programId, this.emailUser);
  final String programId;
  final String emailUser;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: cPrimaryBg,
        appBar: AppBar(
          backgroundColor: cTopBg,
          title: Text('Isi Program', style: TextStyle(color: cOrtuWhite)),
          elevation: 0,
        ),
        body: GetBuilder<FeedController>(
          builder: (controller) => RefreshIndicator(
            onRefresh: () => controller.getProgramContents(),
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
    return Container(
      child: ListView.builder(
        physics: AlwaysScrollableScrollPhysics(),
        itemCount: inbox.length,
        itemBuilder: (ctx, idx) {
          final contentData = inbox[idx];
          String Nomor = contentData.nomerUrutTahapan.toString() + ' ';
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
                  if (contentData.contentType == ContentType.artikel) {
                    String imgData = '';
                    if (contentData.contentThumbnail != null) imgData = contentData.contentThumbnail!;
                    showContent(context, emailUser, contentData.id, contentData.contents,
                        contentData.contentName, imgData, '', contentData.contentSource);
                  } else if (contentData.contentType == ContentType.video) {
                    showContent(
                        context,
                        emailUser,
                        contentData.id,
                        contentData.contents,
                        contentData.contentName,
                        '',
                        contentData.contentDescription,
                        contentData.contentSource);
                  } else if (contentData.contentType == ContentType.pdf) {
                    Navigator.push(
                        context,
                        leftTransitionRoute(
                            FeedPdf(contentModel: contentData, emailUser: emailUser)));
                  } else {
                    showContent(context, emailUser, contentData.id, contentData.contents,
                        contentData.contentName, '', '', contentData.contentSource);
                  }
                },
                title: Text(
                  strContent,
                  style: TextStyle(
                      fontWeight: contentData.status
                          ? FontWeight.normal
                          : FontWeight.bold),
                ),
                subtitle: Text('\n${dateFormat_EDMYHM(contentData.dateCreated)}'),
              ),
            ),
          );
        },
      ),
    );
  }
}
