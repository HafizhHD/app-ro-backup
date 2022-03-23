import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ruangkeluarga/global/global.dart';
import 'package:ruangkeluarga/login/splash_info_2.dart';

class SplashInfo1 extends StatelessWidget {
  final borderRadiusSize = Radius.circular(10);
  // final assetImg = AssetImage('assets/images/unsplash-digital-habit.jpg');
  final assetImg = AssetImage('assets/images/Intro1_p.png');

  @override
  Widget build(BuildContext context) {
    precacheImage(assetImg, context);
    return SafeArea(
      child: Material(
        child: Container(
          color: cPrimaryBg,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Hero(
                        tag: 'carousel',
                        child: Container(
                          constraints: BoxConstraints(
                              maxHeight:
                                  MediaQuery.of(context).size.height / 1.8),
                          margin: EdgeInsets.all(20),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: cOrtuBlack,
                            borderRadius: BorderRadius.all(borderRadiusSize),
                            image: DecorationImage(
                              image: assetImg,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      // 'Bantu keluarga Anda \nmenciptakan kebiasaan digital \nyang sehat',
                      'Membantu keluarga dalam \nmemberi pola asuh di era \ndigital ini',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        color: cOrtuBlack,
                      ),
                    ),
                  ],
                ),
              ),
              linearProgressBar(0.25),
              Hero(
                tag: 'next_info',
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    margin: EdgeInsets.all(10).copyWith(bottom: 50),
                    child: IconButton(
                      iconSize: 50,
                      icon: Container(
                        decoration: BoxDecoration(
                            color: cOrtuOrange, shape: BoxShape.circle),
                        child: Icon(Icons.arrow_forward_rounded,
                            color: cPrimaryBg),
                      ),
                      onPressed: () => Navigator.of(context)
                          .push(leftTransitionRoute(SplashInfo2())),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

Widget linearProgressBar(double value) {
  return Container(
    padding: EdgeInsets.all(30),
    width: Get.width / 2,
    child: Hero(
      tag: 'info_progress',
      child: LinearProgressIndicator(
        value: value,
        backgroundColor: cOrtuBlack,
        color: cOrtuBlue,
      ),
    ),
  );
}
