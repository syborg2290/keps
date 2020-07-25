import 'dart:convert';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keptoon/models/post.dart';
import 'package:keptoon/models/user.dart';
import 'package:keptoon/services/auth_service.dart';
import 'package:keptoon/services/post_service.dart';
import 'package:keptoon/services/user_service.dart';
import 'package:keptoon/utils/full_screen_post_network.dart';
import 'package:keptoon/utils/maps/post_map.dart';
import 'package:keptoon/utils/pallete.dart';
import 'package:keptoon/utils/postMedia/postPicker.dart';
import 'package:keptoon/utils/shimmers/feed2_shimmer.dart';
import 'package:keptoon/utils/shimmers/feed_shimmer.dart';
import 'package:keptoon/utils/shimmers/gallery_shimmer.dart';
import 'package:keptoon/utils/video_plyers/networkVideo.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timeago/timeago.dart' as timeago;

class Feed extends StatefulWidget {
  Feed({Key key}) : super(key: key);

  @override
  _FeedState createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  String current = "experiences";
  User currentUser;
  AuthServcies authService = AuthServcies();
  PostService _postService = PostService();
  UserService _userSEr = UserService();
  bool isLoading = true;
  List<DocumentSnapshot> all = [];

  @override
  void initState() {
    super.initState();
    _userSEr.getAllUsers().then((allUser) {
      setState(() {
        all = allUser;
      });
    });
    authService.getCurrentUser().then((fuser) {
      authService.getUserObj(fuser.uid).then((user) {
        setState(() {
          currentUser = User.fromDocument(user);
          isLoading = false;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.transparent));

    return isLoading
        ? Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              color: Palette.backgroundColor,
              child: feedShimmer(context),
            ),
          )
        : Scaffold(
            backgroundColor: Palette.backgroundColor,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              brightness: Brightness.light,
              backgroundColor: Colors.transparent,
              elevation: 0.0,
              leading: Padding(
                padding: const EdgeInsets.only(
                  left: 20,
                  bottom: 10,
                ),
                child: Image.asset(
                  'assets/gif_icons/live.gif',
                  width: 30,
                  height: 30,
                ),
              ),
              centerTitle: true,
              title: Text(
                'Share the moment',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w300),
              ),
              actions: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(
                    right: 20,
                    bottom: 10,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PostPicker(
                                    postType: current,
                                    currentUser: currentUser,
                                    isFromPost: false,
                                  )));
                    },
                    child: Image.asset(
                      'assets/icons/plus.png',
                      width: 30,
                      height: 30,
                    ),
                  ),
                )
              ],
            ),
            body: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.0,
                    ),
                    child: Center(
                      child: Container(
                        width: width * 0.85,
                        height: 55,
                        decoration: BoxDecoration(
                            color: Color(0xffe0e0e0).withOpacity(0.4),
                            borderRadius: BorderRadius.all(
                              Radius.circular(65.0),
                            ),
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            )),
                        child: Material(
                          elevation: 2,
                          color: Color(0xffe0e0e0),
                          borderRadius: BorderRadius.all(
                            Radius.circular(65.0),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                            child: TextField(
                              onChanged: (text) {},
                              onTap: () {},
                              style: TextStyle(
                                  color: Colors.black, fontSize: 16.0),
                              cursorColor: Colors.black,
                              textAlign: TextAlign.justify,
                              readOnly: true,
                              decoration: InputDecoration(
                                hintText: "Search",
                                hintStyle: TextStyle(
                                  fontSize: 18,
                                ),
                                filled: true,
                                fillColor: Color(0xffe0e0e0),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 5.0, vertical: 12.0),
                                prefixIcon: Material(
                                  color: Color(0xffe0e0e0),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(30.0),
                                  ),
                                  child: InkWell(
                                    onTap: () {},
                                    child: Icon(
                                      Icons.search,
                                      color: Colors.black38,
                                    ),
                                  ),
                                ),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Center(
                    child: Container(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    current = "experiences";
                                  });
                                },
                                child: Column(
                                  children: <Widget>[
                                    current == "experiences"
                                        ? Text(
                                            'Experiences',
                                            style: TextStyle(
                                                color: Colors.grey[500],
                                                fontFamily: "Roboto",
                                                fontSize: 28,
                                                fontWeight: FontWeight.w900),
                                          )
                                        : Text(
                                            'Experiences',
                                            style: TextStyle(
                                                color: Colors.grey[500],
                                                fontFamily: "Roboto",
                                                fontSize: 22,
                                                fontWeight: FontWeight.w500),
                                          )
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    current = "places";
                                  });
                                },
                                child: Column(
                                  children: <Widget>[
                                    current == "places"
                                        ? Text(
                                            'Places',
                                            style: TextStyle(
                                                color: Colors.grey[500],
                                                fontFamily: "Roboto",
                                                fontSize: 28,
                                                fontWeight: FontWeight.w900),
                                          )
                                        : Text(
                                            'Places',
                                            style: TextStyle(
                                                color: Colors.grey[500],
                                                fontFamily: "Roboto",
                                                fontSize: 22,
                                                fontWeight: FontWeight.w500),
                                          )
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    current = "foods";
                                  });
                                },
                                child: Column(
                                  children: <Widget>[
                                    current == "foods"
                                        ? Text(
                                            'Foods',
                                            style: TextStyle(
                                                color: Colors.grey[500],
                                                fontFamily: "Roboto",
                                                fontSize: 28,
                                                fontWeight: FontWeight.w900),
                                          )
                                        : Text(
                                            'Foods',
                                            style: TextStyle(
                                                color: Colors.grey[500],
                                                fontFamily: "Roboto",
                                                fontSize: 22,
                                                fontWeight: FontWeight.w500),
                                          )
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  StreamBuilder(
                      stream: _postService.streamPosts(current),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (!snapshot.hasData) {
                          return Container(
                            color: Palette.backgroundColor,
                            child: feed2Shimmer(context),
                          );
                        }
                        if (snapshot.data.documents.length == 0) {
                          return Center(
                            child: Column(
                              children: <Widget>[
                                Image.asset(
                                  'assets/empty_story.png',
                                  width: width * 0.8,
                                  height: height * 0.5,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: current == "experiences"
                                      ? Text("Empty experinces",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.black38,
                                            fontSize: 36.0,
                                            fontFamily: "Calibre-Semibold",
                                            letterSpacing: 1.0,
                                          ))
                                      : current == "foods"
                                          ? Text("Empty foods",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Colors.black38,
                                                fontSize: 36.0,
                                                fontFamily: "Calibre-Semibold",
                                                letterSpacing: 1.0,
                                              ))
                                          : Text("Empty places",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Colors.black38,
                                                fontSize: 36.0,
                                                fontFamily: "Calibre-Semibold",
                                                letterSpacing: 1.0,
                                              )),
                                ),
                              ],
                            ),
                          );
                        } else {
                          List<Post> postList = [];

                          snapshot.data.documents.forEach((doc) {
                            Post post = Post.fromDocument(doc);
                            postList.add(post);
                          });

                          return ListView.builder(
                              itemCount: postList.length,
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: EdgeInsets.only(
                                    top: 10,
                                    bottom: 10,
                                  ),
                                  child: PostWidget(
                                    post: postList[index],
                                    owner: User.fromDocument(all.firstWhere(
                                        (e) =>
                                            e["id"] == postList[index].ownerId,
                                        orElse: () => null)),
                                  ),
                                );
                              });
                        }
                      }),
                ],
              ),
            ),
          );
  }
}

class PostWidget extends StatelessWidget {
  final Post post;
  final User owner;

  const PostWidget({this.post, this.owner, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Container(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(
              left: 20,
              top: 10,
            ),
            child: InkWell(
              onTap: () {},
              child: Row(
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40.0),
                        border: Border.all(
                          color: Palette.mainAppColor,
                          width: 3,
                        )),
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Hero(
                        transitionOnUserGestures: true,
                        tag: owner.username,
                        child: CircleAvatar(
                          maxRadius: 28,
                          backgroundColor: Color(0xffe0e0e0),
                          backgroundImage: owner.thumbnailUserPhotoUrl == null
                              ? AssetImage('assets/profilephoto.png')
                              : NetworkImage(owner.thumbnailUserPhotoUrl),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(owner.username,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w700)),
                      Text(
                        timeago.format(post.timestamp.toDate()),
                        style: TextStyle(
                            color: Colors.black,
                            fontFamily: "Roboto",
                            fontSize: 14,
                            fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      right: 15,
                      left: width * 0.25,
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

                            locationCoord.add(post.postLatitide);
                            locationCoord.add(post.postLongitude);

                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return PostMap(
                                locationCoord: locationCoord,
                                isFromFeed: true,
                              );
                            }));
                          }
                        }

                        if (status.isGranted &&
                            statusAl.isGranted &&
                            statusIn.isGranted) {
                          List<double> locationCoord = [];

                          locationCoord.add(post.postLatitide);
                          locationCoord.add(post.postLongitude);

                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return PostMap(
                              locationCoord: locationCoord,
                              isFromFeed: true,
                            );
                          }));
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

                            locationCoord.add(post.postLatitide);
                            locationCoord.add(post.postLongitude);

                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return PostMap(
                                locationCoord: locationCoord,
                                isFromFeed: true,
                              );
                            }));
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
          SizedBox(
            height: 5,
          ),
          SizedBox(
            height: 28,
            child: ListView.builder(
                itemCount: post.tags.length,
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(
                      left: 10,
                    ),
                    child: Text(
                      "#" + json.decode(post.tags[index])["tag"],
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }),
          ),
          post.postMediaUrls.length == 1
              ? Center(
                  child: Align(
                    alignment: Alignment.center,
                    child: Container(
                      height: 320,
                      padding: EdgeInsets.only(top: 20),
                      child: AspectRatio(
                        aspectRatio: 7 / 6.7,
                        child: post.mediaTypes[0] == "image"
                            ? GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            NetworkScreenPostFile(
                                              file: post.postMediaUrls[0],
                                              type: "image",
                                            )),
                                  );
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: FancyShimmerImage(
                                    imageUrl: post.postMediathumbnailUrls[0],
                                    boxFit: BoxFit.cover,
                                    shimmerBackColor: Color(0xffe0e0e0),
                                    shimmerBaseColor: Color(0xffe0e0e0),
                                    shimmerHighlightColor: Colors.grey[200],
                                  ),
                                ),
                              )
                            : NetworkVideoplayer(
                                video: post.postMediaUrls[0],
                                aspectRatio: 7 / 6.7,
                              ),
                      ),
                    ),
                  ),
                )
              : Container(
                  height: 320,
                  padding: EdgeInsets.only(top: 20),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: post.postMediaUrls.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {},
                        child: AspectRatio(
                          aspectRatio: 7 / 6.7,
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
                                post.mediaTypes[index] == "image"
                                    ? GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    NetworkScreenPostFile(
                                                      file: post
                                                          .postMediaUrls[index],
                                                      type: "image",
                                                    )),
                                          );
                                        },
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          child: FancyShimmerImage(
                                            imageUrl: post
                                                .postMediathumbnailUrls[index],
                                            boxFit: BoxFit.cover,
                                            shimmerBackColor: Color(0xffe0e0e0),
                                            shimmerBaseColor: Color(0xffe0e0e0),
                                            shimmerHighlightColor:
                                                Colors.grey[200],
                                          ),
                                        ),
                                      )
                                    : NetworkVideoplayer(
                                        video: post.postMediaUrls[index],
                                        aspectRatio: 7 / 6.7,
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
                                                        BorderRadius.circular(
                                                            30),
                                                    color: Colors.black
                                                        .withOpacity(0.8)),
                                                child: Center(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            2.0),
                                                    child: Text(
                                                      "${index + 1}/${post.postMediaUrls.length}",
                                                      textAlign:
                                                          TextAlign.center,
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
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  )),
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                width: 30,
              ),
              Image.asset(
                'assets/icons/heart.png',
                width: 38,
                height: 38,
                color: Colors.black.withOpacity(0.7),
              ),
              SizedBox(
                width: 20,
              ),
              Image.asset(
                'assets/icons/comment.png',
                width: 35,
                height: 35,
                color: Colors.black.withOpacity(0.7),
              ),
              SizedBox(
                width: 200,
              ),
              Image.asset(
                'assets/icons/bookmark.png',
                width: 35,
                height: 35,
                color: Colors.black.withOpacity(0.5),
              )
            ],
          ),
          Divider(),
        ],
      ),
    );
  }
}
