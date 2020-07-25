import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:keptoon/models/user.dart';
import 'package:keptoon/screens/main/sub/postScreen.dart';
import 'package:keptoon/utils/pallete.dart';
import 'package:keptoon/utils/postMedia/postGallery.dart';
import 'package:permission_handler/permission_handler.dart';

class PostPicker extends StatefulWidget {
  final String postType;
  final User currentUser;
  final bool isFromPost;
  PostPicker({this.postType, this.isFromPost, this.currentUser, Key key})
      : super(key: key);

  @override
  _PostPickerState createState() => _PostPickerState();
}

class _PostPickerState extends State<PostPicker> {
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    // var orientation = MediaQuery.of(context).orientation;

    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        brightness: Brightness.light,
        backgroundColor: Colors.transparent,
        title: Text("Device gallery",
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
            )),
        elevation: 0.0,
        leading: IconButton(
            icon: Image.asset(
              'assets/icons/left-arrow.png',
              width: width * 0.07,
              height: height * 0.07,
            ),
            onPressed: () {
              Navigator.pop(context);
            }),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(
              right: 10,
            ),
            child: IconButton(
                icon: Image.asset(
                  'assets/icons/camera.png',
                  width: width * 0.08,
                  height: height * 0.08,
                ),
                onPressed: () async {
                  var status = await Permission.camera.status;
                  if (status.isUndetermined) {
                    var statusRe = await Permission.camera.request();

                    if (statusRe.isGranted) {
                      final pickedFile = await ImagePicker().getImage(
                        source: ImageSource.camera,
                      );
                      if (pickedFile != null) {
                        var obj = {
                          "mediaFile": pickedFile,
                          "type": "camPhoto",
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
                    }
                  }

                  if (status.isGranted) {
                    final pickedFile = await ImagePicker().getImage(
                      source: ImageSource.camera,
                    );
                    if (pickedFile != null) {
                      var obj = {
                        "mediaFile": pickedFile,
                        "type": "camPhoto",
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
                  } else {
                    var statusRe2 = await Permission.camera.request();
                    if (statusRe2.isGranted) {
                      final pickedFile = await ImagePicker().getImage(
                        source: ImageSource.camera,
                      );
                      if (pickedFile != null) {
                        var obj = {
                          "mediaFile": pickedFile,
                          "type": "camPhoto",
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
                    }
                  }
                }),
          ),
          Padding(
            padding: const EdgeInsets.only(
              right: 10,
            ),
            child: IconButton(
                icon: Image.asset(
                  'assets/icons/video-camera.png',
                  width: width * 0.08,
                  height: height * 0.08,
                ),
                onPressed: () async {
                  var statuscam = await Permission.camera.status;
                  var statusmi = await Permission.microphone.status;

                  if (statuscam.isUndetermined && statusmi.isUndetermined) {
                    var statusReCam = await Permission.camera.request();
                    var statusReMi = await Permission.microphone.request();
                    if (statusReMi.isGranted && statusReCam.isGranted) {
                      final pickedFile = await ImagePicker().getVideo(
                          source: ImageSource.camera,
                          maxDuration: Duration(
                            minutes: 5,
                          ));
                      if (pickedFile != null) {
                        var obj = {
                          "mediaFile": pickedFile,
                          "type": "camVideo",
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
                    }
                  }

                  if (statusmi.isGranted && statuscam.isGranted) {
                    final pickedFile = await ImagePicker().getVideo(
                      source: ImageSource.camera,
                    );
                    if (pickedFile != null) {
                      var obj = {
                        "mediaFile": pickedFile,
                        "type": "camVideo",
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
                  } else {
                    var statusRe2Cam = await Permission.camera.request();
                    var statusRe2Mi = await Permission.microphone.request();
                    if (statusRe2Mi.isGranted && statusRe2Cam.isGranted) {
                      final pickedFile = await ImagePicker().getVideo(
                        source: ImageSource.camera,
                      );
                      if (pickedFile != null) {
                        var obj = {
                          "mediaFile": pickedFile,
                          "type": "camVideo",
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
                    }
                  }
                }),
          )
        ],
      ),
      backgroundColor: Palette.backgroundColor,
      body: PostGallery(
        postType: widget.postType,
        currentUser: widget.currentUser,
        isFromPost: widget.isFromPost,
      ),
    );
  }
}
