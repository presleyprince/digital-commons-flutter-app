import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digital_shores/app/presentation/pages/plot/seaweed_information_card.dart';
import 'package:digital_shores/app/presentation/pages/plot/seaweed_information_dialog.dart';
import 'package:digital_shores/app/presentation/provider/auth_notifier.dart';
import 'package:digital_shores/app/presentation/widgets/global/transparent_app_bar.dart';
import 'package:digital_shores/core/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyPlotPage extends StatelessWidget {
  const MyPlotPage({super.key});

  CollectionReference<Map<String, dynamic>> get _collection =>
      FirebaseFirestore.instance.collection('seaweed_information');

  @override
  Widget build(BuildContext context) {
    final isSuperAdmin =
        Provider.of<AuthNotifier>(context, listen: false).isSuperAdmin();

    return Scaffold(
      appBar: TransparentAppBar(
        title: 'Rumput Laut',
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              kDefaultPadding,
              16,
              kDefaultPadding,
              8,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Informasi Rumput Laut',
                    style: kTitle4TextStyle,
                  ),
                ),
                if (isSuperAdmin)
                  ElevatedButton.icon(
                    onPressed: () => _addInformation(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah'),
                  ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: kDefaultPadding,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Pelajari informasi dasar tentang rumput laut, manfaatnya, dan panduan budidaya sederhana.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<
                QuerySnapshot<Map<String, dynamic>>>(
              stream: _collection.orderBy('order').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      'Gagal memuat informasi.',
                    ),
                  );
                }

                final documents = snapshot.data?.docs ?? [];

                if (documents.isEmpty) {
                  return Center(
                    child: Text(
                      isSuperAdmin
                          ? 'Belum ada informasi.\nTekan Tambah untuk membuat informasi.'
                          : 'Belum ada informasi.',
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                if (isSuperAdmin) {
                  return ReorderableListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: kDefaultPadding,
                    ),
                    itemCount: documents.length,
                    buildDefaultDragHandles: false,
                    onReorder: (oldIndex, newIndex) {
                      _reorderInformation(
                        documents,
                        oldIndex,
                        newIndex,
                      );
                    },
                    itemBuilder: (context, index) {
                      return _buildCard(
                        context,
                        documents[index],
                        index,
                        true,
                      );
                    },
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: kDefaultPadding,
                  ),
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    return _buildCard(
                      context,
                      documents[index],
                      index,
                      false,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(
    BuildContext context,
    QueryDocumentSnapshot<Map<String, dynamic>> document,
    int index,
    bool isSuperAdmin,
  ) {
    final data = document.data();

    final title = data['title']?.toString() ?? '';
    final content = data['content']?.toString() ?? '';
    final icon = data['icon']?.toString() ?? 'info';

    return SeaweedInformationCard(
      key: ValueKey(document.id),
      title: title,
      content: content,
      iconName: icon,
      isSuperAdmin: isSuperAdmin,
      dragIndex: index,
      onEdit: () {
        _editInformation(
          context,
          document.reference,
          title,
          content,
          icon,
        );
      },
      onDelete: () {
        _deleteInformation(
          context,
          document.reference,
          title,
        );
      },
    );
  }

  Future<void> _addInformation(
    BuildContext context,
  ) async {
    final result =
        await showDialog<Map<String, String>>(
      context: context,
      builder: (context) {
        return const SeaweedInformationDialog(
          dialogTitle: 'Tambah Informasi',
        );
      },
    );

    if (result == null) {
      return;
    }

    try {
      final lastDocument = await _collection
          .orderBy(
            'order',
            descending: true,
          )
          .limit(1)
          .get();

      int nextOrder = 0;

      if (lastDocument.docs.isNotEmpty) {
        final data =
            lastDocument.docs.first.data();

        final currentOrder =
            data['order'];

        if (currentOrder is num) {
          nextOrder =
              currentOrder.toInt() + 1;
        }
      }

      await _collection.add({
        'title': result['title'],
        'content': result['content'],
        'icon': result['icon'],
        'order': nextOrder,
      });

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Informasi berhasil ditambahkan.',
          ),
        ),
      );
    } catch (e) {
      debugPrint(
        'Add information error: $e',
      );

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Gagal menambahkan informasi.',
          ),
        ),
      );
    }
  }

  Future<void> _editInformation(
    BuildContext context,
    DocumentReference<Map<String, dynamic>> reference,
    String title,
    String content,
    String icon,
  ) async {
    final result =
        await showDialog<Map<String, String>>(
      context: context,
      builder: (context) {
        return SeaweedInformationDialog(
          dialogTitle: 'Edit Informasi',
          initialTitle: title,
          initialContent: content,
          initialIcon: icon,
        );
      },
    );

    if (result == null) {
      return;
    }

    try {
      await reference.update({
        'title': result['title'],
        'content': result['content'],
        'icon': result['icon'],
      });
    } catch (e) {
      debugPrint(
        'Edit information error: $e',
      );
    }
  }

  Future<void> _deleteInformation(
    BuildContext context,
    DocumentReference<Map<String, dynamic>> reference,
    String title,
  ) async {
    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Hapus Informasi',
          ),
          content: Text(
            'Hapus "$title"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await reference.delete();
    }
  }

  Future<void> _reorderInformation(
    List<QueryDocumentSnapshot<Map<String, dynamic>>>
        documents,
    int oldIndex,
    int newIndex,
  ) async {
    if (newIndex > oldIndex) {
      newIndex--;
    }

    if (oldIndex == newIndex) {
      return;
    }

    final reordered =
        List<QueryDocumentSnapshot<Map<String, dynamic>>>.from(
      documents,
    );

    final moved =
        reordered.removeAt(oldIndex);

    reordered.insert(
      newIndex,
      moved,
    );

    final batch =
        FirebaseFirestore.instance.batch();

    for (int i = 0;
        i < reordered.length;
        i++) {
      batch.update(
        reordered[i].reference,
        {
          'order': i,
        },
      );
    }

    await batch.commit();
  }
}