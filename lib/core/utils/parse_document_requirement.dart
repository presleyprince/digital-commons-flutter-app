import 'package:digital_shores/core/enums.dart';

class ParseDocumentRequirement {
  static String toText(DocumentRequirement? requirement) {
    switch (requirement) {
      case DocumentRequirement.suratRekomendasiBbm:
        return 'Surat Rekomendasi BBM';
      case DocumentRequirement.pasKecil:
        return 'Pas Kecil';
      case DocumentRequirement.tdkp:
        return 'TDKP (Tanda Daftar Kapal Perikanan)';
      case DocumentRequirement.kusuka:
        return 'KUSUKA (Kartu Pelaku Usaha Kelautan dan Perikanan)';
      case DocumentRequirement.nib:
        return 'NIB (Nomor Induk Berusaha)';
      default:
        return '-';
    }
  }
}
