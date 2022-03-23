import 'package:flutter/material.dart';
// import 'package:get/get.dart';
import 'package:ruangkeluarga/global/global.dart';
import 'package:ruangkeluarga/login/login.dart';
// import 'package:ruangkeluarga/login/setup_permissions.dart';
import 'package:ruangkeluarga/login/splash_info_1.dart';

class SplashInfo4 extends StatelessWidget {
  final borderRadiusSize = Radius.circular(10);
  final assetImg = AssetImage('assets/images/Intro4_p.png');

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
                child: Hero(
                  tag: 'carousel',
                  child: Container(
                    constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height / 1.8),
                    margin: EdgeInsets.all(20),
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: cOrtuBlack,
                        borderRadius: BorderRadius.all(borderRadiusSize),
                        image: DecorationImage(
                          image: assetImg,
                          fit: BoxFit.cover,
                        )),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.all(10),
                child: Text(
                  // 'melalui konten yang sehat \nmembangun keluarga',
                  'Mulailah mengawasi dan mengontrol gadget anak',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    color: cOrtuBlack,
                  ),
                ),
              ),
              linearProgressBar(1),
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
                            color: cAccentButton, shape: BoxShape.circle),
                        child: Icon(Icons.arrow_forward_rounded,
                            color: cPrimaryBg),
                      ),
                      onPressed: () => Navigator.of(context)
                          .push(leftTransitionRoute(LoginPage())),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
