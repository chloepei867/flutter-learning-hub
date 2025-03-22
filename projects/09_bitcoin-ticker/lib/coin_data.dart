import 'package:http/http.dart' as http;
import 'dart:convert';

const List<String> currenciesList = [
  'AUD',
  'BRL',
  'CAD',
  'CNY',
  'EUR',
  'GBP',
  'HKD',
  'IDR',
  'ILS',
  'INR',
  'JPY',
  'MXN',
  'NOK',
  'NZD',
  'PLN',
  'RON',
  'RUB',
  'SEK',
  'SGD',
  'USD',
  'ZAR'
];

final String baseUrl =
    "https://api-realtime.exrates.coinapi.io/v1/exchangerate";
final String apiKey = "YOUR-API-KEY";

const List<String> cryptoList = [
  'BTC',
  'ETH',
  'LTC',
];

class CoinData {
  Future getCoinData(String selectedQuoteCurrency) async {
    //key: crypto, value: price
    Map<String, String> cryptoPrices = {};
    for (String baseCurrency in cryptoList) {
      var url = "$baseUrl/$baseCurrency/$selectedQuoteCurrency?apikey=$apiKey";
      http.Response response = await http.get(Uri.parse(url));
      print(response);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        double price = jsonData['rate'];
        cryptoPrices[baseCurrency] = price.toStringAsFixed(0);
      } else {
        // print(response.statusCode);
        throw 'Problem with the get request, ${response.statusCode}';
      }
    }
    print("获取的数据是： $cryptoPrices");
    return cryptoPrices;
  }
}
