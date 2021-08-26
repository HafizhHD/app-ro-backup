import 'package:flutter/material.dart';
import 'package:ruangkeluarga/global/global.dart';

class AddonPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: cPrimaryBg,
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(10),
              child: WSearchBar(
                hintText: 'Search Addon',
                fOnChanged: (text) {},
              ),
            ),
            Flexible(
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: 5,
                  itemBuilder: (ctx, k) {
                    return Container(
                      margin: EdgeInsets.all(10),
                      child: AddonCard(
                        imagePath: 'unsplash-digital-habit.jpg',
                        title: 'Item no $k',
                        onTapInfo: () {},
                        onTapJoin: () {},
                      ),
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }
}

class AddonCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final Function()? onTapInfo;
  final Function()? onTapJoin;

  AddonCard({
    required this.imagePath,
    required this.title,
    required this.onTapInfo,
    required this.onTapJoin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      key: Key(title),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
        image: DecorationImage(
          image: AssetImage('assets/images/$imagePath'),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(height: 100),
          Container(
            padding: EdgeInsets.only(top: 5, left: 20, right: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.0),
              color: Colors.black54,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '$title',
                  style: TextStyle(fontWeight: FontWeight.bold, color: cOrtuWhite),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Flexible(
                  child: IconButton(
                    icon: Icon(
                      Icons.info_outline,
                      color: cOrtuWhite,
                    ),
                    onPressed: onTapInfo,
                  ),
                ),
                ElevatedButton(
                  child: Text('Gabung'),
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all((RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(50)),
                    ))),
                    elevation: MaterialStateProperty.resolveWith((states) {
                      if (states.contains(MaterialState.pressed)) return 0;
                      if (states.contains(MaterialState.hovered)) return 6;
                      return 4;
                    }),
                    backgroundColor: MaterialStateProperty.all(cAccentButton),
                    foregroundColor: MaterialStateProperty.all(cPrimaryBg),
                  ),
                  onPressed: onTapJoin,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
