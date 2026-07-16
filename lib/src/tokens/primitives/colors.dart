// lib/src/tokens/primitives/app_colors.dart

import 'package:flutter/widgets.dart';

/// Raw color swatches with no semantic meaning. Only the semantic token
/// layer (`lib/src/tokens/semantic/`) may reference these directly —
/// components must never import this file.
class AppColors {
  AppColors._();

  // Transparent
  static const transparent = Color(0x00000000);

  // Black (opacity variants)
  static const black010 = Color.fromRGBO(0, 0, 0, 0.10);
  static const black020 = Color.fromRGBO(0, 0, 0, 0.20);
  static const black030 = Color.fromRGBO(0, 0, 0, 0.30);
  static const black040 = Color.fromRGBO(0, 0, 0, 0.40);
  static const black050 = Color.fromRGBO(0, 0, 0, 0.50);
  static const black060 = Color.fromRGBO(0, 0, 0, 0.60);
  static const black070 = Color.fromRGBO(0, 0, 0, 0.70);
  static const black080 = Color.fromRGBO(0, 0, 0, 0.80);
  static const black090 = Color.fromRGBO(0, 0, 0, 0.90);
  static const black100 = Color.fromRGBO(0, 0, 0, 1.00);

  // White (opacity variants)
  static const white010 = Color.fromRGBO(255, 255, 255, 0.10);
  static const white020 = Color.fromRGBO(255, 255, 255, 0.20);
  static const white030 = Color.fromRGBO(255, 255, 255, 0.30);
  static const white040 = Color.fromRGBO(255, 255, 255, 0.40);
  static const white050 = Color.fromRGBO(255, 255, 255, 0.50);
  static const white060 = Color.fromRGBO(255, 255, 255, 0.60);
  static const white070 = Color.fromRGBO(255, 255, 255, 0.70);
  static const white080 = Color.fromRGBO(255, 255, 255, 0.80);
  static const white090 = Color.fromRGBO(255, 255, 255, 0.90);
  static const white100 = Color.fromRGBO(255, 255, 255, 1.00);

  // Gray
  static const gray050 = Color(0xFFFBFCFC);
  static const gray100 = Color(0xFFF1F2F4);
  static const gray200 = Color(0xFFE0E2E4);
  static const gray300 = Color(0xFFCDCED1);
  static const gray400 = Color(0xFFB9BBBF);
  static const gray500 = Color(0xFFA6A8AC);
  static const gray600 = Color(0xFF7A7C81);
  static const gray700 = Color(0xFF56595E);
  static const gray800 = Color(0xFF3C3E42);
  static const gray900 = Color(0xFF26282B);
  static const gray950 = Color(0xFF141517);

  // Neutral
  static const neutral050 = Color(0xFFF2F2F2);
  static const neutral100 = Color(0xFFEAEAEA);
  static const neutral200 = Color(0xFFE0E0E0);
  static const neutral300 = Color(0xFFD5D5D5);
  static const neutral400 = Color(0xFFC0C0C0);
  static const neutral500 = Color(0xFFABABAB);
  static const neutral600 = Color(0xFF969696);
  static const neutral700 = Color(0xFF737373);
  static const neutral800 = Color(0xFF5B5B5B);
  static const neutral900 = Color(0xFF3D3D3D);
  static const neutral1000 = Color(0xFF2E2E2E);
  static const neutral1100 = Color(0xFF222222);
  static const neutral1200 = Color(0xFF1B1B1B);

  // Indigo (Primary)
  static const indigo025 = Color(0xFFF2F8FF);
  static const indigo050 = Color(0xFFDCEAF9);
  static const indigo100 = Color(0xFFC4DCF7);
  static const indigo200 = Color(0xFF9CC3F2);
  static const indigo300 = Color(0xFF619EE3);
  static const indigo400 = Color(0xFF3071B7);
  static const indigo500 = Color(0xFF003B71);
  static const indigo600 = Color(0xFF002E5C);
  static const indigo700 = Color(0xFF002349);
  static const indigo800 = Color(0xFF001A39);
  static const indigo900 = Color(0xFF00122C);
  static const indigo950 = Color(0xFF00061A);

  // Tangerine (Secondary)
  static const tangerine050 = Color(0xFFFEEFEC);
  static const tangerine100 = Color(0xFFFDD4CC);
  static const tangerine200 = Color(0xFFFCBFB3);
  static const tangerine300 = Color(0xFFFBA999);
  static const tangerine400 = Color(0xFFFA7E66);
  static const tangerine500 = Color(0xFFF85333);
  static const tangerine600 = Color(0xFFF62800);
  static const tangerine700 = Color(0xFFC52000);
  static const tangerine800 = Color(0xFF941800);

  // Green
  static const green050 = Color(0xFFE6F6EC);
  static const green100 = Color(0xFFD1EDDD);
  static const green200 = Color(0xFFBCE5CD);
  static const green300 = Color(0xFFA7DCBE);
  static const green400 = Color(0xFF7CCB9E);
  static const green500 = Color(0xFF52BA7F);
  static const green600 = Color(0xFF28A960);
  static const green700 = Color(0xFF20874D);
  static const green800 = Color(0xFF18653A);

  // Red
  static const red050 = Color(0xFFFEEFEC);
  static const red100 = Color(0xFFFDD4CC);
  static const red200 = Color(0xFFFCBFB3);
  static const red300 = Color(0xFFFBA999);
  static const red400 = Color(0xFFFA7E66);
  static const red500 = Color(0xFFF85333);
  static const red600 = Color(0xFFF62800);
  static const red700 = Color(0xFFC52000);
  static const red800 = Color(0xFF941800);

  // Yellow
  static const yellow050 = Color(0xFFFFFBED);
  static const yellow100 = Color(0xFFFEF7DB);
  static const yellow200 = Color(0xFFFEF3C9);
  static const yellow300 = Color(0xFFFDEFB7);
  static const yellow400 = Color(0xFFFCE694);
  static const yellow500 = Color(0xFFFBDE70);
  static const yellow600 = Color(0xFFFAD64C);
  static const yellow700 = Color(0xFFCEB03D);
  static const yellow800 = Color(0xFFA28A2E);

  // Orange
  static const orange050 = Color(0xFFFFF7E6);
  static const orange100 = Color(0xFFFFE7BA);
  static const orange200 = Color(0xFFFFD591);
  static const orange300 = Color(0xFFFFC069);
  static const orange400 = Color(0xFFFFA940);
  static const orange500 = Color(0xFFFA8C16);
  static const orange600 = Color(0xFFD46808);
  static const orange700 = Color(0xFFAD4E00);
  static const orange800 = Color(0xFF873800);

  // Blue
  static const blue050 = Color(0xFFEFF4FE);
  static const blue100 = Color(0xFFCDE3FC);
  static const blue200 = Color(0xFFB7D5F7);
  static const blue300 = Color(0xFF9FC6F4);
  static const blue400 = Color(0xFF6FAAEF);
  static const blue500 = Color(0xFF3F8EEA);
  static const blue600 = Color(0xFF006AE5);
  static const blue700 = Color(0xFF005AC3);
  static const blue800 = Color(0xFF003D52);

  // static const Color blue50 = Color(0xFFEFF6FF);
  // static const Color blue500 = Color(0xFF3B82F6);
  // static const Color blue600 = Color(0xFF2563EB);
  // static const Color blue700 = Color(0xFF1D4ED8);

  // static const Color green50 = Color(0xFFF0FDF4);
  // static const Color green500 = Color(0xFF22C55E);
  // static const Color green600 = Color(0xFF16A34A);
  // static const Color green700 = Color(0xFF15803D);

  // static const Color red50 = Color(0xFFFEF2F2);
  // static const Color red500 = Color(0xFFEF4444);
  // static const Color red600 = Color(0xFFDC2626);
  // static const Color red700 = Color(0xFFB91C1C);

  // static const Color amber50 = Color(0xFFFFFBEB);
  // static const Color amber500 = Color(0xFFF59E0B);
  // static const Color amber600 = Color(0xFFD97706);
  // static const Color amber700 = Color(0xFFB45309);

  // static const Color orange50 = Color(0xFFFFF7ED);
  // static const Color orange500 = Color(0xFFF97316);
  // static const Color orange600 = Color(0xFFEA580C);
  // static const Color orange700 = Color(0xFFC2410C);

  // static const Color sky50 = Color(0xFFF0F9FF);
  // static const Color sky500 = Color(0xFF0EA5E9);
  // static const Color sky600 = Color(0xFF0284C7);
  // static const Color sky700 = Color(0xFF0369A1);
}
