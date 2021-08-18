import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ruangkeluarga/global/global.dart';
import 'package:ruangkeluarga/login/splash_info_1.dart';
import 'package:ruangkeluarga/login/splash_info_4.dart';

class SplashInfo3 extends StatelessWidget {
  final borderRadiusSize = Radius.circular(10);
  final assetImg = AssetImage('assets/images/unsplash-reward.jpg');

  @override
  Widget build(BuildContext context) {
    precacheImage(assetImg, context);

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
                  Flexible(
                    child: Container(
                      margin: EdgeInsets.all(20),
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: cOrtuWhite,
                          borderRadius: BorderRadius.all(borderRadiusSize),
                          image: DecorationImage(
                            image: assetImg,
                            fit: BoxFit.cover,
                          )),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'dan memenangkan \nhadiah menarik \nuntuk keluarga Anda',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      color: cOrtuWhite,
                    ),
                  ),
                ],
              ),
            ),
            linearProgressBar(0.75),
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
                    onPressed: () => Navigator.of(context).push(leftTransitionRoute(SplashInfo4())),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
