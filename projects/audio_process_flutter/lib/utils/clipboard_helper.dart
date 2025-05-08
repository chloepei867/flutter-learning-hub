import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ClipboardHelper {
  static Future<void> copyToClipboard(BuildContext context, String text, {String? message}) async {
    await Clipboard.setData(ClipboardData(text: text));

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message ?? '已复制到剪贴板'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}