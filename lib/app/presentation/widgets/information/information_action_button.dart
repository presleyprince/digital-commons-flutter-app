import 'package:digital_shores/app/presentation/provider/auth_notifier.dart';
import 'package:digital_shores/app/presentation/provider/information_notifier.dart';
import 'package:digital_shores/app/presentation/widgets/global/loading_indicator.dart';
import 'package:digital_shores/app/presentation/widgets/global/primary_elevated_button.dart';
import 'package:digital_shores/core/constants.dart';
import 'package:digital_shores/core/utils/custom_snackbar.dart';
import 'package:digital_shores/router.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class InformationActionButton extends StatelessWidget {
  const InformationActionButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: kDefaultPadding),
      child: Column(
        children: [
          Consumer<InformationNotifier>(builder: (context, notifier, child) {
            final state = notifier.syncDataState;
            if (state.stateLoading()) {
              return const LoadingIndicator();
            } else if (state.stateError()) {
              CustomSnackbar.alert(context, state.failure!.message);
            } else if (state.stateSuccess()) {
              CustomSnackbar.success(
                context,
                'Berhasil menyinkronkan data',
              );
            }
            return PrimaryElevatedButton(
              text: 'Segarkan',
              onPressed: Provider.of<InformationNotifier>(context, listen: false).syncData,
            );
          }),
          const SizedBox(height: 12),
          Consumer<AuthNotifier>(
            builder: (context, authNotifier, child) {
              return authNotifier.isAdmin()
                  ? PrimaryElevatedButton(
                      text: 'Tambah Informasi',
                      onPressed: () => router.push('/information/add'),
                      
                    )
                  : const SizedBox();
            },
          ),
        ],
      ),
    );
  }
}
