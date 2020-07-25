import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keptoon/models/user.dart';
import 'package:keptoon/services/auth_service.dart';
import 'package:keptoon/utils/compress_media.dart';
import 'package:keptoon/utils/pallete.dart';
import 'package:keptoon/utils/profileMedia/profileImagePicker.dart';
import 'package:keptoon/services/user_service.dart';
import 'package:keptoon/utils/shimmers/profile_shimmer.dart';
import 'package:photo_manager/photo_manager.dart';

class Profile extends StatefulWidget {
  final String profileId;
  Profile({this.profileId, Key key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  AuthServcies _authServcies = AuthServcies();
  UserService _userService = UserService();
  User current;
  bool profilePicUploading = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _authServcies.getCurrentUser().then((fuser) {
      _authServcies.getUserObj(fuser.uid).then((user) {
        setState(() {
          current = User.fromDocument(user);
          isLoading = false;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.transparent));

    return isLoading
        ? profileShimmer(context)
        : Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              brightness: Brightness.light,
              backgroundColor: Colors.transparent,
              elevation: 0.0,
              leading: IconButton(
                iconSize: 30.0,
                padding: EdgeInsets.only(left: 28.0),
                icon: Icon(Icons.expand_more),
                onPressed: () async {},
              ),
              actions: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(
                    right: 15,
                  ),
                  child: IconButton(
                    iconSize: 40.0,
                    padding: EdgeInsets.only(left: 28.0),
                    icon: Icon(Icons.expand_more),
                    onPressed: () async {},
                  ),
                )
              ],
            ),
            backgroundColor: Palette.backgroundColor,
            body: SingleChildScrollView(
              child: StreamBuilder(
                  stream: _userService.streamingUser(current.id),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return profileShimmer(context);
                    } else {
                      User user = User.fromDocument(snapshot.data.documents[0]);

                      return Center(
                        child: Column(
                          children: <Widget>[
                            Center(
                              child: Container(
                                child: Column(
                                  children: <Widget>[
                                    Center(
                                      child: Stack(
                                        children: <Widget>[
                                          Container(
                                            height: 150,
                                            width: 150,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(100),
                                              border: Border.all(
                                                color: Palette.mainAppColor,
                                                width: 3,
                                              ),
                                            ),
                                            child: user.thumbnailUserPhotoUrl ==
                                                    null
                                                ? AssetImage(
                                                    'assets/profilephoto.png')
                                                : ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                100)),
                                                    child: FancyShimmerImage(
                                                      imageUrl: user
                                                          .thumbnailUserPhotoUrl,
                                                      boxFit: BoxFit.cover,
                                                      shimmerBackColor:
                                                          Color(0xffe0e0e0),
                                                      shimmerBaseColor:
                                                          Color(0xffe0e0e0),
                                                      shimmerHighlightColor:
                                                          Colors.grey[200],
                                                    )),
                                          ),
                                          widget.profileId == current.id
                                              ? FloatingActionButton(
                                                  onPressed: () async {
                                                    var media =
                                                        await Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              ProfileImagePicker()),
                                                    );

                                                    if (media != null) {
                                                      profilePicUploading =
                                                          true;
                                                      if (media["type"] ==
                                                          "gallery") {
                                                        List<AssetEntity>
                                                            mediaFromGallery =
                                                            media["mediaList"];

                                                        mediaFromGallery.forEach(
                                                            (element) async {
                                                          String imageUrl = await _userService
                                                              .uploadImageProfilePic(
                                                                  current.id,
                                                                  await compressImageFile(
                                                                      await element
                                                                          .file,
                                                                      80));

                                                          String imagethumbUrl =
                                                              await _userService
                                                                  .uploadImageProfilePicThumbnail(
                                                                      current
                                                                          .id,
                                                                      await getThumbnailForImage(
                                                                          await element
                                                                              .file,
                                                                          40));

                                                          await _userService
                                                              .updateUserImage(
                                                            current.id,
                                                            imageUrl,
                                                            imagethumbUrl,
                                                          );
                                                        });

                                                        profilePicUploading =
                                                            false;
                                                      }

                                                      if (media["type"] ==
                                                          "camPhoto") {
                                                        String imageUrl = await _userService
                                                            .uploadImageProfilePic(
                                                                current.id,
                                                                await compressImageFile(
                                                                    media[
                                                                        "mediaFile"],
                                                                    80));

                                                        String imagethumbUrl =
                                                            await _userService
                                                                .uploadImageProfilePicThumbnail(
                                                                    current.id,
                                                                    await getThumbnailForImage(
                                                                        media[
                                                                            "mediaFile"],
                                                                        40));

                                                        await _userService
                                                            .updateUserImage(
                                                          current.id,
                                                          imageUrl,
                                                          imagethumbUrl,
                                                        );
                                                        profilePicUploading =
                                                            false;
                                                      }
                                                    }
                                                  },
                                                  elevation: 10.0,
                                                  backgroundColor:
                                                      Palette.mainAppColor,
                                                  child: Image.asset(
                                                    'assets/icons/edit.png',
                                                    width: 30,
                                                    height: 30,
                                                    color: Colors.white,
                                                  ),
                                                )
                                              : SizedBox.shrink()
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                    Center(
                                      child: Text(
                                        current.username,
                                        style: TextStyle(
                                            color: Colors.grey[800],
                                            fontFamily: "Roboto",
                                            fontSize: 36,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                    Center(
                                      child: Text(
                                        "Mobile Application Developer",
                                        style: TextStyle(
                                            color: Colors.grey[500],
                                            fontFamily: "Roboto",
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                    Center(
                                      child: FlatButton(
                                        onPressed: () async {},
                                        shape: new RoundedRectangleBorder(
                                            borderRadius:
                                                new BorderRadius.circular(
                                                    30.0)),
                                        child: Text(
                                          "Subscribe",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                          ),
                                        ),
                                        color: Palette.mainAppColor,
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                    Center(
                                      child: Container(
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Column(
                                                  children: <Widget>[
                                                    Text(
                                                      'Experiences',
                                                      style: TextStyle(
                                                          color:
                                                              Colors.grey[500],
                                                          fontFamily: "Roboto",
                                                          fontSize: 22,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                    )
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Column(
                                                  children: <Widget>[
                                                    Text(
                                                      'Places',
                                                      style: TextStyle(
                                                          color:
                                                              Colors.grey[500],
                                                          fontFamily: "Roboto",
                                                          fontSize: 22,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                    )
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Column(
                                                  children: <Widget>[
                                                    Text(
                                                      'Foods',
                                                      style: TextStyle(
                                                          color:
                                                              Colors.grey[500],
                                                          fontFamily: "Roboto",
                                                          fontSize: 22,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                    )
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  }),
            ),
          );
  }
}
