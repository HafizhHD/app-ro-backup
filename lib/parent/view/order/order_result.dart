import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:ruangkeluarga/global/global.dart';

class OrderResult extends StatefulWidget {
  String paymentMethod;
  String linkImage;
  String? virtuelAccount;
  String? bilCode;
  String? bilKey;


  OrderResult({
    required this.paymentMethod,
    required this.linkImage,
    this.virtuelAccount,
    this.bilCode,
    this.bilKey,
  });

  @override
  _OrderResultState createState() => _OrderResultState();
}

class _OrderResultState extends State<OrderResult> {
  TextEditingController cPaymentMethod = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String? va = widget.virtuelAccount;
    String? billKey = widget.bilKey;
    String? billCode = widget.bilCode;
    if (widget.paymentMethod == "mandiri") {
      va = widget.bilCode! + widget.bilKey!;
    }

    return Scaffold(
        backgroundColor: cPrimaryBg,
        body:
          ListView(
              padding: const EdgeInsets.only(
                top: 40, left: 20, right: 20
              ),
              scrollDirection: Axis.vertical,
              children: <Widget>[
                Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:
                  <Widget>[
                    SizedBox(height: 10),
                    if ((widget.paymentMethod == "gopay") || (widget.paymentMethod == "qris"))
                      Image.network(widget.linkImage),
                    if ((widget.paymentMethod == "gopay") || (widget.paymentMethod == "qris"))
                      Text(
                      'Silahkan scan QR di atas untuk malakukan pembayaran. Scan QR dapat digunakan melalui aplikasi dompet digital anda(GoPay, OVO, Dana, Shopee, Livin Mandiri, Dll)',
                      style: TextStyle(fontSize: 20.0)),
                    if ((widget.paymentMethod == "bni") || (widget.paymentMethod == "bri") || (widget.paymentMethod == "permata"))
                      Text(
                        "Virtual Account : $va",
                        style: TextStyle(fontSize: 20.0),
                      ),
                    SizedBox(height: 5),
                    if (widget.paymentMethod == "mandiri")
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          child: Text(
                            "Penyedia Jasa : $billCode (midtrans)",
                            style: TextStyle(fontSize: 20.0),
                          ),
                        ),
                      ),
                    if (widget.paymentMethod == "mandiri")
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          child: Text(
                            "Kode Bayar : $billKey",
                            style: TextStyle(fontSize: 18.0),
                          ),
                        ),
                      ),
                    if ((widget.paymentMethod == "bni") || (widget.paymentMethod == "bri") || (widget.paymentMethod == "mandiri") || (widget.paymentMethod == "permata"))
                      Text(
                        '',
                        style: TextStyle(fontSize: 18.0),
                      ),
                      Text(
                      'Silahkan lakukan pembayaran dengan cara mentransfer ke nomer virtual account di atas.',
                      style: TextStyle(fontSize: 16.0),
                      ),
                    Text(
                      '',
                      style: TextStyle(fontSize: 20.0),
                    ),
                    MaterialButton(
                      child: Text('Lanjut', style: TextStyle(color: Colors.white),),
                      color: cOrtuButton,
                      onPressed: () {Get.back(result: true);},
                    ),
                  ],
                ),
              ]
          )
    );
  }
}
