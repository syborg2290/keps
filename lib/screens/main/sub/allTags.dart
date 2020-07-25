import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keptoon/models/tag.dart';
import 'package:keptoon/services/tag_service.dart';
import 'package:keptoon/utils/pallete.dart';
import 'package:keptoon/utils/progress.dart';

class AllTags extends StatefulWidget {
  final List<Tag> allTags;
  AllTags({this.allTags, Key key}) : super(key: key);

  @override
  _AllTagsState createState() => _AllTagsState();
}

class _AllTagsState extends State<AllTags> {
  List<Tag> allTags = [];
  List<Tag> fillteredList = [];
  List<Tag> selectedTags = [];
  TagsServices _tag = TagsServices();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    _tag.getAllTaqgs().then((snp) {
      snp.documents.forEach((doc) {
        setState(() {
          allTags.add(Tag.fromDocument(doc));
          selectedTags = widget.allTags;
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
              Navigator.pop(context);
            },
            child: Image.asset(
              'assets/icons/left-arrow.png',
              width: 20,
              height: 20,
            ),
          ),
        ),
        title: Text(
          'All tags',
          style: TextStyle(
            color: Colors.black,
            fontFamily: "Roboto",
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
                Navigator.pop(context, selectedTags);
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
      resizeToAvoidBottomInset: false,
      body: isLoading
          ? rockProgress()
          : Column(
              children: <Widget>[
                SizedBox(
                  height: 10,
                ),
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
                            onChanged: (text) {
                              setState(() {
                                fillteredList = allTags
                                    .where((i) => i.tag
                                        .toLowerCase()
                                        .contains(text.toLowerCase()))
                                    .toList();
                              });
                            },
                            onTap: () {},
                            style:
                                TextStyle(color: Colors.black, fontSize: 16.0),
                            cursorColor: Colors.black,
                            textAlign: TextAlign.justify,
                            decoration: InputDecoration(
                              hintText: "Search tags",
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
                GridView.builder(
                    itemCount: fillteredList.isEmpty
                        ? allTags.length
                        : fillteredList.length,
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 0,
                      mainAxisSpacing: 0,
                      childAspectRatio: 16 / 5,
                    ),
                    itemBuilder: (BuildContext context, int index2) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (fillteredList.isNotEmpty) {
                              if (selectedTags
                                  .where(
                                      (i) => i.tag == fillteredList[index2].tag)
                                  .toList()
                                  .isEmpty) {
                                setState(() {
                                  selectedTags.add(fillteredList[index2]);
                                });
                              } else {
                                int indexre =
                                    selectedTags.indexWhere((element) {
                                  return element.tag
                                      .startsWith(fillteredList[index2].tag);
                                });

                                setState(() {
                                  selectedTags.removeAt(indexre);
                                });
                              }
                            } else {
                              if (selectedTags
                                  .where((i) => i.tag == allTags[index2].tag)
                                  .toList()
                                  .isEmpty) {
                                setState(() {
                                  selectedTags.add(allTags[index2]);
                                });
                              } else {
                                int indexre =
                                    selectedTags.indexWhere((element) {
                                  return element.tag
                                      .startsWith(allTags[index2].tag);
                                });

                                setState(() {
                                  selectedTags.removeAt(indexre);
                                });
                              }
                            }
                          });
                        },
                        child: Chip(
                          label: fillteredList.isEmpty
                              ? Text("#" + allTags[index2].tag,
                                  style: TextStyle(
                                    color: selectedTags
                                            .where((i) =>
                                                i.tag == allTags[index2].tag)
                                            .toList()
                                            .isEmpty
                                        ? Colors.black.withOpacity(0.9)
                                        : Palette.mainAppColor,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center)
                              : Text("#" + fillteredList[index2].tag,
                                  style: TextStyle(
                                    color: selectedTags
                                            .where((i) =>
                                                i.tag ==
                                                fillteredList[index2].tag)
                                            .toList()
                                            .isEmpty
                                        ? Colors.black.withOpacity(0.9)
                                        : Palette.mainAppColor,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center),
                        ),
                      );
                    }),
              ],
            ),
    );
  }
}
