import 'package:flutter/material.dart';
import 'package:grafpix/pixloaders/pix_loader.dart';
import 'package:keptoon/utils/pallete.dart';

Container rockProgress() {
  return Container(
    padding: EdgeInsets.only(bottom: 10.0),
    child: PixLoader(
        loaderType: LoaderType.Rocks, faceColor: Palette.mainAppColor),
  );
}

Container flashProgress() {
  return Container(
    padding: EdgeInsets.only(bottom: 10.0),
    child: PixLoader(
        loaderType: LoaderType.Flashing, faceColor: Palette.mainAppColor),
  );
}
