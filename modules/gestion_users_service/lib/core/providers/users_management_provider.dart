import 'package:auth_service/models/user_model.dart';
import 'package:flutter/material.dart';
import '../../models/users_management_model.dart';

enum UsersManagementStatus { idle, loading, success, error }

class UsersManagementProvider extends ChangeNotifier {
  final UsersManagementModel _model = UsersManagementModel();

  List<UserModel> _users = [];
  UserModel? _selectedUser;
  UsersManagementStatus _status = UsersManagementStatus.idle;
  String _errorMessage = '';

  List<UserModel> get users => _users;
  UserModel? get selectedUser => _selectedUser;
  UsersManagementStatus get status => _status;
  String get errorMessage => _errorMessage;

  Future<void> loadUsers() async {
    _status = UsersManagementStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      _users = await _model.getAllUsers();
      _status = UsersManagementStatus.success;
    } catch (e) {
      _status = UsersManagementStatus.error;
      _errorMessage = e.toString();
    } finally {
      notifyListeners();
    }
  }

  Future<void> getUserDetails(String uid) async {
    _status = UsersManagementStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      _selectedUser = await _model.getUserByUid(uid);
      _status = UsersManagementStatus.success;
    } catch (e) {
      _status = UsersManagementStatus.error;
      _errorMessage = e.toString();
    } finally {
      notifyListeners();
    }
  }

  Future<void> deleteUser(String uid) async {
    _status = UsersManagementStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      await _model.deleteUser(uid);

      _users.removeWhere((user) => user.uid == uid);

      if (_selectedUser?.uid == uid) {
        _selectedUser = null;
      }

      _status = UsersManagementStatus.success;
    } catch (e) {
      _status = UsersManagementStatus.error;
      _errorMessage = e.toString();
    } finally {
      notifyListeners();
    }
  }
}
