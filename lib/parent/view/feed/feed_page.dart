import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ruangkeluarga/global/global.dart';
import 'package:ruangkeluarga/parent/view/feed/feed_controller.dart';
import 'package:ruangkeluarga/parent/view/feed/feed_pdf.dart';
import 'package:ruangkeluarga/utils/rk_webview.dart';
import 'dart:convert';
import 'dart:typed_data';

class FeedPage extends StatelessWidget {
  FeedPage(this.emailUser);
  final String emailUser;
  final controller = Get.find<FeedController>();
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // DIHILANGKAN DI APLIKASI KELUARGA HKBP ==
          FutureBuilder<bool>(
              future: controller.fGetListCoBrand,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return wProgressIndicator();
                return GetBuilder<FeedController>(builder: (builderCtrl) {
                  return Container(
                    constraints: BoxConstraints(
                      maxHeight: screenSize.height / 7,
                      maxWidth: screenSize.width,
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: builderCtrl.listCoBrand.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                            child: Card(
                                color: builderCtrl.selectedCoBrand == index
                                    ? cAsiaBlue
                                    : cPrimaryBg,
                                shadowColor: cPrimaryBg,
                                child: roundAddonAvatar(
                                    screenSize: screenSize,
                                    imgUrl: builderCtrl
                                            .listCoBrand[index].thumbnail ??
                                        'assets/images/hkbpgo.png',
                                    // imgUrl: 'assets/images/hkbpgo.png',
                                    addonName:
                                        builderCtrl.listCoBrand[index].name,
                                    isSelected: true)),
                            onTap: () async {
                              showLoadingOverlay();
                              if (builderCtrl.selectedCoBrand == index) {
                                builderCtrl.selectedCoBrand = -1;
                                await builderCtrl.getContents(
                                    refresh: true, cobrand: 'all');
                              } else {
                                builderCtrl.selectedCoBrand = index;
                                await builderCtrl.getContents(
                                    refresh: true,
                                    cobrand:
                                        builderCtrl.listCoBrand[index].email);
                              }
                              closeOverlay();
                            });
                      },
                    ),
                  );
                });
              }),
          // SAMPAI SINI ==
          Container(
            padding: EdgeInsets.only(top: 10, bottom: 10),
            child: WSearchBar(
                hintText: 'Search by name',
                fOnSubmitted: (text) {
                  controller.setSearchData(text);
                },
                tecController: TextEditingController(text: controller.search)),
          ),
          Flexible(
            flex: 4,
            child: FutureBuilder<bool>(
                future: controller.fGetListContent,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return wProgressIndicator();
                  return RefreshIndicator(
                    onRefresh: () => controller.getContents(refresh: true),
                    child: Container(
                      padding: EdgeInsets.all(5),
                      child: GetBuilder<FeedController>(
                        builder: (builderCtrl) {
                          if (builderCtrl.listSearchContent.length == 0)
                            return Center(
                                child: Text('Tidak ada konten',
                                    style: TextStyle(color: cOrtuText)));
                          else
                            return ListView.separated(
                              controller: builderCtrl.scrollController,
                              shrinkWrap: true,
                              itemCount: builderCtrl.isThereMore
                                  ? builderCtrl.listSearchContent.length + 1
                                  : builderCtrl.listSearchContent.length,
                              itemBuilder: (context, index) =>
                                  index < builderCtrl.listSearchContent.length
                                      ? feedContainer(
                                          builderCtrl.listSearchContent[index],
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
            imgData = data.contentThumbnail!;
            showContent(context, emailUser, data.id, data.contents,
                data.contentName, imgData, '', data.contentSource);
          } else if (data.contentType == ContentType.video) {
            showContent(
                context,
                emailUser,
                data.id,
                data.contents,
                data.contentName,
                '',
                data.contentDescription,
                data.contentSource);
          } else if (data.contentType == ContentType.pdf) {
            Navigator.push(
                context,
                leftTransitionRoute(
                    FeedPdf(contentModel: data, emailUser: emailUser)));
          } else {
            showContent(context, emailUser, data.id, data.contents,
                data.contentName, '', '', data.contentSource);
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
    // return imgUrl.contains('http')
    //     ? ConstrainedBox(
    //         constraints: BoxConstraints(
    //           maxWidth: 100,
    //         ),
    //         child: AspectRatio(
    //           aspectRatio: 1,
    //           child: Container(
    //             decoration: BoxDecoration(
    //               image: DecorationImage(image: NetworkImage(imgUrl), fit: BoxFit.contain),
    //               borderRadius: BorderRadius.circular(15.0),
    //             ),
    //           ),
    //         ),
    //       )
    //     : SizedBox();
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
          CircleAvatar(
            radius: screenSize.height / 28,
            backgroundImage: imgUrl == 'assets/images/hkbpgo.png'
                ? AssetImage('$imgUrl')
                : image.image,
          ),
          Padding(
            padding: EdgeInsets.only(top: 5),
            child: Text(
                addonName == null
                    ? ''
                    : addonName.length >= 24
                        ? '${addonName.substring(0, 20)}...'
                        : addonName,
                style: TextStyle(fontSize: 9, color: cOrtuText),
                textAlign: TextAlign.center),
          )
        ],
      ),
    );
  }
}
