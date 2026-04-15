import 'package:digital_shores/core/enums.dart';

class ParseOccupation {
  static String toText(Occupation? occupation) {
    switch (occupation) {
      case Occupation.fishermanOrFarmer:
        return 'Nelayan/Petani';
      case Occupation.collectorOrEntrepreneur:
        return 'Pengepul/Pengusaha';
      case Occupation.entrepreneur:
        return 'Wirausaha';
      case Occupation.housewife:
        return 'Ibu Rumah Tangga';
      case Occupation.student:
        return 'Pelajar';
      case Occupation.other:
        return 'Lainnya';
      default:
        return '-';
    }
  }

  static Occupation? toEnum(String text) {
    switch (text) {
      case 'Nelayan/Petani':
        return Occupation.fishermanOrFarmer;
      case 'Pengepul/Pengusaha':
        return Occupation.collectorOrEntrepreneur;
      case 'Wirausaha':
        return Occupation.entrepreneur;
      case 'Ibu Rumah Tangga':
        return Occupation.housewife;
      case 'Pelajar':
        return Occupation.student;
      case 'Lainnya':
        return Occupation.other;
      default:
        return null;
    }
  }
}
