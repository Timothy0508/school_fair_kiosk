import 'package:flutter/material.dart';

import 'popup_notification.dart';

void showPopupNotification(BuildContext context, String message) {
  OverlayState? overlayState = Overlay.of(context);
  if (overlayState != null) {
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => PopupNotification(message: message),
    );
    overlayState.insert(overlayEntry);
  }
}
