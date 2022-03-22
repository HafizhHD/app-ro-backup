import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ruangkeluarga/global/global.dart';
import 'package:ruangkeluarga/parent/view/akun/akun_edit.dart';
import 'package:ruangkeluarga/parent/view/main/parent_controller.dart';
import 'package:ruangkeluarga/utils/repository/media_repository.dart';

class AkunPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GetBuilder<ParentController>(
        builder: (ctrl) {
          final parentData = ctrl.parentProfile;
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
                      id: parentData.id,
                      imgUrl: parentData.imgPhoto,
                      name: parentData.name,
                      email: parentData.email,
                      phone: parentData.phone,
                      alamat: parentData.address,
                      birthDate: parentData.birdDate,
                      isParent: parentData.parentStatus.toEnumString()),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: children.length,
                      itemBuilder: (ctx, idx) {
                        final childData = children[idx];
                        print('Nama: ${childData.name}');
                        print('Telepon: ${childData.phone}');
                        print('Alamat: ${childData.address}');
                        print('Tgl. Lahir: ${childData.birdDate.toString()}');
                        return profileContainer(
                            imgUrl: childData.imgPhoto,
                            name: childData.name ?? 'Nama Anak',
                            email: childData.email ?? 'email@anak.com',
                            id: childData.id,
                            phone: childData.phone ?? '',
                            alamat: childData.address ?? '',
                            birthDate: childData.birdDate);
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => logUserOut(),
        label: Text('Sign Out'),
        backgroundColor: cOrtuOrange,
        foregroundColor: cPrimaryBg,
      ),
    );
  }

  Widget profileContainer({
    String isParent = '',
    String? imgUrl,
    required String name,
    required String email,
    required String id,
    String? phone,
    DateTime? birthDate,
    String? alamat,
  }) {
    return Dismissible(
      key: Key('$name+$email'),
      direction: isParent == '' ? DismissDirection.horizontal : DismissDirection.none,
      confirmDismiss: isParent == ''
          ? (_) async {
              return await deleteChild(id, name);
            }
          : null,
      child: Container(
        margin: EdgeInsets.all(5),
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: cOrtuGrey,
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: InkWell(
          onTap: () {
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
          },
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
                            color: cOrtuBlue,
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: Center(
                              child: Icon(Icons.add_a_photo,
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
                                    image: AssetImage(imgUrl),
                                    fit: BoxFit.cover),
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
                      Text(isParent != '' ? isParent : 'Anak'),
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
      ),
    );
  }

  Future<bool?> deleteChild(String childId, String childName) async {
    return Get.dialog<bool>(AlertDialog(
      title: Text('Hapus Anak'),
      content: Text('Yakin ingin menghapus akun $childName?'),
      actions: [
        TextButton(
          onPressed: () {
            Get.back(result: false);
          },
          child: Text('Batal', style: TextStyle(color: cOrtuBlue)),
        ),
        TextButton(
          onPressed: () async {
            showLoadingOverlay();
            final response = await MediaRepository().removeUser(childId);
            if (response.statusCode == 200) {
              await Get.find<ParentController>().getParentChildData();
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
          child: Text('Hapus', style: TextStyle(color: cOrtuBlue)),
        ),
      ],
    ));
  }
}
