import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digital_shores/app/presentation/pages/plot/seaweed_information_card.dart';
import 'package:digital_shores/app/presentation/pages/plot/seaweed_information_dialog.dart';
import 'package:digital_shores/app/presentation/provider/auth_notifier.dart';
import 'package:digital_shores/app/presentation/widgets/global/transparent_app_bar.dart';
import 'package:digital_shores/core/constants.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
              stream: _collection
                  .orderBy('order')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  debugPrint(
                    'Seaweed information error: '
                    '${snapshot.error}',
                  );

                  return const Center(
                    child: Text(
                      'Gagal memuat informasi.',
                    ),
                  );
                }

                final documents =
                    snapshot.data?.docs ?? [];

                if (documents.isEmpty) {
                  return Center(
                    child: Text(
                      isSuperAdmin
                          ? 'Belum ada informasi.\n'
                              'Tekan Tambah untuk membuat informasi.'
                          : 'Belum ada informasi.',
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                // Super Admin can reorder cards.
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

                // Normal users can only view the cards.
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

  // ------------------------------------------------------------
  // BUILD INFORMATION CARD
  // ------------------------------------------------------------

  Widget _buildCard(
    BuildContext context,
    QueryDocumentSnapshot<Map<String, dynamic>>
        document,
    int index,
    bool isSuperAdmin,
  ) {
    final data = document.data();

    final title =
        data['title']?.toString() ?? '';

    final content =
        data['content']?.toString() ?? '';

    final imageUrl =
        data['imageUrl']?.toString() ?? '';

    return SeaweedInformationCard(
      key: ValueKey(document.id),
      title: title,
      content: content,
      imageUrl: imageUrl,
      isSuperAdmin: isSuperAdmin,
      dragIndex: index,

      // EDIT
      onEdit: () {
        _editInformation(
          context,
          document.reference,
          title,
          content,
          imageUrl,
        );
      },

      // DELETE
      onDelete: () {
        _deleteInformation(
          context,
          document.reference,
          title,
          imageUrl,
        );
      },
    );
  }

  // ------------------------------------------------------------
  // UPLOAD IMAGE TO FIREBASE STORAGE
  // ------------------------------------------------------------

  Future<String> _uploadImage(
    XFile image,
  ) async {
    final Uint8List bytes =
        await image.readAsBytes();

    // Give every uploaded image a unique name.
    final String fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${image.name}';

    final Reference storageReference =
        FirebaseStorage.instance
            .ref()
            .child('seaweed_information')
            .child(fileName);

    // Upload the selected image.
    await storageReference.putData(
      bytes,
      SettableMetadata(
        contentType:
            image.mimeType ?? 'image/jpeg',
      ),
    );

    // Get the URL used by the Flutter app
    // to display the image.
    final String downloadUrl =
        await storageReference
            .getDownloadURL();

    return downloadUrl;
  }

  // ------------------------------------------------------------
  // ADD INFORMATION
  // ------------------------------------------------------------

  Future<void> _addInformation(
    BuildContext context,
  ) async {
    final result =
        await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return const SeaweedInformationDialog(
          dialogTitle: 'Tambah Informasi',
        );
      },
    );

    // User pressed Cancel.
    if (result == null) {
      return;
    }

    try {
      final XFile? selectedImage =
          result['image'] as XFile?;

      if (selectedImage == null) {
        if (!context.mounted) {
          return;
        }

        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              'Silakan pilih gambar.',
            ),
          ),
        );

        return;
      }

      // 1. Upload image to Firebase Storage.
      final String imageUrl =
          await _uploadImage(
        selectedImage,
      );

      // 2. Find the current highest order.
      final lastDocument =
          await _collection
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

      // 3. Save information to Firestore.
      await _collection.add({
        'title': result['title'],
        'content': result['content'],
        'imageUrl': imageUrl,
        'order': nextOrder,
      });

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
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

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Gagal menambahkan informasi.',
          ),
        ),
      );
    }
  }

  // ------------------------------------------------------------
  // EDIT INFORMATION
  // ------------------------------------------------------------

  Future<void> _editInformation(
    BuildContext context,
    DocumentReference<Map<String, dynamic>>
        reference,
    String title,
    String content,
    String currentImageUrl,
  ) async {
    final result =
        await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return SeaweedInformationDialog(
          dialogTitle: 'Edit Informasi',
          initialTitle: title,
          initialContent: content,
          initialImageUrl:
              currentImageUrl,
        );
      },
    );

    // User pressed Cancel.
    if (result == null) {
      return;
    }

    try {
      // Keep existing image by default.
      String imageUrl =
          currentImageUrl;

      final XFile? newImage =
          result['image'] as XFile?;

      // If Super Admin selected a new image,
      // upload it and replace the old URL.
      if (newImage != null) {
      imageUrl = await _uploadImage(
        newImage,
        );
      }

      // Update Firestore.
      await reference.update({
        'title': result['title'],
        'content': result['content'],
        'imageUrl': imageUrl,
      });

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Informasi berhasil diperbarui.',
          ),
        ),
      );
    } catch (e) {
      debugPrint(
        'Edit information error: $e',
      );

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Gagal memperbarui informasi.',
          ),
        ),
      );
    }
  }

  // ------------------------------------------------------------
  // DELETE INFORMATION
  // ------------------------------------------------------------

  Future<void> _deleteInformation(
    BuildContext context,
    DocumentReference<Map<String, dynamic>>
        reference,
    String title,
    String imageUrl,
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
              child: const Text(
                'Batal',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              child: const Text(
                'Hapus',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      // Delete Firestore document.
      await reference.delete();

      // Delete associated image from
      // Firebase Storage.
      if (imageUrl.isNotEmpty) {
        await _deleteImageFromStorage(
          imageUrl,
        );
      }

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Informasi berhasil dihapus.',
          ),
        ),
      );
    } catch (e) {
      debugPrint(
        'Delete information error: $e',
      );

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Gagal menghapus informasi.',
          ),
        ),
      );
    }
  }

  // ------------------------------------------------------------
  // DELETE IMAGE FROM FIREBASE STORAGE
  // ------------------------------------------------------------

  Future<void> _deleteImageFromStorage(
    String imageUrl,
  ) async {
    if (imageUrl.isEmpty) {
      return;
    }

    try {
      final Reference imageReference =
          FirebaseStorage.instance
              .refFromURL(imageUrl);

      await imageReference.delete();
    } catch (e) {
      // Do not stop the whole operation if
      // an old image cannot be deleted.
      debugPrint(
        'Delete Storage image error: $e',
      );
    }
  }

  // ------------------------------------------------------------
  // REORDER INFORMATION
  // ------------------------------------------------------------

  Future<void> _reorderInformation(
    List<
            QueryDocumentSnapshot<
                Map<String, dynamic>>>
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

    final reordered = List<
        QueryDocumentSnapshot<
            Map<String, dynamic>>>.from(
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

    try {
      await batch.commit();
    } catch (e) {
      debugPrint(
        'Reorder information error: $e',
      );
    }
  }
}