//Color Data

import 'package:flutter/material.dart';
import 'package:ruangkeluarga/global/global.dart';

const cOrtuBlue = Color(0xFF64c7ed);
const cOrtuDarkBlue = Color(0xFF2266bb);
const cAsiaBlue = Color(0xFF3d99e2);
const cAsiaBluex = Color(0x0caff3);
const cOrtuOrange = Color(0xFFffb703);
const cOrtuGrey = Color(0xFFdddddd);
const cOrtuLightGrey = Color(0xFFf5f5f5);
const cOrtuDarkGrey = Color(0xFF888888);
const cOrtuWhite = Color(0xFFffffff);

const cPrimaryBg =
appName == 'Ruang ORTU by ASIA' ? cOrtuWhite : Color(0x0caff3);// 0caff3
const cTopBg = appName == 'Ruang ORTU by ASIA' ? cAsiaBlue : Color(0x0caff3);
final cAccentButton = cOrtuOrange;
final cDisabled = Colors.grey.shade600;

const cOrtuButton = appName == 'Ruang ORTU by ASIA' ? cOrtuBlue : cOrtuWhite;
const cOrtuText =
    appName == 'Ruang ORTU by ASIA' ? Color(0xFF000000) : cOrtuWhite;
const cOrtuInkWell = appName == 'Ruang ORTU by ASIA' ? cAsiaBlue : cOrtuBlue;
const cOrtuForm = appName == 'Ruang ORTU by ASIA' ? cOrtuWhite : cOrtuGrey;
var cOrtuFormTheme =
    appName == 'Ruang ORTU by ASIA' ? ThemeData.dark() : ThemeData.light();
var cOrtuTheme =
    appName == 'Ruang ORTU by ASIA' ? ThemeData.light() : ThemeData.dark();
