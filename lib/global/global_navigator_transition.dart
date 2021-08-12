import 'package:flutter/material.dart';

Route leftTransitionRoute(Widget newPage) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => newPage,
    transitionDuration: Duration(milliseconds: 500),
    transitionsBuilder: (context, animation, anotherAnimation, child) {
      animation = CurvedAnimation(curve: Curves.ease, parent: animation);
      return SlideTransition(
        position: Tween(begin: Offset(1.0, 0.0), end: Offset(0.0, 0.0)).animate(animation),
        child: SafeArea(top: false, child: child),
      );
    },
  );
}
