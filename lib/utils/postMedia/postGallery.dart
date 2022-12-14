import 'dart:typed_data';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:keptoon/models/user.dart';
import 'package:keptoon/screens/main/sub/postScreen.dart';
import 'package:keptoon/utils/pallete.dart';
import 'package:keptoon/utils/progress.dart';
import 'package:keptoon/utils/shimmers/gallery_shimmer.dart';
import 'package:photo_manager/photo_manager.dart';

class PostGallery extends StatefulWidget {
  final String postType;
  final User currentUser;
  final bool isFromPost;
  PostGallery({this.postType, this.isFromPost, this.currentUser, Key key})
      : super(key: key);

  @override
  _PostGalleryState createState() => _PostGalleryState();
}

class _PostGalleryState extends State<PostGallery> {
  List<int> selectedIndex = [];
  List<AssetEntity> selectedMedia = [];
  bool isLoading = true;
  List<Uint8List> allFiles = [];
  List<AssetEntity> mediaEn = [];

  @override
  void initState() {
    super.initState();
    getPermission();
  }

  getAllItems() async {
    List<AssetPathEntity> list = await PhotoManager.getAssetPathList(
      hasAll: true,
      onlyAll: true,
    );
    list.forEach((assetPath) async {
      List<AssetEntity> assetList = await assetPath.assetList;
      assetList.forEach((element) {
        element.thumbDataWithSize(250, 250).then((value) {
          if (!mounted) {
            return;
          }
          setState(() {
            mediaEn.add(element);
            allFiles.add(value);
            isLoading = false;
          });
        });
      });
    });
  }

  getPermission() async {
    bool result = await PhotoManager.requestPermission();
    if (result) {
      await getAllItems();
    } else {
      AwesomeDialog(
        context: context,
        animType: AnimType.SCALE,
        dialogType: DialogType.NO_HEADER,
        body: Center(
          child: Text(
            'Problem with your permissions!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
            ),
          ),
        ),
        btnOkText: 'Goto app settings',
        btnCancelText: 'Cancel',
        btnOkColor: Palette.mainAppColor,
        btnCancelColor: Palette.mainAppColor,
        btnOkOnPress: () {
          PhotoManager.openSetting();
          if (!mounted) {
            return;
          }
          setState(() {
            isLoading = false;
          });
        },
        btnCancelOnPress: () {
          Navigator.pop(context);
        },
      )..show();
    }
  }

  String _printDuration(Duration duration) {
    String twoDigits(int n) {
      if (n >= 10) return "$n";
      return "0$n";
    }

    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: isLoading
          ? shimmerEffectLoadingGallery(context)
          : Column(children: <Widget>[
              SizedBox(
                height: 20,
              ),
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.only(
                  left: 8,
                  right: 8,
                ),
                child: GridView.builder(
                    itemCount: allFiles.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 1,
                      mainAxisSpacing: 1,
                    ),
                    itemBuilder: (BuildContext context, int index2) {
                      return GestureDetector(
                          onTap: () {
                            if (selectedIndex.contains(index2)) {
                              setState(() {
                                selectedIndex.remove(index2);
                                selectedMedia.remove(mediaEn[index2]);
                              });
                            } else {
                              setState(() {
                                selectedIndex.add(index2);
                                selectedMedia.add(mediaEn[index2]);
                              });
                            }
                          },
                          child: Stack(
                            children: <Widget>[
                              mediaEn[index2] == null
                                  ? rockProgress()
                                  : Stack(
                                      children: <Widget>[
                                        Positioned.fill(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Colors.black38,
                                                width: 0,
                                              ),
                                              image: DecorationImage(
                                                image: MemoryImage(
                                                    allFiles[index2]),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        ),
                                        if (mediaEn[index2].type ==
                                            AssetType.video)
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 5),
                                            child: Align(
                                              alignment: Alignment.bottomLeft,
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                                    right: 5, bottom: 5),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                      color: Colors.black
                                                          .withOpacity(0.8),
                                                      border: Border.all(
                                                        color: Colors.black,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  10))),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Text(
                                                      _printDuration(
                                                        Duration(
                                                            seconds:
                                                                mediaEn[index2]
                                                                    .duration),
                                                      ),
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                              selectedIndex.contains(index2)
                                  ? Container(
                                      child: Center(
                                          child: Container(
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                              width: 2,
                                              color: Colors.white,
                                            ),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(20))),
                                        child: Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 30,
                                        ),
                                      )),
                                      decoration: BoxDecoration(
                                          color: Palette.mainAppColor
                                              .withOpacity(0.6),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10))))
                                  : SizedBox.shrink(),
                            ],
                          ));
                    }),
              )),
            ]),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(top: height * 0.35),
        child: Column(
          children: <Widget>[
            FloatingActionButton(
              onPressed: () {},
              heroTag: "selectedCountTag",
              backgroundColor: Palette.mainAppColor,
              elevation: 10.0,
              child: Text(
                selectedIndex.length.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            FloatingActionButton(
              onPressed: () {
                if (selectedMedia.isNotEmpty) {
                  var obj = {
                    "mediaList": selectedMedia,
                    "type": "gallery",
                  };

                  if (widget.isFromPost) {
                    Navigator.pop(context, obj);
                  } else {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PostScreen(
                                  object: obj,
                                  postType: widget.postType,
                                  current: widget.currentUser,
                                  fromTrimmer: false,
                                )));
                  }
                }
              },
              heroTag: "continueTag",
              backgroundColor: Palette.mainAppColor,
              elevation: 10.0,
              child: Image.asset(
                'assets/icons/done.png',
                color: Colors.white,
                width: width * 0.07,
                height: height * 0.07,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
