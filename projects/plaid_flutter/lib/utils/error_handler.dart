class ErrorHandler {
  static String getErrorMessage(dynamic error) {
    if (error is String) {
      return error;
    }

    // 这里可以根据不同的错误类型返回不同的错误信息
    // 例如：网络错误、认证错误等
    return error.toString();
  }

  static String getLocalizedErrorMessage(String errorKey) {
    // 这里可以从本地化文件中获取错误信息
    // 暂时返回硬编码的错误信息
    switch (errorKey) {
      case 'noAccessToken':
        return '无法获取访问令牌';
      case 'fetchAccounts':
        return '获取账户信息失败';
      case 'fetchTransactions':
        return '获取交易记录失败';
      case 'linkToken':
        return '获取链接令牌失败';
      default:
        return '发生未知错误';
    }
  }
}
