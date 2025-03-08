import 'package:flutter/material.dart';

import 'notification_type.dart';

class PopupNotification extends StatefulWidget {
  final String message;
  final NotificationType type;
  final VoidCallback? onDismissed; // Add onDismissed callback

  PopupNotification(
      {required this.message,
      this.type = NotificationType.info,
      this.onDismissed});

  @override
  _PopupNotificationState createState() => _PopupNotificationState();
}

class _PopupNotificationState extends State<PopupNotification> {
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    // 設定提示訊息顯示一段時間後自動消失 (例如 3 秒)
    Future.delayed(Duration(seconds: 3), () {
      _autoDismiss();
    });
  }

  void _autoDismiss() {
    if (mounted) {
      setState(() {
        _isVisible = false;
      });
      // 延遲移除 OverlayEntry
      Future.delayed(Duration(milliseconds: 300), () {
        _dismiss(); // Call dismiss function
      });
    }
  }

  void _dismiss() {
    // Rename _safeRemoveOverlay to _dismiss, and simplify it
    if (mounted) {
      widget.onDismissed?.call(); // Call the onDismissed callback
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) {
      return SizedBox.shrink();
    }

    // 根據提示訊息類型設定背景顏色
    Color backgroundColor;
    switch (widget.type) {
      case NotificationType.success:
        backgroundColor = Colors.green[200]!; // 成功：綠色
        break;
      case NotificationType.warning:
        backgroundColor = Colors.orange[200]!; // 警告：橘色
        break;
      case NotificationType.info:
      default:
        backgroundColor = Colors.grey[200]!; // 資訊/預設：灰色
        break;
    }

    return Positioned(
      top: 60,
      right: 20,
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(8),
        // *** 使用動態背景顏色 ***
        color: backgroundColor, // 設定動態背景顏色
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.message, style: TextStyle(fontSize: 16)),
              SizedBox(width: 10),
              IconButton(
                icon: Icon(Icons.close, size: 20),
                onPressed: () {
                  setState(() {
                    _isVisible = false;
                  });
                  Future.delayed(Duration(milliseconds: 300), () {
                    _dismiss();
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
