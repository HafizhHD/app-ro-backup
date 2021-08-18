import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ruangkeluarga/global/global.dart';
import 'package:ruangkeluarga/login/splash_info_1.dart';
import 'package:ruangkeluarga/login/splash_info_3.dart';

class SplashInfo2 extends StatelessWidget {
  final borderRadiusSize = Radius.circular(10);
  final assetImg = AssetImage('assets/images/unsplash-parenting.jpg');

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
                    child: Hero(
                      tag: 'carousel',
                      child: Container(
                        margin: EdgeInsets.only(right: 20),
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: cOrtuWhite,
                            borderRadius: BorderRadius.only(bottomRight: borderRadiusSize, topRight: borderRadiusSize),
                            image: DecorationImage(
                              image: assetImg,
                              fit: BoxFit.cover,
                            )),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Bimbing mereka ke konten yang bagus \ndan berikan asupan keingintahuan mereka',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      color: cOrtuWhite,
                    ),
                  ),
                ],
              ),
            ),
            linearProgressBar(0.50),
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
                    onPressed: () => Navigator.of(context).push(leftTransitionRoute(SplashInfo3())),
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
