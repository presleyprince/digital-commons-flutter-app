import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class VerifyPlotsPage extends StatelessWidget {
  const VerifyPlotsPage({super.key});

  Future<void> _verifyPlot(String documentId) async {
    await FirebaseFirestore.instance
        .collection('plot_forms')
        .doc(documentId)
        .update({
      'status': 'VERIFIED',
      'verified_at': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verifikasi Lahan'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('plot_forms')
            .orderBy('submitted_at', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading plots: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final plots = snapshot.data?.docs ?? [];

          if (plots.isEmpty) {
            return const Center(
              child: Text('Tidak ada lahan yang menunggu verifikasi.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: plots.length,
            itemBuilder: (context, index) {
              final doc = plots[index];
              final data = doc.data() as Map<String, dynamic>;
              final status = data['status'] ?? 'PENDING';
              final isVerified = status == 'VERIFIED';

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['owner_name'] ?? 'Unknown owner',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text('Address: ${data['owner_address'] ?? '-'}'),
                      Text('Seaweed: ${data['type_of_seaweed'] ?? '-'}'),
                      Text('Status: $status'),
                      const SizedBox(height: 12),
                      if (!isVerified)
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.verified),
                          label: const Text('Verifikasi'),
                          onPressed: () async {
                            await _verifyPlot(doc.id);

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Lahan berhasil diverifikasi'),
                                ),
                              );
                            }
                          },
                        ),
                      )
                      else
                      const Align(
                        alignment: Alignment.centerRight,
                        child: Chip(
                          label: Text('VERIFIED'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
