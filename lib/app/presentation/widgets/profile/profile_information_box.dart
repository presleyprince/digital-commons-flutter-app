import 'package:digital_shores/app/presentation/provider/auth_notifier.dart';
import 'package:digital_shores/app/presentation/widgets/global/primary_elevated_button.dart';
import 'package:digital_shores/app/presentation/widgets/profile/profile_user_data_tile.dart';
import 'package:digital_shores/const/resource.dart';
import 'package:digital_shores/core/constants.dart';
import 'package:digital_shores/core/utils/parse_occupation.dart';
import 'package:digital_shores/router.dart';
import 'package:flutter/material.dart';

class ProfileInformationBox extends StatelessWidget {
  const ProfileInformationBox({
    super.key,
    required this.notifier,
  });

  final AuthNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: color.primary),
        borderRadius: BorderRadius.circular(kDefaultRadius),
      ),
      padding: const EdgeInsets.all(kDefaultPadding / 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfileUserDataTile(title: 'Nama Lengkap', value: notifier.userData?.fullName),
          ProfileUserDataTile(title: 'Nomor Handphone', value: notifier.userData?.phoneNumber),
          ProfileUserDataTile(
              title: 'Pekerjaan', value: ParseOccupation.toText(notifier.userData?.occupation)),
          ProfileUserDataTile(title: 'Alamat', value: notifier.userData?.address),
          ProfileUserDataTile(
              title: 'Nama Kelompok Tani/Nelayan', value: notifier.userData?.groupName),
          ProfileUserDataTile(title: 'Nama Penyuluh', value: notifier.userData?.instructorName),
          PrimaryElevatedButton(
            text: 'Edit',
            image: R.ASSETS_ICONS_EDIT_PNG,
            onPressed: () => router.go('/profile/edit'),
          ),
        ],
      ),
    );
  }
}
