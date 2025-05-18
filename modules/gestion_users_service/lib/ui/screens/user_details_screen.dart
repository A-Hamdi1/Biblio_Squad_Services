import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/users_management_provider.dart';
import '../widgets/detail_field.dart';
import 'package:ocr_service/ui/components/app_header.dart';

class UserDetailsScreen extends StatefulWidget {
  final String uid;

  const UserDetailsScreen({super.key, required this.uid});

  @override
  _UserDetailsScreenState createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UsersManagementProvider>(context, listen: false)
          .getUserDetails(widget.uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              showBar: true,
              onBackPressed: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: Consumer<UsersManagementProvider>(
                builder: (context, provider, child) {
                  if (provider.status == UsersManagementStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (provider.status == UsersManagementStatus.error) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Error: ${provider.errorMessage}",
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () =>
                                provider.getUserDetails(widget.uid),
                            child: const Text("Retry"),
                          ),
                        ],
                      ),
                    );
                  }

                  if (provider.selectedUser == null) {
                    return const Center(
                      child: Text("User not found"),
                    );
                  }

                  final user = provider.selectedUser!;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: const Text(
                            "User Details",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFF7643),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // User profile header
                        Center(
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: const Color(0xFFFF7643),
                                child: Text(
                                  user.name.isNotEmpty
                                      ? user.name[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    fontSize: 40,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                user.name,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "Role: ${_formatRole(user.role)}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 30),
                        const Divider(),
                        const SizedBox(height: 20),

                        // User details
                        DetailField(label: "User ID", value: user.uid),
                        DetailField(label: "Email", value: user.email),
                        DetailField(label: "Phone", value: user.phone),
                        DetailField(
                            label: "Role", value: _formatRole(user.role)),

                        const SizedBox(height: 30),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () =>
                                _showDeleteConfirmation(context, user),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              "Delete User",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatRole(String role) {
    return role.isNotEmpty ? role[0].toUpperCase() + role.substring(1) : role;
  }

  void _showDeleteConfirmation(BuildContext context, final user) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigatorContext = Navigator.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Delete User"),
        content: Text("Are you sure you want to delete ${user.name}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              final provider =
                  Provider.of<UsersManagementProvider>(context, listen: false);
              provider.deleteUser(user.uid);

              navigatorContext.pop();
              scaffoldMessenger.showSnackBar(
                SnackBar(
                  content: Text("User ${user.name} has been deleted"),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
