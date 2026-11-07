import 'dart:async';

import 'package:ebooking/models/notification_model.dart';
import 'package:ebooking/services/notification_service.dart';
import 'package:flutter/material.dart';

class NotificationProvider with ChangeNotifier {
  NotificationProvider({required this._service});

  static const Duration refreshInterval = Duration(seconds: 20);

  final NotificationService _service;

  Timer? _timer;
  List<AppNotification> _items = [];
  int _unread = 0;
  int _page = 1;
  int _totalPages = 1;
  bool _loading = false;
  String? _error;

  List<AppNotification> get items => _items;
  int get unreadCount => _unread;
  bool get isLoading => _loading;
  bool get hasMore => _page < _totalPages;
  String? get error => _error;

  void start() {
    _timer?.cancel();
    _timer = Timer.periodic(refreshInterval, (_) => refreshUnread());
    refreshUnread();
  }

  Future<void> refreshUnread() async {
    try {
      final count = await _service.unreadCount();
      final changed = count != _unread;
      _unread = count;
      if (changed) {
        if (_items.isNotEmpty) await load();
        notifyListeners();
      }
    } catch (_) {
      return;
    }
  }

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final page = await _service.fetch();
      _items = page.items;
      _page = page.page;
      _totalPages = page.totalPages;
      _unread = await _service.unreadCount();
    } catch (e) {
      _error = '$e';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (_loading || !hasMore) return;
    _loading = true;
    notifyListeners();
    try {
      final page = await _service.fetch(page: _page + 1);
      _items = [..._items, ...page.items];
      _page = page.page;
      _totalPages = page.totalPages;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> markRead(AppNotification notification) async {
    if (notification.isRead) return;
    await _service.markRead(notification.id);
    notification.isRead = true;
    if (_unread > 0) _unread--;
    notifyListeners();
  }

  Future<void> markAllRead() async {
    await _service.markAllRead();
    for (final item in _items) {
      item.isRead = true;
    }
    _unread = 0;
    notifyListeners();
  }

  void clear() {
    _timer?.cancel();
    _timer = null;
    _items = [];
    _unread = 0;
    _page = 1;
    _totalPages = 1;
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
