import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF00787A);
  static const Color background = Colors.white;
  static const Color border = Color(0xFFD8D8D8);
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF7A7A7A);
  static const Color disabled = Color(0xFFD8D8D8);

  static const Color badgeKonserwowe = Color(0xFFADADAD);
  static const Color badgeOwoce = Color(0xFFDD0000);
  static const Color badgeWarzywa = Color(0xFF1B7C00);
  static const Color badgeNabial = Color(0xFFEBEBEB);
  static const Color badgeMrozniki = Color(0xFF0088F0);
  static const Color badgeMieso = Color(0xFF9E0003);
  static const Color badgeSypkie = Color(0xFFFFD900);
  static const Color badgePieczywo = Color(0xFFFF9000);
  static const Color badgeSodycze = Color(0xFFCB009C);
  static const Color badgeTluszcze = Color(0xFF7BA002);

  static Color badgeColor(String? category) {
    switch (category?.toLowerCase()) {
      case 'konserwowe': return badgeKonserwowe;
      case 'owoce': return badgeOwoce;
      case 'warzywa': return badgeWarzywa;
      case 'nabiał': return badgeNabial;
      case 'mrożonki': return badgeMrozniki;
      case 'mięso': return badgeMieso;
      case 'sypkie': return badgeSypkie;
      case 'pieczywo': return badgePieczywo;
      case 'słodycze': return badgeSodycze;
      case 'tłuszcze': return badgeTluszcze;
      default: return badgeKonserwowe;
    }
  }

  static Color badgeTextColor(String? category) {
    switch (category?.toLowerCase()) {
      case 'nabiał': return textSecondary;
      case 'sypkie': return textPrimary;
      default: return Colors.white;
    }
  }
}
