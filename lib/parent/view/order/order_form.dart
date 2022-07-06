import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:ruangkeluarga/global/global.dart';
import 'package:ruangkeluarga/utils/repository/media_repository.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:ruangkeluarga/parent/view/order/order_result.dart';

class OrderForm extends StatefulWidget {
  String parentEmail;
  String? childEmail;
  String packageId;
  String packageName;
  int price;

  OrderForm({
    required this.parentEmail,
    required this.packageId,
    required this.packageName,
    required this.price,
    this.childEmail,
  });

  @override
  _OrderFormState createState() => _OrderFormState();
}

class _OrderFormState extends State<OrderForm> {
  TextEditingController cPaymentMethod = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Pilih Cara Pembayaran', style: TextStyle(color: cOrtuWhite)),
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          backgroundColor: cTopBg,
        ),
        backgroundColor: cPrimaryBg,
        body:
          ListView(
              padding: const EdgeInsets.only(
                top: 20,
              ),
              scrollDirection: Axis.vertical,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    ListTile(
                      leading: Image.network(
                        "https://roi.ruangortu.id/wp-content/uploads/2022/06/gopay.jpg",
                      ),
                      title: Text(
                        "GOPAY",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Pembayaran dapat menggunakan Aplikasi GoPay pada dari perangkat anda',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () => beliPaket(widget.packageId, widget.packageName,
                          widget.parentEmail, widget.childEmail, "gopay", widget.price)
                    ),
                    ListTile(
                        leading: Image.network(
                          "https://roi.ruangortu.id/wp-content/uploads/2022/06/shopee-pay.jpg",
                        ),
                        title: Text(
                          "Shopee Pay",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Pembayaran dapat menggunakan Aplikasi Shopee Pay pada dari perangkat anda',
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () => beliPaket(widget.packageId, widget.packageName,
                            widget.parentEmail, widget.childEmail, "shopee", widget.price)
                    ),
                    ListTile(
                        leading: Image.network(
                          "https://roi.ruangortu.id/wp-content/uploads/2022/06/qris.jpg",
                        ),
                        title: Text(
                          "QRIS",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Pembayaran QRIS dengan dompet digital(GoPay, Shopee Pay, OVO, Dana, Livin by Mandiri, dan aplikasi lainnya)',
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () => beliPaket(widget.packageId, widget.packageName,
                            widget.parentEmail, widget.childEmail, "qris", widget.price)
                    ),
                    ListTile(
                        leading: Image.network(
                          "https://roi.ruangortu.id/wp-content/uploads/2022/06/mandiri.jpg",
                        ),
                        title: Text(
                          "Transfer Bank Mandiri",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Pembayaran dapat mentrransfer ke rekening virtual account mandiri',
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () => beliPaket(widget.packageId, widget.packageName,
                            widget.parentEmail, widget.childEmail, "mandiri", widget.price)
                    ),
                    ListTile(
                      leading: Image.network(
                        "https://roi.ruangortu.id/wp-content/uploads/2022/06/bni.jpg",
                      ),
                      title: Text(
                        "Transfer Bank BNI",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Pembayaran dapat mentrransfer ke rekening virtual account BNI',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () => beliPaket(widget.packageId, widget.packageName,
                            widget.parentEmail, widget.childEmail, "bni", widget.price)
                    ),
                    ListTile(
                        leading: Image.network(
                          "https://roi.ruangortu.id/wp-content/uploads/2022/06/bri.jpg",
                        ),
                        title: Text(
                          "Transfer Bank BNI",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Pembayaran dapat mentrransfer ke rekening virtual account BRI',
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () => beliPaket(widget.packageId, widget.packageName,
                            widget.parentEmail, widget.childEmail, "bri", widget.price)
                    ),
                    ListTile(
                        leading: Image.network(
                          "https://roi.ruangortu.id/wp-content/uploads/2022/06/permata.jpg",
                        ),
                        title: Text(
                          "Transfer Bank Permata",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Pembayaran dapat mentrransfer ke rekening virtual account Permata',
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () async {
                          await beliPaket(widget.packageId, widget.packageName,widget.parentEmail, widget.childEmail, "permata", widget.price);
                        }
                    ),
                  ],
                ),
              ]
          )
    );
  }

  Future<bool> beliPaket(String packageId, packageName, parentEmail,
      childEmail, paymentMethod, int amount) async {
    Map<String, dynamic> beliValue = {
      "emailUser": "$parentEmail",
      "paymentMethod": "$paymentMethod",
      "childEmailUser": "$childEmail",
      "cobrandEmail": "admin@asia.ruangortu.id",
      "amount": "$amount",
      "packageId": "$packageId",
      "price": "$amount",
      "quantity": "1",
      "packageName": "$packageName"
    };
    http.Response r = await MediaRepository().orderRequest(beliValue);
    if (r.statusCode == 200) {
      var json = jsonDecode(r.body);
      if (json['resultCode'] == "OK") {
        var data = json['Data'];
        if (paymentMethod == "gopay") {
          var actions = data['actions'];
          String QRUrl = actions[0]['url'];
          String appUrl = actions[1]['url'];
          try {
            final bool nativeAppLaunchSucceeded = await launchUrlString(
              appUrl,
              mode: LaunchMode.externalNonBrowserApplication,
            );
            if (!nativeAppLaunchSucceeded) {
              var r = await Get.to(() =>
                  OrderResult(linkImage: QRUrl,
                      virtuelAccount: "",
                      paymentMethod: paymentMethod));
              if (r) Get.back(result: true);
            }
          } catch(e) {
            var r = await Get.to(() =>
                OrderResult(linkImage: QRUrl,
                    virtuelAccount: "",
                    paymentMethod: paymentMethod));
            if (r) Get.back(result: true);
          }
        }
        if (paymentMethod == "qris") {
          var actions = data['actions'];
          String QRUrl = actions[0]['url'];
          var r = await Get.to(() =>
                OrderResult(linkImage: QRUrl,
                    virtuelAccount: "",
                    paymentMethod: paymentMethod));
          if (r) Get.back(result: true);
        }
        else if (paymentMethod == "permata") {
          String VANumber = data['permata_va_number'];
          var r = await Get.to(() => OrderResult(linkImage: "",
              virtuelAccount: VANumber, paymentMethod: paymentMethod));
          if (r) Get.back(result: true);
        }
        else if ((paymentMethod == "bni") || (paymentMethod == "bri")) {
          String VANumber = data['va_numbers'][0]["va_number"];
          var r = await Get.to(() => OrderResult(linkImage: "",
              virtuelAccount: VANumber, paymentMethod: paymentMethod));
          if (r) Get.back(result: true);
        }
        else if (paymentMethod == "mandiri") {
          String BilCode = data['biller_code'];
          String BilKey = data['bill_key'];
          var r = await Get.to(() => OrderResult(linkImage: "",
              virtuelAccount: "", bilKey: BilKey, bilCode: BilCode,
              paymentMethod: paymentMethod));
          if (r) Get.back(result: true);
        }
      }
    }
    return true;
  }
}
