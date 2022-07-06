import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ruangkeluarga/global/global.dart';
import 'package:ruangkeluarga/model/rk_child_model.dart';
import 'package:ruangkeluarga/parent/view/akun/akun_edit.dart';
import 'package:ruangkeluarga/parent/view/main/parent_controller.dart';
import 'package:ruangkeluarga/parent/view_model/sekolah_al_azhar_model.dart';
import 'package:ruangkeluarga/utils/base_service/service_controller.dart';
import 'package:ruangkeluarga/utils/repository/media_repository.dart';
import 'package:ruangkeluarga/parent/view/order/order.dart';

import '../../../utils/rk_webview.dart';
import '../inbox/Inbox_page.dart';

class AkunPage extends StatelessWidget {
  final appInfo = Get.find<RKServiceController>().appInfo;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GetBuilder<ParentController>(
        builder: (ctrl) {
          final parentData = ctrl.parentProfile;
          final spouse = parentData.spouse ?? [];
          final children = parentData.children ?? [];

          return Column(mainAxisSize: MainAxisSize.max, children: [
            Expanded(
                child: Container(
                    // color: ,
                    padding: EdgeInsets.all(5),
                    child: RefreshIndicator(
                      onRefresh: () async {
                        await ctrl.getParentChildData();
                      },
                      child: SingleChildScrollView(
                        physics: AlwaysScrollableScrollPhysics(),
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
                                isParent:
                                    parentData.parentStatus.toEnumString(),
                                isMainAccount: true,
                                parentEmail: parentData.email),
                            Flexible(
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: spouse.length,
                                itemBuilder: (ctx, idx) {
                                  final spouseData = spouse[idx];
                                  print('Nama: ${spouseData.name}');
                                  print('Telepon: ${spouseData.phone}');
                                  print('Alamat: ${spouseData.address}');
                                  print(
                                      'Tgl. Lahir: ${spouseData.birdDate.toString()}');
                                  return profileContainer(
                                      imgUrl: spouseData.imgPhoto,
                                      name: spouseData.name ?? 'Nama Pasangan',
                                      email: spouseData.email ??
                                          'email@coparent.com',
                                      id: spouseData.id,
                                      phone: spouseData.phone ?? '',
                                      alamat: spouseData.address ?? '',
                                      birthDate: spouseData.birdDate,
                                      isParent: spouseData.parentStatus
                                          .toEnumString(),
                                      isMainParent: !parentData.isMainParent);
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
                                  var subsciption = null;
                                  if (childData.subscription.isNotEmpty) {
                                    subsciption = childData.subscription[0];
                                  }
                                  print('Nama: ${childData.name}');
                                  print('Telepon: ${childData.phone}');
                                  print('Alamat: ${childData.address}');
                                  print(
                                      'Tgl. Lahir: ${childData.birdDate.toString()}');
                                  return profileContainer(
                                      imgUrl: childData.imgPhoto,
                                      name: childData.name ?? 'Nama Anak',
                                      email:
                                          childData.email ?? 'email@anak.com',
                                      id: childData.id,
                                      phone: childData.phone ?? '',
                                      alamat: childData.address ?? '',
                                      birthDate: childData.birdDate,
                                      parentEmail: parentData.email,
                                      subsription: subsciption
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ))),
            Align(
                alignment: Alignment.bottomLeft,
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  InkWell(
                    child: Text("Kebijakan Privasi",
                      style: TextStyle(
                        color: Colors.blue
                      ),
                    ),
                    onTap: () {showPrivacyPolicy();},
                  ),
                  Text('Versi ${appInfo.version}'),
                ]),
            )

          ]);
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
    bool isMainAccount = false,
    bool isMainParent = false,
    String? imgUrl,
    required String name,
    required String email,
    required String id,
    String? phone,
    DateTime? birthDate,
    SekolahAlAzhar? namaSekolah,
    String? alamat,
    String? parentEmail,
    Subscription? subsription
  }) {
    print('Nama: $name, isParent: $isParent');
    String childEmail = "";
    if (email != parentEmail) childEmail = email;
    return Dismissible(
      key: Key('$name+$email'),
      direction: isMainAccount == false && isMainParent == false
          ? DismissDirection.horizontal
          : DismissDirection.none,
      confirmDismiss: isMainAccount == false && isMainParent == false
          ? (_) async {
              return await deleteChild(id, name, isParent);
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
            if (isMainAccount == true ||
                (isMainAccount == false && isMainParent == false)) {
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
                  selectedSekolahAlazhar: namaSekolah,
                  parentGender:
                      boolParent ? genderCharFromString(isParent) : null,
                ),
              );
            }
          },
          child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
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
                            SizedBox(height: 5),
                            subsription == null?
                              TextButton(onPressed: () async {
                              await Get.to(() => OrderPage(childEmail:
                                childEmail, parentEmail: parentEmail!),
                              );
                              await Get.find<ParentController>().getParentChildData();
                              closeOverlay();
                              },
                                child: Text('Upgrade Paket',
                                    style: TextStyle(
                                    color: cOrtuBlue,
                                    fontSize: 16))
                            ):
                            Text(
                              'Langganan sampai: '  + subsription.dateEnd!,
                              // style: TextStyle(fontSize: 20),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  )
                ),
                isMainAccount == false && isMainParent == false
                    ? Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () async {
                              await deleteChild(id, name, isParent);
                            }))
                    : SizedBox.shrink()
              ]),
        ),
      ),
    );
  }

  Future<bool?> deleteChild(
      String childId, String childName, String isParent) async {
    final String userType = isParent == '' ? 'anak' : 'co-parent';
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
              await Get.find<ParentController>().getParentChildData();
              closeOverlay();
              closeOverlay();
              showToastSuccess(
                  ctx: Get.context!,
                  successText:
                      'Berhasil menghapus $userType dengan nama $childName');
            } else
              showToastFailed(
                  ctx: Get.context!,
                  failedText:
                      'Gagal menghapus $userType dengan nama $childName');
          },
          child: Text('Hapus', style: TextStyle(color: cAsiaBlue)),
        ),
      ],
    ));
  }
}
