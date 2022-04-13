import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ruangkeluarga/child/child_controller.dart';
import 'package:ruangkeluarga/global/global.dart';
import 'package:ruangkeluarga/parent/view/akun/akun_edit.dart';
import 'package:ruangkeluarga/utils/base_service/service_controller.dart';
import 'package:ruangkeluarga/utils/repository/media_repository.dart';

class ChildAkunPage extends StatelessWidget {
  final appInfo = Get.find<RKServiceController>().appInfo;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GetBuilder<ChildController>(
        builder: (ctrl) {
          final childProfile = ctrl.childProfile;
          final parentData = ctrl.parentProfile;
          final otherParent = ctrl.otherParentProfile;
          final children = parentData.children ?? [];
          return Container(
            // color: ,
            padding: EdgeInsets.all(5),
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  profileContainer(
                    id: childProfile.id,
                    imgUrl: childProfile.imgPhoto,
                    name: childProfile.name,
                    email: childProfile.email,
                    phone: childProfile.phone,
                    alamat: childProfile.address,
                    birthDate: childProfile.birdDate,
                    canEdit: true,
                  ),
                  profileContainer(
                    id: parentData.id,
                    imgUrl: parentData.imgPhoto,
                    name: parentData.name,
                    email: parentData.email,
                    phone: parentData.phone,
                    alamat: parentData.address,
                    birthDate: childProfile.birdDate,
                    isParent: parentData.parentStatus.toEnumString(),
                  ),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: otherParent.length,
                      itemBuilder: (ctx, idx) {
                        final otherParentData = otherParent[idx];
                        return profileContainer(
                            id: otherParentData.id,
                            imgUrl: otherParentData.imgPhoto,
                            name: otherParentData.name,
                            email: otherParentData.email,
                            phone: otherParentData.phone,
                            alamat: otherParentData.address,
                            birthDate: childProfile.birdDate,
                            isParent:
                                otherParentData.parentStatus.toEnumString()
                            // phone: ,
                            );
                      },
                    ),
                  ),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: children.length,
                      itemBuilder: (ctx, idx) {
                        final childData = children[idx];
                        return childData.id == childProfile.id
                            ? SizedBox()
                            : profileContainer(
                                imgUrl: childData.imgPhoto,
                                name: childData.name ?? 'Nama Anak',
                                email: childData.email ?? 'email@anak.com',
                                id: childData.id,
                                // phone: ,
                              );
                      },
                    ),
                  ),
                  Container(
                      margin: EdgeInsets.all(10),
                      child: Text('Versi ${appInfo.version}'))
                ],
              ),
            ),
          );
        },
      ),
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: () => logUserOut(),
      //   label: Text('Sign Out'),
      //   backgroundColor: cOrtuOrange,
      //   foregroundColor: cPrimaryBg,
      // ),
    );
  }

  Widget profileContainer({
    String isParent = '',
    String? imgUrl,
    required String name,
    required String email,
    required String id,
    String? phone,
    String? alamat,
    DateTime? birthDate,
    bool canEdit = false,
  }) {
    return Container(
      margin: EdgeInsets.all(5),
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: cOrtuGrey,
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: InkWell(
        onTap: canEdit
            ? () {
                final bool boolParent = isParent == '' ? false : true;
                Get.to(
                  () => AkunEditPage(
                    id: id,
                    name: name,
                    email: email,
                    phoneNum: phone,
                    alamat: alamat,
                    isParent: boolParent,
                    imgUrl: imgUrl,
                    birthDate: birthDate,
                    parentGender:
                        boolParent ? genderCharFromString(isParent) : null,
                  ),
                );
              }
            : null,
        child: Row(
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
                          color: cAsiaBlue,
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Center(
                            child: Icon(Icons.person,
                                color: cPrimaryBg, size: 50)),
                      )
                    : Container(
                        margin: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          image: imgUrl.contains('http')
                              ? DecorationImage(
                                  image: NetworkImage(imgUrl),
                                  fit: BoxFit.cover)
                              : DecorationImage(
                                  image: AssetImage(imgUrl), fit: BoxFit.cover),
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
                    if (!canEdit) Text(isParent != '' ? isParent : 'Saudara'),
                    SizedBox(height: 5),
                    Text(
                      '$email',
                      // style: TextStyle(fontSize: 20),
                    ),
                    SizedBox(height: 5),
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
      ),
    );
  }

  Future<bool?> deleteChild(String childId, String childName) async {
    return Get.dialog<bool>(AlertDialog(
      title: Text('Hapus Akun'),
      content: Text('Yakin ingin menghapus akun $childName?'),
      actions: [
        TextButton(
          onPressed: () {
            Get.back(result: false);
          },
          child: Text('Batal', style: TextStyle(color: cAsiaBlue)),
        ),
        TextButton(
          onPressed: () async {
            showLoadingOverlay();
            final response = await MediaRepository().removeUser(childId);
            if (response.statusCode == 200) {
              await Get.find<ChildController>().getChildData();
              closeOverlay();
              closeOverlay();
              showToastSuccess(
                  ctx: Get.context!,
                  successText:
                      'Berhasil menghapus anak dengan nama $childName');
            } else
              showToastFailed(
                  ctx: Get.context!,
                  failedText: 'Gagal menghapus anak dengan nama $childName');
          },
          child: Text('Hapus', style: TextStyle(color: cAsiaBlue)),
        ),
      ],
    ));
  }
}
