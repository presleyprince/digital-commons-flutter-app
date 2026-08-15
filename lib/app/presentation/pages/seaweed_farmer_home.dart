import 'package:flutter/material.dart';
import 'package:digital_shores/core/constants.dart';
import 'package:go_router/go_router.dart';
import 'package:digital_shores/app/presentation/provider/auth_notifier.dart'; // added to ensure only admins/secretaries ccan access the page
import 'package:provider/provider.dart';

class SeaweedFarmerHome extends StatelessWidget {
  const SeaweedFarmerHome({super.key});

  @override
  Widget build(BuildContext context) {
    // check if the current user is an admin? (used below to decide whether to show the 4th tile)
    final isAdmin =
        Provider.of<AuthNotifier>(context, listen: false).isAdmin();

    // GRID style instead, to match the home page (one is hidden for admin)
    final tiles = <_SeaweedMenuItem>[
      _SeaweedMenuItem(
        icon: Icons.add_location_alt,
        label: 'Peternakan rumput laut baru', // new seaweed farm
        onTap: () => context.push('/home/gps-test'),
      ),
      _SeaweedMenuItem(
        icon: Icons.grid_view_outlined,
        label: 'Ladang rumput laut saya', // my seaweed farms
        onTap: () => context.push('/home/plot-overview'),
      ),
      _SeaweedMenuItem(
        icon: Icons.task_alt,
        label: 'Pilih peternakan rumput laut untuk memverifikasi', // choose seaweed farm to verify
        onTap: () => context.push('/home/saved-plots'),
      ),
      if (isAdmin) // only admins/secretaries see this tile
        _SeaweedMenuItem(
          icon: Icons.verified_user,
          label: 'Verifikasi Lahan', // verify plots
          onTap: () => context.push('/verify-plots'),
        ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rumput Laut'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              const Text(
                'Rekamlah peternakan rumput laut Anda', //record your seaweed farm
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Kelola dan pantau pertanian rumput laut Anda.', //manage and see your seaweed farms
              ),
              const SizedBox(height: 24),

              // Grid Buttons
              GridView.builder(
                shrinkWrap: true, // grid will size itself to its content
                physics: const NeverScrollableScrollPhysics(), // page already scrolls if needed
                itemCount: tiles.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 1 tile per row
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.95, 
                ),
                itemBuilder: (context, index) {
                  final tile = tiles[index];
                  return _SeaweedMenuTile(item: tile);
                },
              ),
              //
            ],
          ),
        ),
      ),
    );
  }
}

///  what icon+text to show, and what to do when it's tapped.
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

/// a colored circle with an icon, and a label below it.
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