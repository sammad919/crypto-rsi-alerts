
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

void main() => runApp(CryptoAlertsApp());

class CryptoAlertsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crypto Alerts Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: CryptoListPage(),
    );
  }
}

class CryptoListPage extends StatefulWidget {
  @override
  _CryptoListPageState createState() => _CryptoListPageState();
}

class _CryptoListPageState extends State<CryptoListPage> {
  List coins = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchCoins();
  }

  Future<void> fetchCoins() async {
    final response = await http.get(Uri.parse(
        'https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=20&page=1&sparkline=false'));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      setState(() {
        coins = data.map((coin) {
          coin['rsi'] = Random().nextInt(100); // Mock RSI
          return coin;
        }).toList();
        loading = false;
      });
    }
  }

  Color getAlertColor(int rsi) {
    if (rsi < 30) return Colors.green;
    if (rsi > 70) return Colors.red;
    return Colors.grey;
  }

  String getAlertStatus(int rsi) {
    if (rsi < 30) return "Oversold";
    if (rsi > 70) return "Overbought";
    return "Normal";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Crypto RSI Alerts")),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: coins.length,
              itemBuilder: (context, index) {
                final coin = coins[index];
                final rsi = coin['rsi'];
                return Card(
                  child: ListTile(
                    leading: Image.network(coin['image'], width: 32),
                    title: Text('${coin['name']} (${coin['symbol'].toUpperCase()})'),
                    subtitle: Text('Price: \$${coin['current_price']}'),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('RSI: $rsi'),
                        Text(getAlertStatus(rsi),
                            style: TextStyle(color: getAlertColor(rsi))),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
