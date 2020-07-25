import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:keptoon/utils/pallete.dart';
import 'package:keptoon/utils/profileMedia/profileGallery.dart';
import 'package:permission_handler/permission_handler.dart';

class ProfileImagePicker extends StatefulWidget {
  ProfileImagePicker({Key key}) : super(key: key);

  @override
  _ProfileImagePickerState createState() => _ProfileImagePickerState();
}

class _ProfileImagePickerState extends State<ProfileImagePicker> {
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
        title: Text("Select a profile",
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
                        Navigator.pop(context, obj);
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
                      Navigator.pop(context, obj);
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
                        Navigator.pop(context, obj);
                      }
                    }
                  }
                }),
          ),
          // Padding(
          //   padding: const EdgeInsets.only(
          //     right: 10,
          //   ),
          //   child: IconButton(
          //       icon: Image.asset(
          //         'assets/icons/video-camera.png',
          //         width: width * 0.08,
          //         height: height * 0.08,
          //       ),
          //       onPressed: () async {
          //         final pickedFile = await ImagePicker().getVideo(
          //             source: ImageSource.camera,
          //             maxDuration: Duration(
          //               minutes: 5,
          //             ));
          //         if (pickedFile != null) {
          //           // Navigator.push(
          //           //   context,
          //           //   MaterialPageRoute(
          //           //       builder: (context) => PostStory(
          //           //             cameraVideoOrImage: File(pickedFile.path),
          //           //             cameraType: "video",
          //           //           )),
          //           // );
          //         }
          //       }),
          // )
        ],
      ),
      backgroundColor: Palette.backgroundColor,
      body: ProfileGalleryView(),
    );
  }
}
