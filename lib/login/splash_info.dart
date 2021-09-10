import 'package:flutter/material.dart';
import 'package:ruangkeluarga/global/global.dart';
import 'package:ruangkeluarga/login/login.dart';
import 'package:ruangkeluarga/login/splash_info_1.dart';

class SplashInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        color: cPrimaryBg,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(height: 50),
            Flexible(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Hero(tag: 'ruangortuIcon', child: Image.asset(currentAppIconPath)),
                  // Text(
                  //   'Ruang Ortu',
                  //   style: TextStyle(
                  //     fontSize: 50,
                  //     fontWeight: FontWeight.bold,
                  //     color: ortuBlue,
                  //   ),
                  // ),
                  SizedBox(height: 20),
                  Text(
                    'Aplikasi Untuk Keluarga HKBP',
                    style: TextStyle(
                      fontSize: 20,
                      color: cOrtuWhite,
                    ),
                  ),
                ],
              ),
            ),
            Hero(
              tag: 'next_info',
              child: Material(
                color: Colors.transparent,
                child: Container(
                  margin: EdgeInsets.all(10).copyWith(bottom: 50),
                  child: IconButton(
                    iconSize: 50,
                    icon: Container(
                      decoration: BoxDecoration(color: cAccentButton, shape: BoxShape.circle),
                      child: Icon(Icons.arrow_forward_rounded, color: cPrimaryBg),
                    ),
                    onPressed: () => Navigator.of(context).push(leftTransitionRoute(SplashInfo1())),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

// Widget oldPolicy(BuildContext context) {
//   return Scaffold(
//     body: Container(
//       margin: const EdgeInsets.only(left: 20.0, right: 20.0, top: 50.0),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           Container(
//             height: 80,
//             child: Align(
//               alignment: Alignment.topCenter,
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 //mainAxisSize: MainAxisSize.max,
//                 children: <Widget>[
//                   Text(
//                     "ruang",
//                     textAlign: TextAlign.left,
//                     style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 30),
//                   ),
//                   Text(
//                     " keluarga",
//                     textDirection: TextDirection.ltr,
//                     textAlign: TextAlign.left,
//                     style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xffFF018786), fontSize: 30),
//                   )
//                 ],
//               ),
//             ),
//           ),
//           Container(
//             child: Container(
//               height: 300,
//               decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(10),
//                   gradient: LinearGradient(
//                     begin: Alignment.topCenter,
//                     end: Alignment.bottomCenter,
//                     colors: [
//                       Color(0xff3BDFD2),
//                       Color(0xff05745F),
//                     ],
//                   )),
//               child: Column(
//                 children: [
//                   Container(
//                     margin: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
//                     child: Align(
//                       alignment: Alignment.centerLeft,
//                       child: Text(
//                         'Izin Akses Data Perangkat',
//                         style: TextStyle(color: Colors.white),
//                       ),
//                     ),
//                   ),
//                   Container(
//                     margin: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
//                     child: Align(
//                       alignment: Alignment.centerLeft,
//                       child: Text(
//                         'Untuk dapat menggunakan layanan ruang keluarga, kami memerlukan izin untuk mengakses data google anda untuk verifikasi.',
//                         style: TextStyle(color: Colors.white),
//                       ),
//                     ),
//                   ),
//                   Column(
//                     children: [
//                       Container(
//                         margin: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
//                         width: MediaQuery.of(context).size.width,
//                         child: FlatButton(
//                           shape: new RoundedRectangleBorder(
//                             borderRadius: new BorderRadius.circular(10.0),
//                           ),
//                           onPressed: () {},
//                           color: Colors.white,
//                           child: Text(
//                             "Baca Kebijakan Privasi",
//                             style: TextStyle(
//                               color: Colors.grey,
//                               fontFamily: 'Raleway',
//                               fontSize: 14.0,
//                             ),
//                           ),
//                         ),
//                       ),
//                       Container(
//                         margin: const EdgeInsets.only(left: 20.0, right: 20.0),
//                         width: MediaQuery.of(context).size.width,
//                         child: FlatButton(
//                           shape: new RoundedRectangleBorder(
//                             borderRadius: new BorderRadius.circular(10.0),
//                           ),
//                           onPressed: () {
//                             Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LoginPage()));
//                             // Navigator.of(context).pushReplacement(MaterialPageRoute(
//                             //     builder: (context) => SetupPermissionChildPage(title: 'Setup Permission',)));
//                           },
//                           color: Colors.white,
//                           child: Text(
//                             "Setuju",
//                             style: TextStyle(
//                               color: Colors.grey,
//                               fontFamily: 'Raleway',
//                               fontSize: 14.0,
//                             ),
//                           ),
//                         ),
//                       ),
//                       Container(
//                         margin: const EdgeInsets.only(left: 20.0, right: 20.0),
//                         width: MediaQuery.of(context).size.width,
//                         child: FlatButton(
//                           shape: new RoundedRectangleBorder(
//                             borderRadius: new BorderRadius.circular(10.0),
//                           ),
//                           onPressed: () {},
//                           color: Colors.white,
//                           child: Text(
//                             "Tolak",
//                             style: TextStyle(
//                               color: Colors.grey,
//                               fontFamily: 'Raleway',
//                               fontSize: 14.0,
//                             ),
//                           ),
//                         ),
//                       )
//                     ],
//                   )
//                 ],
//               ),
//             ),
//           )
//         ],
//       ),
//     ),
//   );
// }
