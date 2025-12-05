import 'package:flutter/material.dart';

class SelectionProvider extends ChangeNotifier {
  bool _isSelectionMode = false;
  int _selectedCount = 0;
  VoidCallback? _onDelete;
  VoidCallback? _onCancel;
  VoidCallback? _onSelectAll;

  bool get isSelectionMode => _isSelectionMode;
  int get selectedCount => _selectedCount;
  VoidCallback? get onDelete => _onDelete;
  VoidCallback? get onCancel => _onCancel;
  VoidCallback? get onSelectAll => _onSelectAll;

  void enterSelectionMode({
    required int count,
    required VoidCallback onDelete,
    required VoidCallback onCancel,
    VoidCallback? onSelectAll,
  }) {
    _isSelectionMode = true;
    _selectedCount = count;
    _onDelete = onDelete;
    _onCancel = onCancel;
    _onSelectAll = onSelectAll;
    notifyListeners();
  }

  void updateCount(int count) {
    _selectedCount = count;
    notifyListeners();
  }

  void exitSelectionMode() {
    _isSelectionMode = false;
    _selectedCount = 0;
    _onDelete = null;
    _onCancel = null;
    _onSelectAll = null;
    notifyListeners();
  }
}
