import 'package:flutter/material.dart';
import 'package:ruangkeluarga/global/global.dart';

class AddonPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: cPrimaryBg,
      child: SafeArea(
        child: Column(
          // SearchBar(),
          children: [
            Text('Addon Page'),
            ListView.builder(
                itemCount: 5,
                itemBuilder: (ctx, k) {
                  return Container(
                    child: AddonCard(
                      imagePath: 'unsplash-digital-habit.jpg',
                      title: 'Item no $k',
                      onTapInfo: () {},
                      onTapJoin: () {},
                    ),
                  );
                }),
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
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        image: DecorationImage(
          image: AssetImage('assets/images/$imagePath'),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(height: 100),
          Flexible(
            child: Container(
              padding: EdgeInsets.all(10).copyWith(bottom: 0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                color: Colors.black38,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                      icon: Icon(Icons.info_outline),
                      onPressed: onTapInfo,
                    ),
                  ),
                  ElevatedButton(onPressed: onTapJoin, child: Text('Gabung'))
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
