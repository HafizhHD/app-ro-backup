import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ruangkeluarga/global/global.dart';
import 'package:ruangkeluarga/parent/view/feed/feed_controller.dart';
import 'package:ruangkeluarga/parent/view/feed/feed_pdf.dart';
import 'package:ruangkeluarga/parent/view/feed/program_page.dart';
import 'package:ruangkeluarga/utils/rk_webview.dart';
import 'dart:convert';
import 'dart:typed_data';

import '../../../model/cobrand_program_content_model.dart';

const List<Tab> tabs = <Tab>[
  Tab(text: 'Artikel'),
  Tab(text: 'Program'),
];

class FeedPage extends StatelessWidget {
  FeedPage(this.emailUser, this.userType);
  final String emailUser;
  final String userType;
  String jenisArtikel = 'artikel';
  final controller = Get.find<FeedController>();
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return DefaultTabController(
      length: tabs.length,
      // The Builder widget is used to have a different BuildContext to access
      // closest DefaultTabController.
      child: Builder(builder: (BuildContext context) {
        final TabController tabController = DefaultTabController.of(context)!;
        tabController.addListener(() {
          if (!tabController.indexIsChanging) {
            // Your code goes here.
            // To get index of current tab use tabController.index
            controller.jenisArtikel = '';
            if (tabController.index == 0) {
              this.jenisArtikel = 'artikel';
            } else {
              this.jenisArtikel = 'program';
            }
            controller.jenisArtikel = this.jenisArtikel;
            controller.getContents(refresh: true);
          }
        });
        return Scaffold(
          appBar: AppBar(
            bottom: const TabBar(
              tabs: tabs,
            ),
            toolbarHeight: 6,
          ),
          body: TabBarView(
            children: tabs.map((Tab tab) {
              if (tab.text == 'Artikel') {
                return Container(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: EdgeInsets.only(top: 10, bottom: 10),
                        child: WSearchBar(
                            hintText: 'Search by name',
                            fOnSubmitted: (text) {
                              controller.setSearchData(text);
                            },
                            tecController:
                                TextEditingController(text: controller.search)),
                      ),
                      Flexible(
                        flex: 4,
                        child: FutureBuilder<bool>(
                            future: controller.fGetListContent,
                            builder: (context, snapshot) {
                              if (!snapshot.hasData)
                                return wProgressIndicator();
                              return RefreshIndicator(
                                onRefresh: () =>
                                    controller.getContents(refresh: true),
                                child: Container(
                                  padding: EdgeInsets.all(5),
                                  child: GetBuilder<FeedController>(
                                    builder: (builderCtrl) {
                                      if (builderCtrl
                                              .listSearchContent.length ==
                                          0)
                                        return Center(
                                            child: Text('Tidak ada konten',
                                                style: TextStyle(
                                                    color: cOrtuText)));
                                      else
                                        return ListView.separated(
                                          controller:
                                              builderCtrl.scrollController,
                                          shrinkWrap: true,
                                          itemCount: builderCtrl.isThereMore
                                              ? builderCtrl.listSearchContent
                                                      .length +
                                                  1
                                              : builderCtrl
                                                  .listSearchContent.length,
                                          itemBuilder: (context, index) =>
                                              index <
                                                      builderCtrl
                                                          .listSearchContent
                                                          .length
                                                  ? feedContainer(
                                                      builderCtrl
                                                              .listSearchContent[
                                                          index],
                                                      context)
                                                  : builderCtrl.isThereMore
                                                      ? wProgressIndicator()
                                                      : Container(),
                                          separatorBuilder: (ctx, idx) =>
                                              Divider(color: cOrtuGrey),
                                        );
                                    },
                                  ),
                                ),
                              );
                            }),
                      ),
                    ],
                  ),
                );
              }
              // Program
              else {
                return Container(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: EdgeInsets.only(top: 10, bottom: 10),
                        child: WSearchBar(
                            hintText: 'Search by name',
                            fOnSubmitted: (text) {
                              controller.setSearchProgramData(text);
                            },
                            tecController:
                                TextEditingController(text: controller.search)),
                      ),
                      Flexible(
                        flex: 4,
                        child: FutureBuilder<bool>(
                            future: controller.fGetListProgram,
                            builder: (context, snapshot) {
                              if (!snapshot.hasData)
                                return wProgressIndicator();
                              return RefreshIndicator(
                                onRefresh: () =>
                                    controller.getPrograms(refresh: true),
                                child: Container(
                                  padding: EdgeInsets.all(5),
                                  child: GetBuilder<FeedController>(
                                    builder: (builderCtrl) {
                                      if (builderCtrl
                                              .listSearchProgram.length ==
                                          0)
                                        return Center(
                                            child: Text('Tidak ada konten',
                                                style: TextStyle(
                                                    color: cOrtuText)));
                                      else
                                        return ListView.separated(
                                          controller:
                                              builderCtrl.scrollController,
                                          shrinkWrap: true,
                                          itemCount: builderCtrl.isThereMore
                                              ? builderCtrl.listSearchProgram
                                                      .length +
                                                  1
                                              : builderCtrl
                                                  .listSearchProgram.length,
                                          itemBuilder: (context, index) =>
                                              index <
                                                      builderCtrl
                                                          .listSearchProgram
                                                          .length
                                                  ? feedProgramContainer(
                                                      builderCtrl
                                                              .listSearchProgram[
                                                          index],
                                                      context)
                                                  : builderCtrl.isThereMore
                                                      ? wProgressIndicator()
                                                      : Container(),
                                          separatorBuilder: (ctx, idx) =>
                                              Divider(color: cOrtuGrey),
                                        );
                                    },
                                  ),
                                ),
                              );
                            }),
                      ),
                    ],
                  ),
                );
              }
            }).toList(),
          ),
        );
      }),
    );
  }

  Widget feedContainer(ContentModel data, BuildContext context) {
    final textColor = cOrtuText;
    return InkWell(
        child: Container(
          margin: EdgeInsets.only(top: 5, bottom: 5),
          child: Row(
            children: [
              data.contentThumbnail != null
                  ? imgContainer(data.contentThumbnail!)
                  : SizedBox(),
              Flexible(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: EdgeInsets.only(bottom: 5, left: 10),
                        child: Text(data.coBrandEmail,
                            style: TextStyle(fontSize: 10, color: textColor)),
                      ),
                      Container(
                        padding: EdgeInsets.only(bottom: 2, left: 10),
                        child: Text(data.contentName,
                            style: TextStyle(
                                fontSize: 14,
                                color: textColor,
                                fontWeight: FontWeight.bold)),
                      ),
                      // Container(
                      //   padding: EdgeInsets.only(bottom: 2),
                      //   child: Text(data.contentDescription, textAlign: TextAlign.justify, style: TextStyle(color: cOrtuGrey)),
                      // ),
                      Container(
                        padding:
                            EdgeInsets.only(bottom: 2, right: 10, left: 10),
                        child: Text('\n${dateFormat_EDMY(data.startDate)}',
                            style: TextStyle(fontSize: 10, color: textColor)),
                      ),
                    ],
                  )),
            ],
          ),
        ),
        onTap: () {
          if (data.contentType == ContentType.artikel) {
            String imgData = '';
            if (data.contentThumbnail != null) imgData = data.contentThumbnail!;
            showContent(
                context,
                emailUser,
                data.id,
                data.contents,
                data.contentName,
                imgData,
                '',
                data.contentSource,
                data.response);
          } else if (data.contentType == ContentType.video) {
            showContent(
                context,
                emailUser,
                data.id,
                data.contents,
                data.contentName,
                '',
                data.contentDescription,
                data.contentSource,
                data.response);
          } else if (data.contentType == ContentType.pdf) {
            Navigator.push(
                context,
                leftTransitionRoute(
                    FeedPdf(contentModel: data, emailUser: emailUser)));
          } else {
            showContent(context, emailUser, data.id, data.contents,
                data.contentName, '', '', data.contentSource, data.response);
          }
        });
  }

  Widget feedProgramContainer(ProgramModel data, BuildContext context) {
    final textColor = cOrtuText;
    return InkWell(
        child: Container(
          margin: EdgeInsets.only(top: 5, bottom: 5),
          child: Row(
            children: [
              data.thumbnail != null
                  ? imgContainer(data.thumbnail!)
                  : SizedBox(),
              Flexible(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: EdgeInsets.only(bottom: 5, left: 10),
                        child: Text(data.coBrandEmail,
                            style: TextStyle(fontSize: 10, color: textColor)),
                      ),
                      Container(
                        padding: EdgeInsets.only(bottom: 2, left: 10),
                        child: Text(data.programName,
                            style: TextStyle(
                                fontSize: 14,
                                color: textColor,
                                fontWeight: FontWeight.bold)),
                      ),
                      // Container(
                      //   padding: EdgeInsets.only(bottom: 2),
                      //   child: Text(data.contentDescription, textAlign: TextAlign.justify, style: TextStyle(color: cOrtuGrey)),
                      // ),
                      Container(
                        padding:
                            EdgeInsets.only(bottom: 2, right: 10, left: 10),
                        child: Text('\n${dateFormat_EDMY(data.startDate)}',
                            style: TextStyle(fontSize: 10, color: textColor)),
                      ),
                    ],
                  )),
            ],
          ),
        ),
        onTap: () async {
          if (userType == 'parent') {
            print("orang tua");
            showLoadingOverlay();
            await controller.getProgramContents(
                refresh: true, programId: data.id);
            closeOverlay();
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ProgramxPage(data.id, emailUser)));
          } else {
            showLoadingOverlay();
            await controller.getProgramContents(
                refresh: true, programId: data.id);
            closeOverlay();
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ProgramxPage(data.id, emailUser)));
          }
        });
  }

  Widget imgContainer(String imgUrl) {
    var dataImage = imgUrl.split(",");
    Uint8List _bytesImage;
    _bytesImage = Base64Decoder().convert(dataImage[1]);
    Image image = Image.memory(_bytesImage);
    return imgUrl.contains('data')
        ? ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 100,
            ),
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(image: image.image, fit: BoxFit.cover),
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          )
        : SizedBox();
  }

  Widget roundAddonAvatar(
      {required Size screenSize,
      required String imgUrl,
      required String addonName,
      bool isSelected = false}) {
    var dataImage = imgUrl.split(",");
    Uint8List _bytesImage;
    _bytesImage = dataImage.length > 1
        ? Base64Decoder().convert(dataImage[1])
        : Base64Decoder().convert('');
    Image image = Image.memory(_bytesImage);
    return Container(
      //color: isSelected ? cOrtuBlue : Colors.transparent,
      width: screenSize.width / 6,
      alignment: Alignment.center,
      margin: EdgeInsets.all(5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
              flex: 6,
              child: CircleAvatar(
                maxRadius: screenSize.height / 28,
                backgroundImage: imgUrl == 'assets/images/hkbpgo.png'
                    ? AssetImage('$imgUrl')
                    : image.image,
              )),
          Expanded(
            flex: 4,
            child: Align(
                alignment: Alignment.center,
                child: Text(
                    addonName == null
                        ? ''
                        : addonName.length >= 24
                            ? '${addonName.substring(0, 20)}...'
                            : addonName,
                    style: TextStyle(fontSize: 9, color: cOrtuText),
                    textAlign: TextAlign.center)),
          )
        ],
      ),
    );
  }
}
