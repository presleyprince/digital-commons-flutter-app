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
        title: const Text('Verifikasi Lahan'), //verify plots
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('plot_forms')
            .orderBy('submitted_at', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Gagal memuat lahan: ${snapshot.error}'), //error loading plots/farms
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final plots = snapshot.data?.docs ?? [];

          if (plots.isEmpty) {
            return const Center(
              child: Text('Tidak ada lahan yang menunggu verifikasi.'), //no plots waiting for verification 
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
                        data['owner_name'] ?? 'Pemilik tidak diketahui', //unknown owner
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text('Alamat: ${data['owner_address'] ?? '-'}'), //address
                      Text('Rumput Laut: ${data['type_of_seaweed'] ?? '-'}'), //seaweed
                      Text('Status: $status'), //status, same as english
                      const SizedBox(height: 12),
                      if (!isVerified)
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.verified),
                          label: const Text('Verifikasi'), //verify
                          onPressed: () async {
                            await _verifyPlot(doc.id);

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Lahan terverifikasi'), //plot verified
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
                          label: Text('TERVERIFIKASI'), //VERIFIED
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