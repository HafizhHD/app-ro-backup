import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ruangkeluarga/global/global.dart';

class RKConfigAccessInternetPage extends StatefulWidget {
  @override
  _RKConfigAccessInternetPageState createState() => _RKConfigAccessInternetPageState();
  final String title;
  final String name;

  RKConfigAccessInternetPage({Key? key, required this.title, required this.name}) : super(key: key);
}

class _RKConfigAccessInternetPageState extends State<RKConfigAccessInternetPage> {
  bool _switchValueFilter = true;
  bool _switchValueSafeSearch = true;
  bool _switchValuePorno = true;
  bool _switchValueAborsi = true;
  bool _switchValueKencan = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: cPrimaryBg,
        appBar: AppBar(
          centerTitle: true,
          title: Text(widget.name, style: TextStyle(color: cOrtuWhite)),
          backgroundColor: cPrimaryBg,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: cOrtuWhite),
            onPressed: () => Navigator.of(context).pop(),
          ),
          elevation: 0,
        ),
        body: Container(
          padding: EdgeInsets.only(left: 10, right: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Flexible(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(5),
                      child: Text(
                        'Akses Internet',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: cOrtuWhite, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    WSearchBar(
                      fOnChanged: (v) {},
                    ),
                    //dropDown

                    Padding(
                      padding: EdgeInsets.all(5),
                      child: Divider(
                        thickness: 1,
                        color: cOrtuWhite,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Mengontrol Kata Kunci Yang Tepat Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqu',
                        style: TextStyle(color: cOrtuWhite),
                      ),
                    ),
                    Flexible(
                        child: Container(
                      padding: EdgeInsets.all(5),
                      child: Wrap(
                        children: List.generate(20, (index) {
                          return Container(
                            margin: EdgeInsets.all(2),
                            padding: EdgeInsets.all(5),
                            color: cOrtuGrey,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Narkoba$index'),
                                IconButton(onPressed: () {}, icon: Icon(Icons.close)),
                              ],
                            ),
                          );
                        }),
                      ),
                    )),
                    SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text(
                        'Daftarkan Kata Kunci',
                        style: TextStyle(color: cOrtuWhite),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      // controller: cPhoneNumber,
                      minLines: 3,
                      maxLines: 5,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Tulis kata kunci dan pisahkan dengan tanda koma',
                        contentPadding: const EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: FlatButton(
                  height: 50,
                  minWidth: 300,
                  shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(15.0),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  color: cOrtuBlue,
                  child: Text(
                    "DAFTAR",
                    style: TextStyle(
                      fontFamily: 'Raleway',
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
