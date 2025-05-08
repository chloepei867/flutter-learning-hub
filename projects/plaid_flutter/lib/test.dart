import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:plaid_flutter/plaid_flutter.dart';

Future<String?> createLinkToken() async {
  // 确保 .env 文件已加载
  await dotenv.load(fileName: ".env");

  // 从 .env 文件中获取 PLAID_CLIENT_ID 和 PLAID_SECRET

  final clientId = dotenv.env['PLAID_CLIENT_ID'];
  final secret = dotenv.env['PLAID_SECRET'];

  // if (clientId == null || secret == null) {
  //   print("Missing PLAID_CLIENT_ID or PLAID_SECRET in .env file");
  //   return null;
  // }

  // 设置 API 端点
  final url = Uri.parse('https://sandbox.plaid.com/link/token/create');

  // 构建请求头
  final headers = {
    'Content-Type': 'application/json',
  };

  // 构建请求体
  final body = jsonEncode({
    'client_id': clientId,  // 从 .env 文件加载
    'secret': secret,       // 从 .env 文件加载
    'user': {
      'client_user_id': 'user-id',
      'phone_number': '+1 415 5550123',
    },
    'client_name': 'Personal Finance App',
    'products': ['transactions'],
    'transactions': {
      'days_requested': 730,
    },
    'country_codes': ['US'],
    'language': 'en',
    'webhook': 'https://sample-web-hook.com',
    'redirect_uri': 'http://localhost:3000',
    'account_filters': {
      'depository': {
        'account_subtypes': ['checking', 'savings'],
      },
      'credit': {
        'account_subtypes': ['credit card'],
      }
    }
  });

  // 发送请求
  try {
    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      // 请求成功，解析响应
      print('Response body: ${response.body}');
      final responseData = jsonDecode(response.body);
      print('Link Token: ${responseData['link_token']}');
      return responseData['link_token'];
    } else {
      // 请求失败，打印错误信息
      print('Request failed with status: ${response.statusCode}');
      print('Response body: ${response.body}');
      return null;
    }
  } catch (e) {
    // 捕获异常
    print('Error occurred: $e');
    return null;
  }
}

Future<String?> getAccessToken(String publicToken) async {
  await dotenv.load(fileName: ".env");

  // 从 .env 文件中获取 PLAID_CLIENT_ID 和 PLAID_SECRET

  final clientId = dotenv.env['PLAID_CLIENT_ID'];
  final secret = dotenv.env['PLAID_SECRET'];

  final url = Uri.parse('https://sandbox.plaid.com/item/public_token/exchange');

  // 构建请求头
  final headers = {
    'Content-Type': 'application/json',
  };

  // 构建请求体
  final body = jsonEncode({
    "client_id": clientId,
    "secret": secret,
    "public_token": publicToken,
  });

  // 发送请求
  try {
    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      // 请求成功，解析响应
      print('Response body: ${response.body}');
      final responseData = jsonDecode(response.body);
      print('Access Token: ${responseData['access_token']}');
      return responseData['access_token'];
    } else {
      // 请求失败，打印错误信息
      print('Request failed with status: ${response.statusCode}');
      print('Response body: ${response.body}');
      return null;
    }
  } catch (e) {
    // 捕获异常
    print('Error occurred: $e');
    return null;
  }

}

Future<void> fetchAccountData(String accessToken) async {
  await dotenv.load(fileName: ".env");

  // 从 .env 文件中获取 PLAID_CLIENT_ID 和 PLAID_SECRET

  final clientId = dotenv.env['PLAID_CLIENT_ID'];
  final secret = dotenv.env['PLAID_SECRET'];

  final url = Uri.parse('https://sandbox.plaid.com/accounts/get');

  // 构建请求头
  final headers = {
    'Content-Type': 'application/json',
  };

  // 构建请求体
  final body = jsonEncode({
    "client_id": clientId,
    "secret": secret,
    "access_token": accessToken,
  });

  // 发送请求
  try {
    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      // 请求成功，解析响应
      print('Response body: ${response.body}');
      final responseData = jsonDecode(response.body);
      print('Accounts Response: ${responseData['accounts']}');
      // return responseData['access_token'];
    } else {
      // 请求失败，打印错误信息
      print('Request failed with status: ${response.statusCode}');
      print('Response body: ${response.body}');
      return null;
    }
  } catch (e) {
    // 捕获异常
    print('Error occurred: $e');
    return null;
  }
}

Future<void> fetchTransitionData(String accessToken) async {
  await dotenv.load(fileName: ".env");

  // 从 .env 文件中获取 PLAID_CLIENT_ID 和 PLAID_SECRET

  final clientId = dotenv.env['PLAID_CLIENT_ID'];
  final secret = dotenv.env['PLAID_SECRET'];

  final url = Uri.parse('https://sandbox.plaid.com/transactions/sync');

  // 构建请求头
  final headers = {
    'Content-Type': 'application/json',
  };

  // 构建请求体
  final body = jsonEncode({
    "client_id": clientId,
    "secret": secret,
    "access_token": accessToken,
    "count": 250,
  });

  // 发送请求
  try {
    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      // 请求成功，解析响应
      print('Transition Response body: ${response.body}');
      final responseData = jsonDecode(response.body);
      // print('Transition Response: ${responseData['accounts']}');
      // return responseData['access_token'];
    } else {
      // 请求失败，打印错误信息
      print('Request failed with status: ${response.statusCode}');
      print('Response body: ${response.body}');
      return null;
    }
  } catch (e) {
    // 捕获异常
    print('Error occurred: $e');
    return null;
  }
}

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {

  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  LinkTokenConfiguration? _configuration;
  StreamSubscription<LinkEvent>? _streamEvent;
  StreamSubscription<LinkExit>? _streamExit;
  StreamSubscription<LinkSuccess>? _streamSuccess;
  LinkObject? _successObject;
  String _linkToken = "";
  String? _publicToken;
  String? _accessToken;

  @override
  void initState() {
    super.initState();

    _streamEvent = PlaidLink.onEvent.listen(_onEvent);
    _streamExit = PlaidLink.onExit.listen(_onExit);
    _streamSuccess = PlaidLink.onSuccess.listen(_onSuccess);
    fetchLinkToken();
    fetchAccessToken();
    // getAccessToken(_publicToken);
  }

  Future<void> fetchAccessToken() async {
    String? token = await createLinkToken();
    setState(() {
      final _publicToken = _successObject?.toJson().toString() ?? ""; // 更新 linkToken 状态，触发 UI 重新构建
    });
    // String accessToken = getAccessToken(_publicToken);


  }

  Future<void> fetchLinkToken() async {
    String? token = await createLinkToken();
    setState(() {
      _linkToken = token!; // 更新 linkToken 状态，触发 UI 重新构建
    });
  }


  @override
  void dispose() {
    _streamEvent?.cancel();
    _streamExit?.cancel();
    _streamSuccess?.cancel();
    super.dispose();
  }

  void _createLinkTokenConfiguration() {
    setState(() {
      _configuration = LinkTokenConfiguration(
        token: _linkToken,
      );

      PlaidLink.create(configuration: _configuration!);
    });
  }

  void _onEvent(LinkEvent event) {
    final name = event.name;
    final metadata = event.metadata.description();
    print("onEvent: $name, metadata: $metadata");
  }

  void _onSuccess(LinkSuccess event) async {
    String token = event.publicToken;
    final metadata = event.metadata.description();
    print("onSuccess: $token, metadata: $metadata");
    String? accessToken = await getAccessToken(token);
    setState(() {
      _accessToken = accessToken;
      if (_accessToken != null) {
        fetchAccountData(_accessToken!);
      }
    });

    // setState(
    //
    //     // () => _successObject = event
    // );
  }

  void _onExit(LinkExit event) {
    final metadata = event.metadata.description();
    final error = event.error?.description();
    print("onExit metadata: $metadata, error: $error");
  }

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      home: Scaffold(
        body: Container(
          width: double.infinity,
          color: Colors.grey[200],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Center(
                  child: Text(
                    _configuration?.toJson().toString() ?? "",
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              //create link token configuration
              ElevatedButton(
                onPressed: _createLinkTokenConfiguration,
                child: const Text("Create Link Token Configuration"),
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed:
                _configuration != null ? () => PlaidLink.open() : null,
                child: const Text("Open"),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _configuration != null
                    ? () {
                  PlaidLink.submit(
                    SubmissionData(
                      phoneNumber: "14155550015",
                    ),
                  );
                }
                    : null,
                child: const Text("Submit Phone Number"),
              ),
              ElevatedButton(
                onPressed: _accessToken != null
                    ? () {
                  // PlaidLink.submit(
                  //   SubmissionData(
                  //     phoneNumber: "14155550015",
                  //   ),
                  // );
                  fetchTransitionData(_accessToken!);
                }
                    : null,
                child: const Text("Fetch Transition Data"),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    _successObject?.toJson().toString() ?? "",
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


