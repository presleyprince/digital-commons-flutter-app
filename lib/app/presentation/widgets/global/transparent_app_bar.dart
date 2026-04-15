import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TransparentAppBar extends StatelessWidget implements PreferredSizeWidget {
  const TransparentAppBar({
    super.key,
    this.title,
    this.onBack,
    this.actions,
  });

  final String? title;
  final Function()? onBack;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: true,
      leading: onBack != null
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black), // Pastikan ikon terlihat
              onPressed: onBack,
            )
          : null,
      backgroundColor: Colors.transparent,
      elevation: 0, // Pastikan tidak ada shadow
      title: title == null
          ? null
          : Text(title!, style: const TextStyle(color: Colors.black)), // Pastikan teks terlihat
      actions: actions,
      systemOverlayStyle: SystemUiOverlayStyle.dark, // Pastikan status bar tetap gelap
    );
  }
}
