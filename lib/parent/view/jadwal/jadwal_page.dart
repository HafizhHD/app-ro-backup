import 'package:flutter/material.dart';
import 'package:ruangkeluarga/global/global.dart';

class JadwalPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Flexible(
                  child: Container(
                    padding: EdgeInsets.all(5),
                    child: ListTile(
                      tileColor: cOrtuBlue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      title: Align(alignment: Alignment.centerLeft, child: Icon(Icons.calendar_today_outlined)),
                      subtitle: Text('Hari ini'),
                      trailing: Text(
                        '2',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                ),
                Flexible(
                  child: Container(
                    padding: EdgeInsets.all(5),
                    child: ListTile(
                      tileColor: cOrtuWhite,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      title: Align(alignment: Alignment.centerLeft, child: Icon(Icons.calendar_today_outlined)),
                      subtitle: Text('Terjadwal'),
                      trailing: Text(
                        '3',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Seluruh Keluarga',
                    style: TextStyle(color: cOrtuWhite),
                  ),
                  Icon(Icons.keyboard_arrow_down, color: cOrtuWhite),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: cOrtuWhite,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tambah Jadwal',
                  ),
                  Icon(Icons.add, color: cPrimaryBg),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 20, bottom: 10),
              child: ListTile(
                tileColor: cOrtuBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                leading: Icon(Icons.circle),
                title: Text('Belajar Online HKBP'),
                subtitle: Text('HKB PGO'),
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 10, bottom: 10),
              child: ListTile(
                tileColor: cOrtuWhite,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                leading: Icon(Icons.circle),
                title: Text('Menyapu Taman'),
                subtitle: Text('Tugas Harian'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
