import 'package:flutter/material.dart';
import 'package:ruangkeluarga/global/global.dart';

class DetailContentRKView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kontrol dan Konfigurasi',
      theme: ThemeData(primaryColor: Colors.white70),
      home: DetailContentRKPage(title: 'Detil Kontent'),
    );
  }
}

class DetailContentRKPage extends StatefulWidget {
  @override
  _DetailContentRKPageState createState() => _DetailContentRKPageState();
  final String title;
  DetailContentRKPage({Key? key, required this.title}) : super(key: key);
}

class _DetailContentRKPageState extends State<DetailContentRKPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: TextStyle(color: cOrtuWhite)),
        backgroundColor: cTopBg,
        iconTheme: IconThemeData(color: Colors.grey.shade700),
      ),
      backgroundColor: Colors.grey[200],
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 200,
            child: Image.asset(
              'assets/images/digital_parenting_one.png',
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.fill,
            ),
          ),
          Flexible(
            child: Container(
              width: MediaQuery.of(context).size.width,
              color: Colors.white,
              child: SingleChildScrollView(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(
                        top: 20.0, left: 10.0, right: 10.0, bottom: 10.0),
                    child: Text(
                      '7 Step to Good Digital Parenting',
                      style: TextStyle(fontSize: 20, color: Colors.black),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(10.0),
                    child: Text(
                      'Tujuh langkah sederhana, namun tetap menantang untuk menjadi orangtua digital yang baik. Ini jelas sebuah perjalanan, seperti mengasuh anak itu sendiri. Tidak ada yang namanya kesempurnaan. Cukup baik.\n\n'
                      '1. Bicaralah Dengan Anak Anda\nBicara lebih awal dan sering Terbuka dan langsung Tetap tenang\n'
                      '2. Mendidik Diri Sendiri\nCari secara online untuk apa pun yang tidak Anda pahami Cobalah sendiri aplikasi, game, dan situs Jelajahi kiat dan sumber daya pengasuhan FOSI\n\n'
                      '3. Gunakan Kontrol Orang Tua\nTetapkan konten dan batas waktu di perangkat anak-anak Anda Secara rutin periksa pengaturan privasi di media sosial Pantau penggunaan anak-anak Anda dan waktu layar mereka\n\n'
                      '4. Tetapkan Aturan Dasar dan Terapkan Konsekuensi\nDiskusikan dan tandatangani perjanjian keselamatan keluarga Batasi di mana dan kapan perangkat dapat digunakan Hapus hak istimewa teknologi saat aturan dilanggar\n\n'
                      '5. Teman dan Ikuti Tapi Jangan Menguntit\nIkuti anak-anak Anda di media sosial Hormati ruang dan kebebasan online mereka Jangan membanjiri akun mereka dengan komentar\n\n'
                      '6. Jelajahi, Bagikan, dan Rayakan\nOnline dengan anak-anak Anda dan jelajahi dunia digital merekaBagikan pengalaman online Anda sendiri Belajar dari satu sama lain dan bersenang-senang\n\n'
                      '7. Jadilah Model Peran Digital yang Baik\nBatasi kebiasaan buruk Anda sendiri. Ketahui kapan dan di mana harus mencabut kabel. Tunjukkan pada anak Anda cara berkolaborasi dan bersikap baik secara online',
                      style: TextStyle(fontSize: 14, color: Colors.black),
                    ),
                  )
                ],
              )),
            ),
          )
        ],
      ),
    );
  }
}
