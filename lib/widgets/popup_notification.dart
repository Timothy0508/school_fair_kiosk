import 'package:flutter/material.dart';

class PopupNotification extends StatefulWidget {
  final String message;
  final VoidCallback? onDismissed; // Add onDismissed callback

  PopupNotification({required this.message, this.onDismissed});

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
      return SizedBox.shrink(); // 不可見時返回空的 SizedBox
    }

    return Positioned(
      top: 60, // 調整垂直位置
      right: 20, // 調整水平位置
      child: Material(
        // 使用 Material 增加陰影和背景
        elevation: 4,
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[200], // 設定背景顏色
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
                    _isVisible = false; // 點擊關閉按鈕時設定為不可見
                  });
                  Future.delayed(Duration(milliseconds: 300), () {
                    _dismiss(); // Call dismiss function
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
