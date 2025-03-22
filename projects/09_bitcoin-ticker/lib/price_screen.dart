import 'package:bitcoin_ticker/coin_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

const double kItemExtent = 32.0;

class PriceScreen extends StatefulWidget {
  const PriceScreen({super.key});

  @override
  State<PriceScreen> createState() => _PriceScreenState();
}

class _PriceScreenState extends State<PriceScreen> {
  String selectedCurrency = "USD";
  double rate = 0;

  Widget androidDropDown() {
    return DropdownMenu(
      initialSelection: "USD",
      dropdownMenuEntries:
          currenciesList.map<DropdownMenuEntry<String>>((String item) {
        return DropdownMenuEntry<String>(
          value: item,
          label: item,
        );
      }).toList(),
      onSelected: (value) {
        setState(() {
          selectedCurrency = value!;
          fetchData();
        });
      },
    );
  }

  Widget iOSPicker() {
    return CupertinoPicker(
      itemExtent: kItemExtent,
      onSelectedItemChanged: (selectedIndex) {
        setState(() {
          selectedCurrency = currenciesList[selectedIndex];
          fetchData();
        });
      },
      children: List<Widget>.generate(currenciesList.length, (int index) {
        return Center(
          child: Text(
            currenciesList[index],
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }),
    );
  }

  Map<String, String>? cryptoToPrice;
  bool isFetchDataSuccessful = false;

  void fetchData() async {
    try {
      var data = await CoinData().getCoinData(selectedCurrency);
      setState(() {
        cryptoToPrice = data;
        isFetchDataSuccessful = true;
      });
      print("第一个数据 ${cryptoToPrice?["BTC"]}");
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('🤑 Coin Ticker'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ...cryptoList.map(
                (currency) => CurrencyExchangeCard(
                    baseCurrency: currency,
                    rate: isFetchDataSuccessful
                        ? (cryptoToPrice?[currency] ?? "N/A")
                        : "?",
                    selectedQuoteCurrency: selectedCurrency),
              ),
            ],
          ),
          Container(
            height: 150.0,
            alignment: Alignment.center,
            padding: EdgeInsets.only(bottom: 30),
            color: Colors.lightBlue,
            child: Platform.isIOS ? iOSPicker() : androidDropDown(),
          ),
        ],
      ),
    );
  }
}

class CurrencyExchangeCard extends StatelessWidget {
  const CurrencyExchangeCard(
      {super.key,
      required this.baseCurrency,
      required this.selectedQuoteCurrency,
      required this.rate});

  final String baseCurrency;
  final String selectedQuoteCurrency;
  final String rate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(18.0, 18.0, 18.0, 0),
      child: Card(
        color: Colors.lightBlue,
        elevation: 5.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 28.0, vertical: 15.0),
          child: Text(
            '1 $baseCurrency = $rate $selectedQuoteCurrency',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20.0,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
