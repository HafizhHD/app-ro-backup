import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RKConfigAccessInternet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp();
  }
}

class RKConfigAccessInternetPage extends StatefulWidget {
  // List<charts.Series> seriesList;
  @override
  _RKConfigAccessInternetPageState createState() => _RKConfigAccessInternetPageState();
  final String title;

  RKConfigAccessInternetPage({Key? key, required this.title}) : super(key: key);
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
        appBar: AppBar(
          title: Text(widget.title, style: TextStyle(color: Colors.grey.shade700)),
          backgroundColor: Colors.white70,
          iconTheme: IconThemeData(color: Colors.grey.shade700),
        ),
        backgroundColor: Colors.grey[300],
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: Colors.grey[300],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: SingleChildScrollView(
                    child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.only(top: 10.0),
                        height: 50,
                        color: Colors.white,
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            'Boao Simanjuntak',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.all(20.0),
                        child: Text('Kontrol Instant', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      Container(
                        height: 80,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey,
                              blurRadius: 3.0,
                            ),
                          ],
                        ),
                        child: Align(
                          child: Container(
                            margin: EdgeInsets.all(10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  child: Text(
                                    'Siagakan Internet Filters',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                                Container(
                                  child: CupertinoSwitch(
                                    value: _switchValueFilter,
                                    onChanged: (value) {
                                      setState(() {
                                        _switchValueFilter = value;
                                      });
                                    },
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: 150,
                        margin: EdgeInsets.only(top: 20.0),
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey,
                              blurRadius: 3.0,
                            ),
                          ],
                        ),
                        child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Container(
                            margin: EdgeInsets.all(10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  child: Text(
                                    'Safe Search',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                                Container(
                                  child: CupertinoSwitch(
                                    value: _switchValueSafeSearch,
                                    onChanged: (value) {
                                      setState(() {
                                        _switchValueSafeSearch = value;
                                      });
                                    },
                                  ),
                                )
                              ],
                            ),
                          ),
                          Container(
                            height: 50,
                            margin: EdgeInsets.only(left: 10.0, right: 10.0),
                            child: Text('SafeSearch merupakan fitur untuk menyembunyikan hasil pencarian'
                                'eksplit, ini berupaya untuk menyehatkan hasil pencarian pada internet.'),
                          )
                        ]),
                      ),
                      Container(
                        height: 150,
                        margin: EdgeInsets.only(top: 10.0),
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey,
                              blurRadius: 3.0,
                            ),
                          ],
                        ),
                        child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Container(
                            margin: EdgeInsets.all(10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  child: Text(
                                    'Pornografi',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                                Container(
                                  child: CupertinoSwitch(
                                    value: _switchValuePorno,
                                    onChanged: (value) {
                                      setState(() {
                                        _switchValuePorno = value;
                                      });
                                    },
                                  ),
                                )
                              ],
                            ),
                          ),
                          Container(
                            height: 50,
                            margin: EdgeInsets.only(left: 10.0, right: 10.0),
                            child: Text('Pemblokiran akses internet untuk semua konten dewasa'
                                ' (17+ tahun atau lebih), yang mana menghadirkan atau '
                                'memperlihatkan konten sexual atau porno.'),
                          )
                        ]),
                      ),
                      Container(
                        height: 150,
                        margin: EdgeInsets.only(top: 10.0),
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey,
                              blurRadius: 3.0,
                            ),
                          ],
                        ),
                        child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Container(
                            margin: EdgeInsets.all(10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  child: Text(
                                    'Obat-obatan/Aborsi',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                                Container(
                                  child: CupertinoSwitch(
                                    value: _switchValueAborsi,
                                    onChanged: (value) {
                                      setState(() {
                                        _switchValueAborsi = value;
                                      });
                                    },
                                  ),
                                )
                              ],
                            ),
                          ),
                          Container(
                            height: 50,
                            margin: EdgeInsets.only(left: 10.0, right: 10.0),
                            child: Text('Pemblokiran akses internet ke situs yang mana secara legal'
                                ' mempromosikan obat-obatan, rokok, senjata, produk alkohol dan asesorisnya.'
                                ' Termasuk informasi tentang aborsi.'),
                          )
                        ]),
                      ),
                      Container(
                        height: 150,
                        margin: EdgeInsets.only(top: 10.0, bottom: 5.0),
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey,
                              blurRadius: 3.0,
                            ),
                          ],
                        ),
                        child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Container(
                            margin: EdgeInsets.all(10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  child: Text(
                                    'Kencan/Perjudian',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                                Container(
                                  child: CupertinoSwitch(
                                    value: _switchValueKencan,
                                    onChanged: (value) {
                                      setState(() {
                                        _switchValueKencan = value;
                                      });
                                    },
                                  ),
                                )
                              ],
                            ),
                          ),
                          Container(
                            height: 50,
                            margin: EdgeInsets.only(left: 10.0, right: 10.0),
                            child: Text('Pemblokiran akses internet ke situs yang memfasilitasi untuk '
                                'melakukan kontak dengan orang lain dengan tujuan membangun '
                                'hubungan personal, romantik atau hubungan sexual. Termasuk '
                                'memblokir akses ke situs perjudian seperti perjudian, lotere, kasino.'),
                          )
                        ]),
                      ),
                      Container(
                        height: 150,
                        margin: EdgeInsets.only(top: 10.0, bottom: 5.0),
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey,
                              blurRadius: 3.0,
                            ),
                          ],
                        ),
                        child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Container(
                            margin: EdgeInsets.all(10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  child: Text(
                                    'Radikalisme',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                                Container(
                                  child: CupertinoSwitch(
                                    value: _switchValueKencan,
                                    onChanged: (value) {
                                      setState(() {
                                        _switchValueKencan = value;
                                      });
                                    },
                                  ),
                                )
                              ],
                            ),
                          ),
                          Container(
                            height: 50,
                            margin: EdgeInsets.only(left: 10.0, right: 10.0),
                            child: Text('Pemblokiran akses internet ke situs yang memfasilitasi untuk '
                                'melakukan kontak dengan orang lain dengan tujuan membangun '
                                'hubungan personal, romantik atau hubungan sexual. Termasuk '
                                'memblokir akses ke situs perjudian seperti perjudian, lotere, kasino.'),
                          )
                        ]),
                      ),
                    ]),
                  ),
                ),
              )
            ],
          ),
        ));
  }
}
