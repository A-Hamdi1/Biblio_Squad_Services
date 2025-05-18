import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/user_list_item.dart';
import '../../core/providers/users_management_provider.dart';
import 'package:ocr_service/ui/components/app_header.dart';
import 'package:gestion_users_service/ui/screens/user_details_screen.dart';

class UsersListScreen extends StatefulWidget {
  const UsersListScreen({super.key});

  @override
  _UsersListScreenState createState() => _UsersListScreenState();
}

class _UsersListScreenState extends State<UsersListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UsersManagementProvider>(context, listen: false).loadUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              onBackPressed: () => Navigator.of(context).pop(),
              showBar: true,
            ),
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                "Users Management",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF7643),
                ),
              ),
            ),
            Expanded(
              child: Consumer<UsersManagementProvider>(
                builder: (context, provider, child) {
                  if (provider.status == UsersManagementStatus.loading &&
                      provider.users.isEmpty) {
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
                            onPressed: () => provider.loadUsers(),
                            child: const Text("Retry"),
                          ),
                        ],
                      ),
                    );
                  }

                  if (provider.users.isEmpty) {
                    return const Center(
                      child: Text("No users found"),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () => provider.loadUsers(),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: provider.users.length,
                      itemBuilder: (context, index) {
                        final user = provider.users[index];
                        return UserListItem(
                          user: user,
                          onViewDetails: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    UserDetailsScreen(uid: user.uid),
                              ),
                            ).then((_) {
                              provider.loadUsers();
                            });
                          },
                          onDelete: () =>
                              _showDeleteConfirmation(context, user),
                        );
                      },
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

  void _showDeleteConfirmation(BuildContext context, final user) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

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
            onPressed: () async {
              Navigator.of(dialogContext).pop();

              final provider =
                  Provider.of<UsersManagementProvider>(context, listen: false);

              await provider.deleteUser(user.uid);

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
