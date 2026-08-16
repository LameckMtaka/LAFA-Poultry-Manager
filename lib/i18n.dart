class AppI18n {
  static String tr(String lang, String sw, String en) => lang == 'en' ? en : sw;
}
