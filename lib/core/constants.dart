import 'package:digital_shores/app/domain/entities/home_menu.dart';
import 'package:digital_shores/const/resource.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

const kWhiteColor = Color(0xffFFFFFF);
const kGreyColor = Color(0xff8C8C8C);
const kLightGreyColor = Color(0xffD2D2D2);
const kDefaultErrorColor = Color(0xffB00020);
const kRedColor = Color(0xffBC4545);
const kYellowColor = Color(0xffBCB645);
const kGreenColor = Color(0xff24693B);

const kBlueColor = Color(0xff5B76CE);

const kAppName = 'Ruang Pesisir';

const kHelpUrl = 'https://chat.whatsapp.com/D7JXWVUnp3tDUfej0pjobh';
const kSeaDiscussionUrl = 'https://chat.whatsapp.com/F2UsOVWVnHMGrGXhZxxGIE';
const kTermsUrl = 'https://doc-hosting.flycricket.io/digital-shores/c3a4b67d-0544-4d31-b832-3ad1e5f48c83/terms';

const kConnectionFailTitle = "Sambungan Terputus";
const kConnectionFailMessage = "Sambungkan ponsel Anda dengan jaringan internet";

const kFontweightBold = FontWeight.w700;
const kFontweightSemiBold = FontWeight.w600;
const kFontweightMedium = FontWeight.w500;
const kFontweightRegular = FontWeight.w400;
const kFontweightLight = FontWeight.w300;

const kDefaultPadding = 24.0;
const kDefaultRadius = 12.0;

const kTimeoutDuration = Duration(seconds: 5);

final kTimeoutException = ClientException('Tidak dapat terhubung ke server');

final List<HomeMenu> kHomeMenu = [
  HomeMenu(
    image: R.ASSETS_ICONS_MY_DOCUMENT_PNG,
    title: 'DokumenKu',
    route: 'administration',
  ),
// removed Bincang Laut, becoming merged to Informasi
  HomeMenu(
    image: R.ASSETS_ICONS_INFORMATION_PNG,
    title: 'Informasi',
    route: 'information',
  ),
  HomeMenu(
    image: R.ASSETS_ICONS_MY_PLOT_PNG,
    title: 'LahanKu',
    route: 'my-plot',
  ),
  HomeMenu(
    image: R.ASSETS_ICONS_MY_FINANCIAL_PNG,
    title: 'KeuanganKu',
    route: 'my-finance',
  ),
  HomeMenu(
    image: R.ASSETS_ICONS_SEAWEED_HOME_PNG, // need to update icon
    title: 'Rumput Laut', //change to Indonesian
    route: 'seaweed-home',
  ),
  // removed Cuaca, now a widget
];

const kOccupation = [
  "Nelayan/Petani",
  "Pengepul/Pengusaha",
  "Wirausaha",
  "Ibu Rumah Tangga",
  "Pelajar",
  "Lainnya",
];

const kCollections = [
  'finance_logs',
  'administration_documents',
];

const kTitle7TextStyle = TextStyle(
  fontSize: 14,
  fontWeight: kFontweightBold,
);

const kTitle6TextStyle = TextStyle(
  fontSize: 16,
  fontWeight: kFontweightBold,
);

const kTitle5TextStyle = TextStyle(
  fontSize: 18,
  fontWeight: kFontweightBold,
);

const kTitle4TextStyle = TextStyle(
  fontSize: 20,
  fontWeight: kFontweightBold,
);

const kTitle3TextStyle = TextStyle(
  fontSize: 24,
  fontWeight: kFontweightBold,
);

const kTitle2TextStyle = TextStyle(
  fontSize: 28,
  fontWeight: kFontweightBold,
);

const kTitle1TextStyle = TextStyle(
  fontSize: 32,
  fontWeight: kFontweightBold,
);

const kSubtitle6TextStyle = TextStyle(
  fontSize: 14,
  fontWeight: kFontweightRegular,
);

const kSubtitle5TextStyle = TextStyle(
  fontSize: 16,
  fontWeight: kFontweightRegular,
);

const kSubtitle4TextStyle = TextStyle(
  fontSize: 18,
  fontWeight: kFontweightRegular,
);

const kSubtitle3TextStyle = TextStyle(
  fontSize: 20,
  fontWeight: kFontweightRegular,
);

const kSubtitle2TextStyle = TextStyle(
  fontSize: 24,
  fontWeight: kFontweightRegular,
);

const kSubtitle1TextStyle = TextStyle(
  fontSize: 28,
  fontWeight: kFontweightRegular,
);

const kBodyTextStyle = TextStyle(
  fontSize: 16,
  fontWeight: kFontweightRegular,
);

const kLight7TextStyle = TextStyle(
  fontSize: 14,
  fontWeight: kFontweightLight,
);

const kLight6TextStyle = TextStyle(
  fontSize: 16,
  fontWeight: kFontweightLight,
);
