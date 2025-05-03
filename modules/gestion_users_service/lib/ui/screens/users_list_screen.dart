import 'package:auth_service/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/users_provider.dart';

class UsersListScreen extends StatefulWidget {
  const UsersListScreen({super.key});

  @override
  _UsersListScreenState createState() => _UsersListScreenState();
}

class _UsersListScreenState extends State<UsersListScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch users when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UsersProvider>(context, listen: false).fetchUsers();
    });
  }

  void _confirmDeleteUser(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete user ${user.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteUser(user.uid);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deleteUser(String userId) async {
    final usersProvider = Provider.of<UsersProvider>(context, listen: false);
    await usersProvider.deleteUser(userId);

    if (usersProvider.status == UsersStatus.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(usersProvider.errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Users List',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFFFF7643),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Consumer<UsersProvider>(
          builder: (context, usersProvider, child) {
            if (usersProvider.status == UsersStatus.loading &&
                usersProvider.users.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (usersProvider.status == UsersStatus.error) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error: ${usersProvider.errorMessage}',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => usersProvider.fetchUsers(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            // Filter users to only show Author and Client roles
            final filteredUsers = usersProvider.users
                .where((user) => user.role == 'Author' || user.role == 'Client')
                .toList();

            if (filteredUsers.isEmpty) {
              return const Center(
                child: Text(
                  'No users found',
                  style: TextStyle(fontSize: 18),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => usersProvider.fetchUsers(),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = filteredUsers[index];
                  return UserListItem(
                    user: user,
                    onDelete: () => _confirmDeleteUser(user),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class UserListItem extends StatelessWidget {
  final UserModel user;
  final VoidCallback onDelete;

  const UserListItem({
    super.key,
    required this.user,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFFFF7643),
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: user.role == 'Author'
                        ? Colors.blue.withOpacity(0.2)
                        : Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    user.role,
                    style: TextStyle(
                      color: user.role == 'Author'
                          ? Colors.blue[700]
                          : Colors.green[700],
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete),
                  label: const Text('Delete'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
