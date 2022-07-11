import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ruangkeluarga/global/global.dart';
import 'package:ruangkeluarga/parent/view/main/parent_controller.dart';
import 'package:ruangkeluarga/parent/view/order/order_form.dart';

class OrderPage extends StatelessWidget {
  String parentEmail;
  String childEmail;

  OrderPage({
    required this.childEmail,
    required this.parentEmail,
  });

  @override
  //
  // State<StatefulWidget> createState() {
  //   // TODO: implement createState
  //   throw UnimplementedError();
  // }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pilih Paket', style: TextStyle(color: cOrtuWhite)),
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        backgroundColor: cTopBg,
      ),
      backgroundColor: cPrimaryBg,
      body: GetBuilder<ParentController>(
        builder: (ctrl) {
          final packages = ctrl.listPackage;
          return Column(mainAxisSize: MainAxisSize.max, children: [
            Expanded(
                child: Container(
                  // color: ,
                    padding: EdgeInsets.all(5),
                    child: RefreshIndicator(
                      onRefresh: () async {
                        // getParentpackageData();
                      },
                      child: SingleChildScrollView(
                        physics: AlwaysScrollableScrollPhysics(),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Flexible(
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: packages.length,
                                itemBuilder: (ctx, idx) {
                                  final packageData = packages[idx];
                                  print('Nama Paket: ${packageData.PackageName}');
                                  print('Syarat dan Ketentuan: ${packageData.PackageDescription}');
                                  print('Harga: ${packageData.PackagePrice}');
                                  return packageContainer(
                                      paketId: packageData.PackageId,
                                      namaPaket: packageData.PackageName,
                                      deskripsi: packageData.PackageDescription,
                                      harga: packageData.PackagePrice,
                                      thumbnail: packageData.PackageIcon!,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ))),
          ]);
        },
      ),
    );
  }

  Widget packageContainer({
    required String paketId,
    required String namaPaket,
    required String deskripsi,
    required String thumbnail,
    required int harga,
  }) {
    print('Nama Paket: $namaPaket');
    return Dismissible(
      key: Key('$namaPaket'),
      child: Container(
        margin: EdgeInsets.all(5),
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: cOrtuGrey,
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: InkWell(
          onTap: () async {
              var r = await Get.to(
                () => OrderForm(parentEmail: parentEmail, childEmail: childEmail,
                    packageId: paketId, packageName: namaPaket, price: harga ),
              );
              if (r) Get.back(result: true);
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
                        ),
                        Flexible(
                          child: Container(
                            margin: EdgeInsets.all(5),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Image.network(
                                  thumbnail,
                                  fit: BoxFit.scaleDown,
                                ),
                                Text(
                                  '$namaPaket',
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Rp. $harga',
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Ketentuan: $deskripsi',
                                  // style: TextStyle(fontSize: 20),
                                ),
                                SizedBox(height: 5),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )),
              ]),
        ),
      ),
    );
  }
  
}
