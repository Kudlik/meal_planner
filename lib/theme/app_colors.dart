import 'package:flutter/material.dart';

class AppColors {
  // ── Backgrounds & surfaces ────────────────────────────────────────────────
  static const Color background   = Color(0xFF1E1B13); // dark warm black
  static const Color surface      = Color(0xFF2C4E37); // forest green — meal cards, drawers
  static const Color surfaceLight = Color(0xFF44664E); // lighter green — hover / secondary
  static const Color primary      = surface;           // alias — use surface in new code

  // ── Accent (gold / cream) ─────────────────────────────────────────────────
  static const Color accent        = Color(0xFFDDC66E); // warm gold — primary buttons, selected
  static const Color accentSurface = Color(0xFFF7F0E2); // very light cream — nav bar bg
  static const Color accentMid     = Color(0xFFEFE2BC); // medium cream
  static const Color accentBright  = Color(0xFFFAE287); // bright yellow

  // ── Text ──────────────────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFFFFFFFF); // white — on dark background
  static const Color textSecondary = Color(0xFF7C7767); // warm gray — secondary on dark
  static const Color textOnAccent  = Color(0xFF675E40); // Schemes/Secondary — on gold/cream surfaces
  static const Color textLabel     = Color(0xFF6E5D0E); // Schemes/Primary — labels on accent surfaces
  static const Color textDark      = Color(0xFF333027); // near-black — on light surfaces
  static const Color textOnCard    = Color(0xFFC5ECCD); // mint — icons & labels on green cards

  // ── UI chrome ─────────────────────────────────────────────────────────────
  static const Color border         = Color(0xFFCDC6B4); // Schemes/Outline — warm gray border
  static const Color borderNeutral  = Color(0xFFD8D8D8); // Border — neutral gray, disabled badge bg
  static const Color disabled       = Color(0xFF9B9B9B); // Disabled font — gray text
  static const Color backdrop       = Color(0xB21E1B13); // dark bg at 70% — modal backdrop

  // ── Category badge fills ──────────────────────────────────────────────────
  static const Color badgeKonserwowe = Color(0xFFADADAD);
  static const Color badgeOwoce      = Color(0xFFDD0000);
  static const Color badgeWarzywa    = Color(0xFF1B7C00);
  static const Color badgeNabial     = Color(0xFFEBEBEB);
  static const Color badgeMrozniki   = Color(0xFF0088F0);
  static const Color badgeMieso      = Color(0xFF9E0003);
  static const Color badgeSypkie     = Color(0xFFFAE287);
  static const Color badgePieczywo   = Color(0xFFFF9000);
  static const Color badgeSodycze    = Color(0xFFCB009C);
  static const Color badgeTluszcze   = Color(0xFF7BA002);
  static const Color badgeHigiena    = Color(0xFF00787A);

  static Color badgeColor(String? category) {
    switch (category?.toLowerCase()) {
      case 'konserwowe': return badgeKonserwowe;
      case 'owoce':      return badgeOwoce;
      case 'warzywa':    return badgeWarzywa;
      case 'nabiał':     return badgeNabial;
      case 'mrożonki':   return badgeMrozniki;
      case 'mięso':      return badgeMieso;
      case 'sypkie':     return badgeSypkie;
      case 'pieczywo':   return badgePieczywo;
      case 'słodycze':   return badgeSodycze;
      case 'tłuszcze':   return badgeTluszcze;
      case 'higiena':    return badgeHigiena;
      default:           return badgeKonserwowe;
    }
  }

  static Color badgeTextColor(String? category) {
    switch (category?.toLowerCase()) {
      case 'nabiał':      return textDark;
      case 'sypkie':      return textDark;
      case 'tłuszcze':    return const Color(0xFF000000);
      case 'pieczywo':    return const Color(0xFF000000);
      case 'konserwowe':  return const Color(0xFF000000);
      default:         return Colors.white;
    }
  }
}
