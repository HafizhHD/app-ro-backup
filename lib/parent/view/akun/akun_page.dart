import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ruangkeluarga/global/global.dart';
import 'package:ruangkeluarga/global/global_snackbar.dart';
import 'package:ruangkeluarga/parent/view/main/parent_controller.dart';
import 'package:ruangkeluarga/utils/repository/media_repository.dart';

class AkunPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ParentController>(
      builder: (ctrl) {
        final parentData = ctrl.parentProfile;
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
                        id: childData.id,
                        // phone: ,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 'assets/images/foto_anak.png'
  Widget profileContainer({
    String? imgUrl,
    required String name,
    required String email,
    String? id,
    String? phone,
  }) {
    return Dismissible(
      key: Key('$name+$email'),
      direction: id != null && id != '' ? DismissDirection.horizontal : DismissDirection.none,
      confirmDismiss: id != null && id != ''
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
          child: Text('Batal', style: TextStyle(color: cOrtuOrange)),
        ),
        TextButton(
          onPressed: () async {
            showLoadingOverlay();
            final response = await MediaRepository().removeUser(childId);
            if (response.statusCode == 200) {
              await Get.find<ParentController>().getParentChildData();
              closeOverlay();
              closeOverlay();
              showSnackbar('Berhasil menghapus anak dengan nama $childName');
            } else
              showSnackbar('Gagal menghapus anak dengan nama $childName');
          },
          child: Text('Hapus', style: TextStyle(color: cOrtuOrange)),
        ),
      ],
    ));
  }
}
