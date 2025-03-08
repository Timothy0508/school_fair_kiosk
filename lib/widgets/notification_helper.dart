import 'package:flutter/material.dart';

import 'popup_notification.dart';

OverlayEntry? _currentOverlayEntry; // Store current OverlayEntry

OverlayEntry showPopupNotification(BuildContext context, String message) {
  if (_currentOverlayEntry != null && _currentOverlayEntry!.mounted) {
    _currentOverlayEntry!.remove(); // Remove existing overlay if present
    _currentOverlayEntry = null; // Reset current overlay entry
  }

  OverlayState? overlayState = Overlay.of(context);
  if (overlayState != null) {
    _currentOverlayEntry = OverlayEntry(
      // Store the created OverlayEntry
      builder: (context) => PopupNotification(
          message: message,
          onDismissed: () {
            // Callback when PopupNotification is dismissed
            _currentOverlayEntry = null; // Reset current overlay entry
          }),
    );
    overlayState.insert(_currentOverlayEntry!);
    return _currentOverlayEntry!; // Return the OverlayEntry
  }
  return OverlayEntry(
      builder: (context) =>
          SizedBox.shrink()); // Return empty entry if overlayState is null
}
