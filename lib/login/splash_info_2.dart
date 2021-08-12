import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ruangkeluarga/global/global.dart';
import 'package:ruangkeluarga/login/splash_info_3.dart';

class SplashInfo2 extends StatelessWidget {
  final borderRadiusSize = Radius.circular(10);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        color: primaryBg,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(height: 100),
            Flexible(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Container(
                      margin: EdgeInsets.only(right: 20),
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: ortuWhite,
                          borderRadius: BorderRadius.only(bottomRight: borderRadiusSize, topRight: borderRadiusSize),
                          image: DecorationImage(
                            image: AssetImage('assets/images/digital_parenting_one.png'),
                            fit: BoxFit.cover,
                          )),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Bimbing merekake konten yang bagus dan berikan asupan keingintahuan mereka',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      color: ortuBlue,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(20),
              width: Get.width / 2,
              child: Hero(
                tag: 'info_progress',
                child: LinearProgressIndicator(
                  value: 0.25,
                  backgroundColor: ortuWhite,
                  color: ortuBlue,
                ),
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
                      decoration: BoxDecoration(color: ortuBlue, shape: BoxShape.circle),
                      child: Icon(Icons.arrow_forward_rounded, color: primaryBg),
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
