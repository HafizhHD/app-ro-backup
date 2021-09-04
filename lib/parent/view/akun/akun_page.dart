import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ruangkeluarga/global/global.dart';
import 'package:ruangkeluarga/parent/view/main/parent_controller.dart';

class AkunPage extends StatelessWidget {
  final parentController = Get.find<ParentController>();

  @override
  Widget build(BuildContext context) {
    final parentData = parentController.parentProfile;
    return Container(
      // color: ,
      padding: EdgeInsets.all(5),
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            profileContainer(imgUrl: parentData.imgPhoto, name: parentData.name, email: parentData.email, phone: parentData.phone),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: parentData.children.length,
                itemBuilder: (ctx, idx) {
                  final childData = parentData.children[idx];
                  return profileContainer(
                    // imgUrl: 'assets/images/foto_anak.png',
                    name: childData.name ?? 'Nama Anak',
                    email: childData.email ?? 'email@anak.com',
                    // phone: ,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 'assets/images/foto_anak.png'
  Widget profileContainer({
    String? imgUrl,
    required String name,
    required String email,
    String? phone,
  }) {
    return Container(
      margin: EdgeInsets.all(5),
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: cOrtuGrey,
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Stack(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 100,
                ),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: imgUrl == null
                      ? Container(
                          margin: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: cOrtuBlue,
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: Center(child: Icon(Icons.add_a_photo, color: cPrimaryBg, size: 50)),
                        )
                      : Container(
                          margin: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            image: imgUrl.contains('http')
                                ? DecorationImage(image: NetworkImage(imgUrl), fit: BoxFit.cover)
                                : DecorationImage(image: AssetImage(imgUrl), fit: BoxFit.cover),
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                        ),
                ),
              ),
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
                      SizedBox(height: 10),
                      Text(
                        '$email',
                        // style: TextStyle(fontSize: 20),
                      ),
                      SizedBox(height: 10),
                      if (phone != null)
                        Text(
                          '$phone',
                          // style: TextStyle(fontSize: 20),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 1,
            right: 1,
            child: IconButton(
              iconSize: 35,
              icon: Icon(Icons.edit),
              onPressed: () {},
            ),
          )
        ],
      ),
    );
  }
}
