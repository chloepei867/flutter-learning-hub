class AccessTokenStore {
  static final AccessTokenStore _instance = AccessTokenStore._internal();
  factory AccessTokenStore() => _instance;
  AccessTokenStore._internal();

  String? accessToken;
  String? itemId;
}

final accessTokenStore = AccessTokenStore();
