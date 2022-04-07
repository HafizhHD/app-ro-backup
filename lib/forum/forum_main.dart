import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ruangkeluarga/global/global.dart';
import 'package:ruangkeluarga/parent/view/feed/feed_controller.dart';
import 'package:ruangkeluarga/utils/rk_webview.dart';
import 'dart:convert';
import 'dart:typed_data';

class ForumMain extends GetView<FeedController> {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Forum',
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: cOrtuText)),
          Text('Selamat datang di forum $appName.',
              style: TextStyle(color: cOrtuText)),
          // Container(
          //   padding: EdgeInsets.only(top: 10, bottom: 10),
          //   child: WSearchBar(
          //       hintText: 'Search by name',
          //       fOnSubmitted: (text) {
          //         controller.setSearchData(text);
          //       },
          //       tecController: TextEditingController(text: controller.search)),
          // ),
          Flexible(
            flex: 4,
            child: FutureBuilder<bool>(
                future: controller.fGetListContent,
                builder: (context, snapshot) {
                  // if (!snapshot.hasData) return wProgressIndicator();
                  if (!snapshot.hasData)
                    return Center(
                        child: Text('Coming Soon',
                            style: TextStyle(color: cOrtuText)));
                  return RefreshIndicator(
                    onRefresh: () => controller.getContents(refresh: true),
                    child: Container(
                      padding: EdgeInsets.all(5),
                      child: GetBuilder<FeedController>(
                        builder: (builderCtrl) {
                          if (builderCtrl.listSearchContent.length >= 0)
                            return Center(
                                child: Text('Coming Soon',
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
                                          builderCtrl.listSearchContent[index])
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

  Widget feedContainer(ContentModel data) {
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
                        child: Text('Dibuat oleh ${data.coBrandEmail}',
                            style: TextStyle(fontSize: 9, color: textColor)),
                      ),
                      Container(
                        padding: EdgeInsets.only(bottom: 2, left: 10),
                        child: Text('Apakah ${data.contentName}?',
                            style: TextStyle(
                                fontSize: 12,
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
                            style: TextStyle(fontSize: 9, color: textColor)),
                      ),
                    ],
                  )),
            ],
          ),
        ),
        onTap: () {});
  }

  Widget imgContainer(String imgUrl) {
    var dataImage = imgUrl.split(",");
    Uint8List _bytesImage;
    _bytesImage = Base64Decoder().convert(dataImage[1]);
    Image image = Image.memory(_bytesImage);
    return imgUrl.contains('data')
        ? ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 50,
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
      {required String imgUrl,
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
      margin: EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: imgUrl == 'assets/images/hkbpgo.png'
                ? AssetImage('$imgUrl')
                : image.image,
          ),
          Padding(
            padding: EdgeInsets.only(top: 10),
            child: Text(
              addonName == null
                  ? ''
                  : addonName.length >= 12
                      ? '${addonName.substring(0, 9)}...'
                      : addonName,
              style: TextStyle(fontSize: 10, color: cOrtuText),
            ),
          )
        ],
      ),
    );
  }
}
