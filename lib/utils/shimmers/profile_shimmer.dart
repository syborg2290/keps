import 'package:animator/animator.dart';
import 'package:content_placeholder/content_placeholder.dart';
import 'package:flutter/material.dart';

profileShimmer(BuildContext context) {
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
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: Colors.white,
                            width: 10,
                          ),
                          borderRadius: BorderRadius.circular(100.0)),
                      child: ContentPlaceholder.block(
                          width: width * 0.33,
                          height: height * 0.18,
                          rightSpacing: 11,
                          leftSpacing: 11,
                          borderRadius: 80),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                ContentPlaceholder.block(
                    width: width * 0.6,
                    height: height * 0.04,
                    borderRadius: 15),
                ContentPlaceholder.block(
                    width: width * 0.65,
                    height: height * 0.08,
                    borderRadius: 15),
                SizedBox(
                  height: 20,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    ContentPlaceholder.block(
                        width: width * 0.2,
                        height: height * 0.08,
                        borderRadius: 15),
                    ContentPlaceholder.block(
                        width: width * 0.2,
                        height: height * 0.08,
                        borderRadius: 15),
                    ContentPlaceholder.block(
                        width: width * 0.2,
                        height: height * 0.08,
                        borderRadius: 15),
                  ],
                ),
                SizedBox(
                  height: 30,
                ),
                Center(
                  child: ContentPlaceholder.block(
                      width: width * 0.9,
                      height: height * 0.3,
                      borderRadius: 15),
                ),
              ]),
            )),
      ),
    ),
  );
}
