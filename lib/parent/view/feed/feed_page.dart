import 'package:flutter/material.dart';
import 'package:ruangkeluarga/global/global.dart';
import 'package:ruangkeluarga/parent/view/addon/addon_page.dart';

class FeedPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            constraints: BoxConstraints(
              maxHeight: screenSize.height / 6,
              maxWidth: screenSize.width - 20,
            ),
            child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: 10,
              itemBuilder: (context, index) {
                return roundAddonAvatar(imgUrl: 'assets/images/hkbpgo.png', addonName: 'HKBP GO $index');
              },
            ),
          ),
          Container(
            padding: EdgeInsets.only(top: 10, bottom: 10),
            child: WSearchBar(
              hintText: 'Search Addon',
              fOnChanged: (text) {},
            ),
          ),
          Flexible(
            flex: 4,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: 10,
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.only(top: 10, bottom: 10),
                  height: 100,
                  decoration: BoxDecoration(
                    color: cOrtuGrey,
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Center(
                    child: Text(
                      'Index ke $index',
                      style: TextStyle(fontSize: 40),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget roundAddonAvatar({
    required String imgUrl,
    required String addonName,
  }) {
    return Container(
      margin: EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: AssetImage('$imgUrl'),
          ),
          Padding(
            padding: EdgeInsets.only(top: 10),
            child: Text(
              '$addonName',
              style: TextStyle(color: cOrtuWhite),
            ),
          )
        ],
      ),
    );
  }
}
