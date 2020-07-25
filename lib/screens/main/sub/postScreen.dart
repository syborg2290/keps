import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:keptoon/models/tag.dart';
import 'package:keptoon/models/user.dart';
import 'package:keptoon/screens/initial/home.dart';
import 'package:keptoon/screens/main/sub/allTags.dart';
import 'package:keptoon/screens/main/sub/selectedTags.dart';
import 'package:keptoon/services/post_service.dart';
import 'package:keptoon/services/tag_service.dart';
import 'package:keptoon/utils/compress_media.dart';
import 'package:keptoon/utils/flush_bars.dart';
import 'package:keptoon/utils/full_screenPostFile.dart';
import 'package:keptoon/utils/image_cropper.dart';
import 'package:keptoon/utils/maps/post_map.dart';
import 'package:keptoon/utils/pallete.dart';
import 'package:keptoon/utils/postMedia/postPicker.dart';
import 'package:keptoon/utils/progress.dart';
import 'package:keptoon/utils/video_plyers/fileVideo.dart';
import 'package:keptoon/utils/video_trimmer.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:video_player/video_player.dart';
import 'package:video_trimmer/video_trimmer.dart';
import 'package:permission_handler/permission_handler.dart';

class PostScreen extends StatefulWidget {
  final object;
  final String postType;
  final User current;
  final bool fromTrimmer;
  final List<File> postMedias;
  final List<String> type;
  final double latitude;
  final double longitude;
  final List<Tag> tags;
  PostScreen(
      {this.object,
      this.fromTrimmer,
      this.postMedias,
      this.tags,
      this.latitude,
      this.longitude,
      this.type,
      this.current,
      this.postType,
      Key key})
      : super(key: key);

  @override
  _PostScreenState createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  List<File> postMedias = [];
  TagsServices _tags = TagsServices();
  PostService _postService = PostService();
  List<String> type = [];
  double latitude;
  double longitude;
  List<Tag> tags = [];
  ProgressDialog pr;
  VideoPlayerController _videocontroller;
  TextEditingController tagname = TextEditingController();

  @override
  void initState() {
    super.initState();

    pr = ProgressDialog(
      context,
      type: ProgressDialogType.Download,
      textDirection: TextDirection.ltr,
      isDismissible: false,
      customBody: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
        ),
        width: 100,
        height: 100,
        child: Center(
          child: rockProgress(),
        ),
      ),
      showLogs: false,
    );

    if (widget.fromTrimmer) {
      setState(() {
        postMedias = widget.postMedias;
        type = widget.type;
        latitude = widget.latitude;
        longitude = widget.longitude;
        tags = widget.tags;
      });
    } else {
      if (widget.object["type"] == "gallery") {
        List<AssetEntity> selectedMedia = widget.object["mediaList"];

        for (var i = 0; i < selectedMedia.length; i++) {
          selectedMedia[i].file.then((fileRe) {
            setState(() {
              postMedias.add(fileRe);
            });
          });

          if (selectedMedia[i].type.toString() == "AssetType.image") {
            setState(() {
              type.add("image");
            });
          } else {
            selectedMedia[i].file.then((video) {
              checkVideoDurations(video, i);
            });

            setState(() {
              type.add("video");
            });
          }
        }
      }

      if (widget.object["type"] == "camPhoto") {
        PickedFile filep = widget.object["mediaList"];

        setState(() {
          type.add("image");
          postMedias.add(File(filep.path));
        });
      }

      if (widget.object["type"] == "camVideo") {
        PickedFile filep = widget.object["mediaList"];

        setState(() {
          type.add("video");
          postMedias.add(File(filep.path));
        });
      }
    }
  }

  checkVideoDurations(File video, int index) async {
    _videocontroller = VideoPlayerController.file(video)
      ..initialize().then((_) {
        if (_videocontroller.value.duration.inSeconds > 300) {
          videoTrimDialog(_videocontroller.value.duration.inMinutes.toString(),
              video, index);
          return;
        }
      });
  }

  videoTrimDialog(String duration, File video, int index) {
    AwesomeDialog(
      context: context,
      animType: AnimType.SCALE,
      dialogType: DialogType.INFO,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Center(
              child: Text(
                "Maximum video duration (5 minitues)",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              width: 300,
              height: 250,
              child: FileVideoplayer(
                video: video,
                aspectRatio: 1.2 / 1,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.only(
                right: 20,
                left: 20,
              ),
              child: Container(
                height: 50,
                width: double.infinity,
                child: FlatButton(
                  onPressed: () async {
                    final Trimmer _trimmer = Trimmer();
                    await _trimmer.loadVideo(videoFile: video);

                    File trimmedVideo = await Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return VideoTrimmer(
                        trimmer: _trimmer,
                        current: widget.current,
                        index: index,
                        latitude: latitude,
                        longitude: longitude,
                        postMedias: postMedias,
                        postType: widget.postType,
                        tags: tags,
                        type: type,
                      );
                    }));

                    if (trimmedVideo != null) {
                      setState(() {
                        postMedias[index] = trimmedVideo;
                      });
                    }
                  },
                  padding: EdgeInsets.all(0),
                  child: Ink(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Palette.mainAppColor,
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      constraints: BoxConstraints(
                          maxWidth: double.infinity, minHeight: 50),
                      child: Text(
                        "Trim video",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    )..show();
  }

  post() async {
    if (longitude != null && latitude != null) {
      if (tags.isNotEmpty) {
        pr.show();

        List<String> mediaUrls = [];
        List<String> thumbnailUrls = [];
        List<String> typeF = [];
        List enodedTags = [];

        for (var i = 0; i < postMedias.length; i++) {
          _videocontroller = VideoPlayerController.file(postMedias[i])
            ..initialize().then((_) {
              if (_videocontroller.value.duration.inSeconds > 300) {
                postMedias.removeAt(i);
                type.removeAt(i);
              }
            });
        }

        for (var i = 0; i < postMedias.length; i++) {
          if (type[i] == "image") {
            typeF.add("image");
            mediaUrls.add(await _postService
                .uploadImagePost(await compressImageFile(postMedias[i], 80)));
            thumbnailUrls.add(await _postService.uploadImagePostThumbnail(
                await compressImageFile(postMedias[i], 40)));
          } else {
            typeF.add("video");
            mediaUrls.add(await _postService
                .uploadVideoToPost(await compressVideoFile(postMedias[i])));
            thumbnailUrls.add(await _postService.uploadVideoToPostThumb(
                await getThumbnailForVideo(postMedias[i])));
          }
        }

        for (var elem in tags) {
          enodedTags.add(json.encode(Tag().toMap(elem)));
          await _tags.updateTagsCount(widget.current.id, elem.tag);
        }

        await _postService.addPost(widget.current.id, widget.postType, latitude,
            longitude, mediaUrls, thumbnailUrls, typeF, enodedTags);

        pr.hide().whenComplete(() {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return Home();
          }));
        });
      } else {
        GradientSnackBar.showMessage(context, "Please select atleast 1 #tag!");
      }
    } else {
      GradientSnackBar.showMessage(context, "Please pin the location!");
    }
  }

  addNewTagDialog() {
    AwesomeDialog(
        context: context,
        animType: AnimType.SCALE,
        dialogType: DialogType.NO_HEADER,
        body: Center(
          child: Column(
            children: <Widget>[
              Text(
                'Create new tag',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  child: TextField(
                    controller: tagname,
                    autofocus: true,
                    decoration: InputDecoration(
                      prefix: Text(
                        "#",
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                            fontWeight: FontWeight.w700),
                      ),
                      labelText: "Tag name",
                      labelStyle: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w700),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade700),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Palette.mainAppColor),
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.auto,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.only(
                  right: 40,
                  left: 40,
                ),
                child: Container(
                  height: 50,
                  width: double.infinity,
                  child: FlatButton(
                    onPressed: () async {
                      if (tagname.text.trim() != "") {
                        pr.show();
                        QuerySnapshot sn =
                            await _tags.tagCheckSe(tagname.text.trim());
                        if (sn.documents.length > 0) {
                          pr.hide();
                          GradientSnackBar.showMessage(
                              context, "Tag already in the list!");
                        } else {
                          Tag tag = await _tags.addNewTag(
                              tagname.text.trim(), widget.current.id);
                          setState(() {
                            tags.add(tag);
                          });
                          pr.hide().whenComplete(() {
                            Navigator.pop(context);
                          });
                        }
                      }
                    },
                    padding: EdgeInsets.all(0),
                    child: Ink(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Palette.mainAppColor,
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        constraints: BoxConstraints(
                            maxWidth: double.infinity, minHeight: 50),
                        child: Text(
                          "Create",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        btnOk: Text(""),
        btnCancel: Text(""))
      ..show();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.transparent));

    return Scaffold(
      backgroundColor: Palette.backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        brightness: Brightness.dark,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: Padding(
          padding: const EdgeInsets.only(
            left: 20,
          ),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Home()));
            },
            child: Image.asset(
              'assets/icons/left-arrow.png',
              width: 20,
              height: 20,
            ),
          ),
        ),
        title: Text(
          'customize the post',
          style: TextStyle(
              color: Colors.black,
              fontFamily: "Roboto",
              fontSize: 20,
              fontWeight: FontWeight.w700),
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(
              right: 10,
              bottom: 10,
            ),
            child: FlatButton(
              onPressed: () async {
                await post();
              },
              child: Center(
                  child: Text("Post",
                      style: TextStyle(
                        fontSize: 19,
                        color: Colors.white,
                      ))),
              color: Palette.mainAppColor,
              shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(20.0),
                  side: BorderSide(
                    color: Palette.mainAppColor,
                  )),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                left: 20,
                top: 20,
              ),
              child: InkWell(
                onTap: () {},
                child: Row(
                  children: <Widget>[
                    Hero(
                      transitionOnUserGestures: true,
                      tag: widget.current.username,
                      child: CircleAvatar(
                        maxRadius: 28,
                        backgroundColor: Color(0xffe0e0e0),
                        backgroundImage:
                            widget.current.thumbnailUserPhotoUrl == null
                                ? AssetImage('assets/profilephoto.png')
                                : NetworkImage(
                                    widget.current.thumbnailUserPhotoUrl),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            widget.current.username,
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w500),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 30,
                              top: 5,
                            ),
                            child: Row(
                              children: <Widget>[
                                Image.asset(
                                  'assets/icons/pin.png',
                                  width: 25,
                                  height: 25,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 6,
                                  ),
                                  child: Image.asset(
                                    latitude != null
                                        ? 'assets/icons/correct.png'
                                        : 'assets/icons/dot.png',
                                    width: 20,
                                    height: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    FloatingActionButton(
                      heroTag: "tags",
                      onPressed: () async {
                        if (tags.isNotEmpty) {
                          List<Tag> tagRE = await Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return SelectedTags(
                              allTags: tags,
                            );
                          }));
                          if (tagRE != null) {
                            setState(() {
                              tags = tagRE;
                            });
                          }
                        }
                      },
                      backgroundColor: Palette.mainAppColor,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Image.asset(
                              'assets/icons/tag.png',
                              width: 20,
                              height: 20,
                              color: Colors.white,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Text(
                              tags.length.toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        right: 10,
                      ),
                      child: FloatingActionButton(
                        onPressed: () async {
                          var status = await Permission.location.status;
                          var statusAl = await Permission.locationAlways.status;
                          var statusIn =
                              await Permission.locationWhenInUse.status;
                          if (status.isUndetermined) {
                            var statusRe = await Permission.location.request();
                            var statusAlRe =
                                await Permission.locationAlways.request();
                            var statusInRe =
                                await Permission.locationWhenInUse.request();
                            if (statusRe.isGranted &&
                                statusAlRe.isGranted &&
                                statusInRe.isGranted) {
                              List<double> locationCoord = [];

                              locationCoord.add(latitude);
                              locationCoord.add(longitude);

                              List<double> ltng = await Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return PostMap(
                                  locationCoord:
                                      latitude == null ? null : locationCoord,
                                  isFromFeed: false,
                                );
                              }));

                              if (ltng != null) {
                                setState(() {
                                  latitude = ltng[0];
                                  longitude = ltng[1];
                                });
                              }
                            }
                          }

                          if (status.isGranted &&
                              statusAl.isGranted &&
                              statusIn.isGranted) {
                            List<double> locationCoord = [];

                            locationCoord.add(latitude);
                            locationCoord.add(longitude);

                            List<double> ltng = await Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return PostMap(
                                locationCoord:
                                    latitude == null ? null : locationCoord,
                                isFromFeed: false,
                              );
                            }));
                            if (ltng != null) {
                              setState(() {
                                latitude = ltng[0];
                                longitude = ltng[1];
                              });
                            }
                          } else {
                            var statusRe2 = await Permission.location.request();
                            var statusReAl2 =
                                await Permission.locationAlways.request();
                            var statusReIn2 =
                                await Permission.locationWhenInUse.request();
                            if (statusRe2.isGranted &&
                                statusReAl2.isGranted &&
                                statusReIn2.isGranted) {
                              List<double> locationCoord = [];

                              locationCoord.add(latitude);
                              locationCoord.add(longitude);

                              List<double> ltng = await Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return PostMap(
                                  locationCoord:
                                      latitude == null ? null : locationCoord,
                                  isFromFeed: false,
                                );
                              }));

                              if (ltng != null) {
                                setState(() {
                                  latitude = ltng[0];
                                  longitude = ltng[1];
                                });
                              }
                            }
                          }
                        },
                        heroTag: "postlocation",
                        backgroundColor: Palette.mainAppColor,
                        child: Image.asset(
                          'assets/icons/pin.png',
                          color: Colors.white,
                          width: 30,
                          height: 30,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
                height: 320,
                padding: EdgeInsets.only(top: 20),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: postMedias.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {},
                      child: AspectRatio(
                        aspectRatio: 1.2 / 1,
                        child: Container(
                          margin: EdgeInsets.only(
                            left: 10,
                            right: 5,
                          ),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.black),
                          child: Stack(
                            children: <Widget>[
                              type[index] == "image"
                                  ? GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  FullScreenPostFile(
                                                    file: postMedias[index],
                                                    type: "image",
                                                  )),
                                        );
                                      },
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: Image.file(
                                          postMedias[index],
                                          fit: BoxFit.cover,
                                          height: 320,
                                          width: 350,
                                        ),
                                      ),
                                    )
                                  : FileVideoplayer(
                                      video: postMedias[index],
                                      aspectRatio: 1.2 / 1,
                                    ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: GestureDetector(
                                  onTap: () {
                                    if (postMedias.length == 1) {
                                      setState(() {
                                        postMedias.removeAt(index);
                                        type.removeAt(index);
                                      });
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => Home()));
                                    } else {
                                      setState(() {
                                        postMedias.removeAt(index);
                                        type.removeAt(index);
                                      });
                                    }
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(30.0),
                                    child: ClipRect(
                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(
                                            sigmaX: 0, sigmaY: 0),
                                        child: Container(
                                          width: 50.0,
                                          height: 50.0,
                                          padding: EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                              color: Colors.black
                                                  .withOpacity(0.8)),
                                          child: Center(
                                              child: Padding(
                                            padding: const EdgeInsets.all(2.0),
                                            child: Image.asset(
                                              'assets/icons/close.png',
                                              color: Colors.white,
                                            ),
                                          )),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.topLeft,
                                child: Container(
                                  margin: EdgeInsets.all(20),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(30.0),
                                        child: ClipRect(
                                          child: BackdropFilter(
                                            filter: ImageFilter.blur(
                                                sigmaX: 0, sigmaY: 0),
                                            child: Container(
                                              width: 60.0,
                                              height: 40.0,
                                              padding: EdgeInsets.all(5),
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                  color: Colors.black
                                                      .withOpacity(0.8)),
                                              child: Center(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(2.0),
                                                  child: Text(
                                                    "${index + 1}/${postMedias.length}",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 20,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Container(
                                  margin: EdgeInsets.all(20),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                      GestureDetector(
                                        onTap: () async {
                                          if (type[index] == "image") {
                                            File croppedImage =
                                                await Navigator.push(context,
                                                    MaterialPageRoute(
                                                        builder: (context) {
                                              return ImageCropper(
                                                image: postMedias[index],
                                              );
                                            }));
                                            if (croppedImage != null) {
                                              setState(() {
                                                postMedias[index] =
                                                    croppedImage;
                                              });
                                            }
                                          } else {
                                            final Trimmer _trimmer = Trimmer();
                                            await _trimmer.loadVideo(
                                                videoFile: postMedias[index]);

                                            File trimmedVideo =
                                                await Navigator.push(context,
                                                    MaterialPageRoute(
                                                        builder: (context) {
                                              return VideoTrimmer(
                                                trimmer: _trimmer,
                                                current: widget.current,
                                                index: index,
                                                latitude: latitude,
                                                longitude: longitude,
                                                postMedias: postMedias,
                                                postType: widget.postType,
                                                tags: tags,
                                                type: type,
                                              );
                                            }));

                                            if (trimmedVideo != null) {
                                              setState(() {
                                                postMedias[index] =
                                                    trimmedVideo;
                                              });
                                            }
                                          }
                                        },
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(30.0),
                                          child: ClipRect(
                                            child: BackdropFilter(
                                              filter: ImageFilter.blur(
                                                  sigmaX: 0, sigmaY: 0),
                                              child: Container(
                                                width: 40.0,
                                                height: 40.0,
                                                padding: EdgeInsets.all(5),
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                    color: Colors.black
                                                        .withOpacity(0.8)),
                                                child: Center(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            2.0),
                                                    child: Image.asset(
                                                      type[index] == "image"
                                                          ? 'assets/icons/crop.png'
                                                          : 'assets/icons/cut.png',
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                )),
            SizedBox(
              height: 10,
            ),
            GestureDetector(
              onTap: () async {
                var obj = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PostPicker(
                              isFromPost: true,
                            )));

                if (obj != null) {
                  if (obj["type"] == "gallery") {
                    List<AssetEntity> selectedMedia = obj["mediaList"];
                    for (var i = 0; i < selectedMedia.length; i++) {
                      selectedMedia[i].file.then((fileRe) {
                        setState(() {
                          postMedias.add(fileRe);
                        });
                      });

                      if (selectedMedia[i].type.toString() ==
                          "AssetType.image") {
                        setState(() {
                          type.add("image");
                        });
                      } else {
                        selectedMedia[i].file.then((video) {
                          checkVideoDurations(video, i);
                        });

                        setState(() {
                          type.add("video");
                        });
                      }
                    }
                  }

                  if (obj["type"] == "camPhoto") {
                    PickedFile filep = obj["mediaList"];

                    setState(() {
                      type.add("image");
                      postMedias.add(File(filep.path));
                    });
                  }

                  if (obj["type"] == "camVideo") {
                    PickedFile filep = obj["mediaList"];

                    setState(() {
                      type.add("video");
                      postMedias.add(File(filep.path));
                    });
                  }
                }
              },
              child: Image.asset(
                'assets/icons/plus.png',
                width: 40,
                height: 40,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.only(
                right: 20,
                left: 20,
              ),
              child: Container(
                height: 50,
                width: double.infinity,
                child: FlatButton(
                  onPressed: () async {
                    addNewTagDialog();
                  },
                  padding: EdgeInsets.all(0),
                  child: Ink(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Palette.mainAppColor,
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      constraints: BoxConstraints(
                          maxWidth: double.infinity, minHeight: 50),
                      child: Text(
                        "Create new #tag",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 10,
                ),
                child: Text(
                  "Popular tags for you",
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.5),
                    fontSize: 22,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            StreamBuilder(
              stream: _tags.streamingTags(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (!snapshot.hasData) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Image.asset(
                          'assets/icons/hash.png',
                          width: 50,
                          height: 50,
                          color: Colors.black.withOpacity(0.5),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          "tags not available yet",
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.5),
                            fontSize: 25,
                          ),
                          textAlign: TextAlign.center,
                        )
                      ],
                    ),
                  );
                }
                if (snapshot.data.documents.length == 0) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Image.asset(
                          'assets/icons/hash.png',
                          width: 50,
                          height: 50,
                          color: Colors.black.withOpacity(0.5),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          "tags not available yet",
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.5),
                            fontSize: 25,
                          ),
                          textAlign: TextAlign.center,
                        )
                      ],
                    ),
                  );
                } else {
                  List<Tag> streamedTags = [];
                  snapshot.data.documents.forEach((tagDoc) {
                    Tag stag = Tag.fromDocument(tagDoc);
                    streamedTags.add(stag);
                  });

                  return GridView.builder(
                      itemCount: streamedTags.length,
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 0,
                        mainAxisSpacing: 0,
                        childAspectRatio: 16 / 5,
                      ),
                      itemBuilder: (BuildContext context, int index2) {
                        return index2 <= 6
                            ? index2 == 5
                                ? GestureDetector(
                                    onTap: () async {
                                      List<Tag> re = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => AllTags(
                                                    allTags: tags,
                                                  )));
                                      if (re != null) {
                                        setState(() {
                                          tags = re;
                                        });
                                      }
                                    },
                                    child: Chip(
                                      backgroundColor: Colors.blue,
                                      label: Text("#more",
                                          style: TextStyle(
                                            color:
                                                Colors.white.withOpacity(0.9),
                                            fontSize: 25,
                                          )),
                                    ),
                                  )
                                : GestureDetector(
                                    onTap: () {
                                      if (tags
                                          .where((i) =>
                                              i.tag == streamedTags[index2].tag)
                                          .toList()
                                          .isEmpty) {
                                        setState(() {
                                          tags.add(streamedTags[index2]);
                                        });
                                      } else {
                                        int indexre =
                                            tags.indexWhere((element) {
                                          return element.tag.startsWith(
                                              streamedTags[index2].tag);
                                        });
                                        setState(() {
                                          tags.removeAt(indexre);
                                        });
                                      }
                                    },
                                    child: Text("#" + streamedTags[index2].tag,
                                        style: TextStyle(
                                          color: tags
                                                  .where((i) =>
                                                      i.tag ==
                                                      streamedTags[index2].tag)
                                                  .toList()
                                                  .isNotEmpty
                                              ? Palette.mainAppColor
                                              : Colors.black.withOpacity(0.9),
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center),
                                  )
                            : SizedBox.shrink();
                      });
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
