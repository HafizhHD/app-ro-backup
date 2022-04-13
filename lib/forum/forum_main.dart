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
      margin: EdgeInsets.symmetric(
          vertical: screenSize.height / 9, horizontal: screenSize.width / 9),
      child: Center(
          child: Container(
              color: cAsiaBlue,
              padding: EdgeInsets.all(10),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('SEGERA HADIR',
                        style: TextStyle(
                            color: cOrtuWhite,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center),
                    Container(
                        padding: EdgeInsets.all(5),
                        child: Image.asset(
                            'assets/images/icon/undraw_forms_re_pkrt.png',
                            height: 150,
                            fit: BoxFit.fitHeight)),
                    Container(
                      padding: EdgeInsets.all(5),
                      child: Text(
                        'FITUR FORUM\nMerupakan media komunikasi bagi para orangtua yang diharapkan dapat menambah pengetahuan seputar Pola Asuh Anak di Era Digital',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: cOrtuWhite),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ]))),
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
