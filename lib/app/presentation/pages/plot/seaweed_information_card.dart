import 'package:digital_shores/core/constants.dart';
import 'package:flutter/material.dart';

class SeaweedInformationCard extends StatelessWidget {
  const SeaweedInformationCard({
    super.key,
    required this.title,
    required this.content,
    required this.imageUrl,
    required this.isSuperAdmin,
    required this.dragIndex,
    required this.onEdit,
    required this.onDelete,
  });

  final String title;
  final String content;
  final String imageUrl;
  final bool isSuperAdmin;
  final int dragIndex;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final primaryColor =
        Theme.of(context).colorScheme.primary;

    return Container(
      margin: const EdgeInsets.only(
        bottom: 16,
      ),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: primaryColor.withOpacity(0.35),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Uploaded image
          if (imageUrl.isNotEmpty)
            Image.network(
              imageUrl,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (
                context,
                error,
                stackTrace,
              ) {
                return _imagePlaceholder();
              },
            )
          else
            _imagePlaceholder(),

          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: kTitle6TextStyle,
                      ),
                    ),

                    if (isSuperAdmin)
                      ReorderableDragStartListener(
                        index: dragIndex,
                        child: const Padding(
                          padding: EdgeInsets.all(8),
                          child: Icon(
                            Icons.drag_handle,
                            color: Colors.grey,
                          ),
                        ),
                      ),

                    if (isSuperAdmin)
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            onEdit();
                          }

                          if (value == 'delete') {
                            onDelete();
                          }
                        },
                        itemBuilder: (context) =>
                            const [
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete),
                                SizedBox(width: 8),
                                Text('Hapus'),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),

                const SizedBox(height: 8),

                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      height: 180,
      width: double.infinity,
      color: Colors.grey.shade200,
      child: const Center(
        child: Icon(
          Icons.image_outlined,
          size: 55,
          color: Colors.grey,
        ),
      ),
    );
  }
}