import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keptoon/models/tag.dart';
import 'package:keptoon/utils/pallete.dart';

class SelectedTags extends StatefulWidget {
  final List<Tag> allTags;
  SelectedTags({this.allTags, Key key}) : super(key: key);

  @override
  _SelectedTagsState createState() => _SelectedTagsState();
}

class _SelectedTagsState extends State<SelectedTags> {
  List<Tag> allReTags = [];

  @override
  void initState() {
    super.initState();

    setState(() {
      allReTags = widget.allTags;
    });
  }

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
        title: Text(
          'Selected tags',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
          ),
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(
              right: 10,
              bottom: 10,
            ),
            child: FlatButton(
              onPressed: () async {
                Navigator.pop(context, allReTags);
              },
              child: Center(
                  child: Text("Done",
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
      backgroundColor: Palette.backgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
            itemCount: allReTags.length,
            scrollDirection: Axis.vertical,
            itemBuilder: (context, index) {
              return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Chip(
                      label: Text("#" + allReTags[index].tag,
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.9),
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (allReTags.length == 1) {
                          setState(() {
                            allReTags.removeAt(index);
                          });
                          Navigator.pop(context, allReTags);
                        } else {
                          setState(() {
                            allReTags.removeAt(index);
                          });
                        }
                      },
                      child: Container(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset(
                            'assets/icons/close.png',
                            width: 40,
                            height: 40,
                          ),
                        ),
                      ),
                    ),
                  ]);
            }),
      ),
    );
  }
}
