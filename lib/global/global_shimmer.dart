import 'package:flutter/material.dart';
import 'package:ruangkeluarga/global/global.dart';
import 'package:shimmer/shimmer.dart';

Widget shimmerMultipleContainer({int pItemCount = 1, double pHeight = 150, String timeoutText = 'Timeout! Failed to load data'}) {
  return FutureBuilder(
      future: Future.delayed(Duration(seconds: 10)),
      builder: (c, s) {
        if (s.connectionState == ConnectionState.done) {
          return Container(
            margin: EdgeInsets.only(top: 5, bottom: 5),
            padding: EdgeInsets.only(top: 5, bottom: 5),
            decoration: BoxDecoration(border: Border.all(color: cPrimaryBg), borderRadius: BorderRadius.circular(15)),
            child: Center(
              child: Text(
                timeoutText,
                style: TextStyle(color: Colors.red),
              ),
            ),
          );
        }
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: pItemCount,
            itemBuilder: (context, index) {
              return Card(
                  child: Container(
                height: pHeight,
              ));
            },
          ),
        );
      });
}

Widget shimmerUserCard({int pItemCount = 1, double pHeight = 150}) {
  return Shimmer.fromColors(
    baseColor: Colors.grey.shade400,
    highlightColor: Colors.grey.shade100,
    child: ListView.builder(
      shrinkWrap: true,
      itemCount: pItemCount,
      itemBuilder: (context, index) {
        return Card(
            child: Container(
          height: pHeight,
        ));
      },
    ),
  );
}
