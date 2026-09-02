import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digital_shores/core/enums.dart';
import 'package:digital_shores/core/utils/path_guard.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ManageUsersPage extends StatefulWidget {
  const ManageUsersPage({super.key});

  @override
  State<ManageUsersPage> createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage> {
  // Stores the temporarily selected role for each user.
  // Key = Firestore user document ID
  // Value = selected role index
  final Map<String, int> selectedRoles = {};

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      PathGuard.superAdminGuard(context);
    });
  }

  // Convert the role number from Firestore
  // into a readable role name.
  String getRoleName(dynamic roleValue) {
    if (roleValue == null) {
      return 'User';
    }

    final int role = roleValue as int;

    if (role >= 0 && role < UserRole.values.length) {
      return UserRole.values[role].label;
    }

    return 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/home');
          },
        ),
        title: const Text('Manage Users'),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .snapshots(),

        builder: (context, snapshot) {
          // Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Error
          if (snapshot.hasError) {
            return const Center(
              child: Text('Failed to load users'),
            );
          }

          // No users
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No users found'),
            );
          }

          final users = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,

            itemBuilder: (context, index) {
              // Firestore document ID
              final userId = users[index].id;

              // Firestore user data
              final user =
                  users[index].data() as Map<String, dynamic>;

              final fullName =
                  user['full_name'] ?? 'Unknown User';

              final phoneNumber =
                  user['phone_number'] ?? '-';

              // Current role stored in Firestore
              final int currentRole =
                  (user['role'] ?? UserRole.user.index) as int;

              // Convert current role to readable text
              final roleName =
                  getRoleName(currentRole);

              // If the Super Admin selected another role,
              // use that value.
              // Otherwise use the current Firestore role.
              final int selectedRole =
                  selectedRoles[userId] ?? currentRole;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),

                child: Padding(
                  padding: const EdgeInsets.all(16),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      // -------------------------
                      // USER INFORMATION
                      // -------------------------

                      Row(
                        children: [
                          const CircleAvatar(
                            child: Icon(Icons.person),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,

                              children: [
                                Text(
                                  fullName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 4),

                                Text(phoneNumber),

                                const SizedBox(height: 4),

                                Text(
                                  'Current Role: $roleName',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // -------------------------
                      // NORMAL ACCOUNT
                      // -------------------------

                      if (currentRole !=
                          UserRole.superAdmin.index) ...[
                        DropdownButtonFormField<int>(
                          initialValue: selectedRole,

                          decoration: const InputDecoration(
                            labelText: 'Change Role',
                            border: OutlineInputBorder(),
                          ),

                          items: [
                            DropdownMenuItem<int>(
                              value: UserRole.user.index,
                              child: const Text('User'),
                            ),

                            DropdownMenuItem<int>(
                              value: UserRole.secretary.index,
                              child: const Text('Secretary'),
                            ),

                            DropdownMenuItem<int>(
                              value: UserRole.admin.index,
                              child: const Text('Admin'),
                            ),
                          ],

                          onChanged: (value) {
                            if (value == null) {
                              return;
                            }

                            setState(() {
                              selectedRoles[userId] = value;
                            });
                          },
                        ),

                        // Only show Confirm Change when
                        // the selected role is different.
                        if (selectedRole != currentRole) ...[
                          const SizedBox(height: 12),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                final bool? confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text('Confirm Role Change'),
                                      content: Text(
                                        'Change $fullName from '
                                        '${getRoleName(currentRole)} to '
                                        '${getRoleName(selectedRole)}?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop(false);
                                          },
                                          child: const Text('Cancel'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.of(context).pop(true);
                                          },
                                          child: const Text('Confirm'),
                                        ),
                                      ],
                                    );
                                  },
                                );

                                if (confirmed != true) {
                                  return;
                                }

                                try {
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(userId)
                                      .update({
                                    'role': selectedRole,
                                  });

                                  if (!mounted) {
                                    return;
                                  }

                                  setState(() {
                                    selectedRoles.remove(userId);
                                  });

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '$fullName role updated successfully.',
                                      ),
                                    ),
                                  );
                                } catch (e) {
                                  if (!mounted) {
                                    return;
                                  }

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Failed to update user role.',
                                      ),
                                    ),
                                  );

                                  debugPrint('Role update error: $e');
                                }
                              },
                              child: const Text(
                                'Confirm Change',
                              ),
                            ),
                          ),
                        ],
                      ]

                      // -------------------------
                      // SUPER ADMIN ACCOUNT
                      // -------------------------

                      else
                        const Text(
                          'Super Admin role cannot be changed here.',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
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