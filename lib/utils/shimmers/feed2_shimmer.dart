import 'package:animator/animator.dart';
import 'package:content_placeholder/content_placeholder.dart';
import 'package:flutter/material.dart';

feed2Shimmer(BuildContext context) {
  double width = MediaQuery.of(context).size.width;
  double height = MediaQuery.of(context).size.height;
  return SingleChildScrollView(
    child: Padding(
      padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
      child: Animator(
        duration: Duration(milliseconds: 1000),
        tween: Tween(begin: 0.95, end: 1.0),
        curve: Curves.easeInCirc,
        cycles: 0,
        builder: (anim) => Transform.scale(
            scale: anim.value,
            child: ContentPlaceholder(
              bgColor: Color(0xffe0e0e0),
              borderRadius: 30.0,
              highlightColor: Colors.grey[200],
              context: context,
              child: Column(children: <Widget>[
                SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Center(
                      child: ContentPlaceholder.block(
                          width: width * 0.4,
                          height: height * 0.3,
                          borderRadius: 15),
                    ),
                    Center(
                      child: ContentPlaceholder.block(
                          width: width * 0.4,
                          height: height * 0.3,
                          borderRadius: 15),
                    ),
                  ],
                ),
                SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Center(
                      child: ContentPlaceholder.block(
                          width: width * 0.4,
                          height: height * 0.3,
                          borderRadius: 15),
                    ),
                    Center(
                      child: ContentPlaceholder.block(
                          width: width * 0.4,
                          height: height * 0.3,
                          borderRadius: 15),
                    ),
                  ],
                ),
              ]),
            )),
      ),
    ),
  );
}
