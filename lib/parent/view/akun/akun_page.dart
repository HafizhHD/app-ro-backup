import 'package:flutter/material.dart';
import 'package:ruangkeluarga/global/global.dart';

class AkunPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      // color: ,
      padding: EdgeInsets.all(5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          profileContainer(imgUrl: 'assets/images/unsplash-reward.jpg', name: 'Nama Ayah', email: 'email@ayah.com', phone: '08180818080'),
          profileContainer(imgUrl: 'assets/images/foto_anak.png', name: 'Nama Anak', email: 'email@anak.com'),
          profileContainer(imgUrl: null, name: 'Nama Anak', email: 'email@anak.com', phone: '09019019'),
        ],
      ),
    );
  }

  // 'assets/images/foto_anak.png'
  Widget profileContainer({
    String? imgUrl,
    required String name,
    required String email,
    String? phone,
  }) {
    return Container(
      margin: EdgeInsets.all(10),
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
                  maxWidth: 150,
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
                            image: DecorationImage(image: AssetImage(imgUrl), fit: BoxFit.cover),
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
                        style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Text(
                        '$email',
                        style: TextStyle(fontSize: 20),
                      ),
                      SizedBox(height: 10),
                      if (phone != null)
                        Text(
                          '$phone',
                          style: TextStyle(fontSize: 20),
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
    );
  }
}
