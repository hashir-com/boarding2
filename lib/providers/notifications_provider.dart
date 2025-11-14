import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/api_service.dart';

/// Provider class for managing notification state across the app
/// Handles fetching, storing, and updating notification data
class NotificationProvider extends ChangeNotifier {
  List<NotificationItem> _notifications = [];
  bool _isLoading = false;
  String _errorMessage = '';

  // Public getters to access private state
  List<NotificationItem> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  final ApiService _apiService = ApiService();

  /// Fetches notifications from the API
  /// Updates loading state and notifies listeners throughout the process
  /// Handles errors and stores error messages if the request fails
  Future<void> fetchNotifications() async {
    // Set loading state
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      // Call API service to fetch notifications
      final response = await _apiService.fetchNotification();
      _notifications = response.data;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      // Handle error and store error message
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}