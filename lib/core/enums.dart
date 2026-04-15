enum RequestState {
  initial,
  loading,
  success,
  error,
}

enum Occupation {
  fishermanOrFarmer,
  collectorOrEntrepreneur,
  entrepreneur,
  extensionWorker,
  housewife,
  student,
  other,
}

enum FinanceLogCategory {
  expense('Pengeluaran'),
  loan('Pinjaman'),
  income('Pendapatan');

  final String label;
  const FinanceLogCategory(this.label);
}

enum FinanceHistoryRangeType {
  today,
  thisWeek,
  thisMonth,
  customMonth,
}

enum DocumentType {
  ktp('KTP (Kartu Tanda Penduduk)'),
  kk('KK (Kartu Keluarga)'),
  kusuka('KUSUKA (Kartu Pelaku Usaha Kelautan dan Perikanan)'),
  pasKecil('Pas Kecil'),
  tdkp('TDKP (Tanda Daftar Kapal Perikanan)'),
  suratRekomendasi('Surat Rekomendasi Dinas Perikanan'),
  npwp('NPWP'),
  nib('NIB'),
  cekFisik('Cek Fisik Kapal'),
  bpjs('BPJS Ketenagakerjaan'),
  suratIllegalFishing('Surat Pernyataan Tidak Melakukan Illegal Fishing'),
  suratKuasa('Surat Kuasa bagi yang Menguasakan'),
  suratPengukuran('Surat Permohonan Pengukuran Kapal'),
  suratBuktiKapal('Surat Bukti Hak Milik atas Kapal'),
  suratKeteranganGalangan(
      'Surat Keterangan Tukang untuk Kapal yang Dibuat di Galangan Tradisional'),
  other('Lainnya');

  final String label;
  const DocumentType(this.label);
}

enum DocumentRequirement {
  suratRekomendasiBbm('Surat Rekomendasi BBM'),
  pasKecil('Pas Kecil'),
  tdkp('TDKP'),
  kusuka('KUSUKA'),
  nib('NIB');

  final String label;
  const DocumentRequirement(this.label);
}

enum InformationCategory {
  regulation('Peraturan/Perizinan'),
  scholarship('Beasiswa'),
  news('Berita'),
  helps('Bantuan');

  final String label;
  const InformationCategory(this.label);
}

enum WeatherRegionCode {
  barrangCaddi('Kelurahan Barrang Caddi', '73.71.15.1001'),
  galesongKota('Desa Galesong Kota', '73.05.09.2002'),
  kalukubodo('Desa Kalukubodo', '73.05.05.2017'),
  laikang('Desa Laikang', '73.05.02.2005');

  final String region;
  final String regionCode;
  const WeatherRegionCode(this.region, this.regionCode);
}