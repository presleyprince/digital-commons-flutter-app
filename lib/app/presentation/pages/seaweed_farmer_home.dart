import 'package:flutter/material.dart';
import 'package:digital_shores/core/constants.dart';
import 'package:go_router/go_router.dart';
import 'package:digital_shores/app/presentation/provider/auth_notifier.dart';
import 'package:provider/provider.dart';

class SeaweedFarmerHome extends StatelessWidget {
  const SeaweedFarmerHome({super.key});

  @override
  Widget build(BuildContext context) {
    final isAdmin =
    Provider.of<AuthNotifier>(context, listen: false).isAdmin();

    final tiles = <_SeaweedMenuItem>[
      _SeaweedMenuItem(
        icon: Icons.add_location_alt,
        label: 'Lahan baru',
        onTap: () => context.push('/home/gps-test'),
      ),
      _SeaweedMenuItem(
        icon: Icons.grid_view_outlined,
        label: 'Lahan saya',
        onTap: () => context.push('/home/plot-overview'),
      ),
      if (isAdmin)
        _SeaweedMenuItem(
          icon: Icons.task_alt,
          label: 'Pilih lahan untuk memverifikasi',
          onTap: () => context.push('/home/saved-plots'),
        ),
      if (isAdmin)
        _SeaweedMenuItem(
          icon: Icons.verified_user,
          label: 'Verifikasi Lahan',
          onTap: () => context.push('/verify-plots'),
        ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('LahanKu'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              const Text(
                'Rekam dan kelola lahan Anda',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text('Kelola dan pantau data lahan Anda.'),
              const SizedBox(height: 24),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: tiles.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.95,
                ),
                itemBuilder: (context, index) {
                  final tile = tiles[index];
                  return _SeaweedMenuTile(item: tile);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SeaweedMenuItem {
  const _SeaweedMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
}

class _SeaweedMenuTile extends StatelessWidget {
  const _SeaweedMenuTile({required this.item});

  final _SeaweedMenuItem item;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(kDefaultRadius),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(kDefaultRadius),
          border: Border.all(color: color.primary.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: color.primary,
              child: Icon(item.icon, color: color.onPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              item.label,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: kTitle7TextStyle,
            ),
          ],
        ),
      ),
    );
  }
}