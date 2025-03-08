import 'package:flutter/material.dart';

import 'notification_type.dart'; // 引入 NotificationType 列舉
import 'popup_notification.dart';

OverlayEntry? _currentOverlayEntry; // Store current OverlayEntry

OverlayEntry showPopupNotification(BuildContext context, String message,
    {NotificationType type = NotificationType.info}) {
  // Add type parameter with default value
  if (_currentOverlayEntry != null && _currentOverlayEntry!.mounted) {
    _currentOverlayEntry!.remove();
    _currentOverlayEntry = null;
  }

  OverlayState? overlayState = Overlay.of(context);
  if (overlayState != null) {
    _currentOverlayEntry = OverlayEntry(
      builder: (context) => PopupNotification(
          message: message,
          type: type, // Pass the type parameter to PopupNotification
          onDismissed: () {
            _currentOverlayEntry = null;
          }),
    );
    overlayState.insert(_currentOverlayEntry!);
    return _currentOverlayEntry!;
  }
  return OverlayEntry(builder: (context) => SizedBox.shrink());
}
