import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ruangkeluarga/global/global.dart';
import 'package:ruangkeluarga/parent/view/feed/feed_controller.dart';

class FeedPage extends GetView<FeedController> {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Container(
          //   constraints: BoxConstraints(
          //     maxHeight: screenSize.height / 6,
          //     maxWidth: screenSize.width - 20,
          //   ),
          //   child: ListView.builder(
          //     shrinkWrap: true,
          //     scrollDirection: Axis.horizontal,
          //     itemCount: 10,
          //     itemBuilder: (context, index) {
          //       return roundAddonAvatar(imgUrl: 'assets/images/hkbpgo.png', addonName: 'HKBP GO $index');
          //     },
          //   ),
          // ),
          Container(
            padding: EdgeInsets.only(top: 10, bottom: 10),
            child: WSearchBar(
              hintText: 'Search by name',
              fOnChanged: (text) {
                controller.setSearchData(text);
              },
            ),
          ),
          Flexible(
            flex: 4,
            child: FutureBuilder<bool>(
                future: controller.fGetList,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return wProgressIndicator();
                  return RefreshIndicator(
                    onRefresh: () => controller.getContents(),
                    child: Container(
                      padding: EdgeInsets.all(5),
                      child: GetBuilder<FeedController>(
                        builder: (builderCtrl) {
                          return ListView.separated(
                            shrinkWrap: true,
                            itemCount: builderCtrl.listSearchContent.length,
                            itemBuilder: (context, index) => feedContainer(builderCtrl.listSearchContent[index]),
                            separatorBuilder: (ctx, idx) => Divider(color: cOrtuGrey),
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
    final textColor = cOrtuWhite;
    return InkWell(
      child: Container(
        margin: EdgeInsets.only(top: 5, bottom: 5),
        child: Row(
          children: [
            Flexible(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: EdgeInsets.only(bottom: 5),
                      child: Text(data.coBrandEmail, style: TextStyle(fontSize: 10, color: textColor)),
                    ),
                    Container(
                      padding: EdgeInsets.only(bottom: 2),
                      child: Text(data.contentName, style: TextStyle(fontSize: 20, color: textColor, fontWeight: FontWeight.bold)),
                    ),
                    Container(
                      padding: EdgeInsets.only(bottom: 2),
                      child: Text(data.contentDescription, textAlign: TextAlign.justify, style: TextStyle(color: cOrtuGrey)),
                    ),
                    Container(
                      padding: EdgeInsets.only(bottom: 2),
                      child: Text('\n${dateFormat_EDMYHM(data.dateCreated)}', style: TextStyle(fontSize: 10, color: textColor)),
                    ),
                  ],
                )),
            data.contentThumbnail != null ? imgContainer(data.contentThumbnail!) : SizedBox(),
          ],
        ),
      ),
    );
  }

  Widget imgContainer(String imgUrl) {
    return imgUrl.contains('http')
        ? ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 100,
            ),
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(image: NetworkImage(imgUrl), fit: BoxFit.contain),
                  borderRadius: BorderRadius.circular(15.0),
                ),
              ),
            ),
          )
        : SizedBox();
  }

  Widget roundAddonAvatar({
    required String imgUrl,
    required String addonName,
  }) {
    return Container(
      margin: EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: AssetImage('$imgUrl'),
          ),
          Padding(
            padding: EdgeInsets.only(top: 10),
            child: Text(
              '$addonName',
              style: TextStyle(color: cOrtuWhite),
            ),
          )
        ],
      ),
    );
  }
}
