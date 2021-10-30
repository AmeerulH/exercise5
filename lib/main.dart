import 'dart:async';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Day 5 Exercise'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String symbol = '';
  String data = '';
  List symbols = [];
  List tickHistory = [];
  dynamic symbolDetails;
  final channel = IOWebSocketChannel.connect(
      'wss://ws.binaryws.com/websockets/v3?app_id=1089');
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  var _controller = TextEditingController();

  // void getSymbols() {
  //   channel.stream.listen((message) {
  //     final decodedMessage = jsonDecode(message);
  //     final symbolsData = decodedMessage['active_symbols'];
  //     setState(() {
  //       symbolsData.forEach((value) => {
  //             value.containsKey('symbol') ? symbols.add(value['symbol']) : null
  //           });
  //     });
  //     print(symbols);
  //     print(symbolDetails);
  //     channel.sink.close();
  //   });

  //   channel.sink.add('{"active_symbols": "brief", "product_type": "basic"}');
  // }

  void getData(symbol) {
    tickHistory.clear();
    channel.stream.listen((tick) {
      final decodedMessage = jsonDecode(tick);
      final name = decodedMessage['tick']['symbol'];
      final serverTimeAsEpoch = decodedMessage['tick']['epoch'];
      final price = decodedMessage['tick']['quote'];
      final serverTime =
          DateTime.fromMillisecondsSinceEpoch(serverTimeAsEpoch * 1000);

      setState(() {
        tickHistory.add({"Name": name, "Price": price, "Date": serverTime});
      });
      print('Name: ${name}, Price: ${price}, Date: ${serverTime}');
    });

    channel.sink.add('{"ticks": "$symbol"}');
  }

  @override
  void initState() {
    // getData('cryBTCUSD');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Container(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'Enter Symbol: ',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      onPressed: _formKey.currentState?.validate() ?? false
                          ? () {
                              getData(symbol);
                            }
                          : null,
                      icon: const Icon(Icons.check_circle_rounded),
                    ),
                  ),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a symbol';
                    }
                    return null;
                  },
                  onChanged: (String? value) {
                    setState(() {
                      symbol = value!;
                    });
                  },
                ),
                tickHistory.isNotEmpty
                    ? Expanded(
                        child: ListView.builder(
                            itemCount: tickHistory.length,
                            itemBuilder: (context, index) {
                              return Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.black,
                                  ),
                                  color: Colors.amberAccent,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.only(left: 10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  'Name: ${tickHistory[index]["Name"]}',
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  'Price: ${tickHistory[index]["Price"]}',
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  'Date: ${tickHistory[index]["Date"]}',
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }))
                    : Container()
              ],
            ),
          ),
        ));
  }
}

// class DetailsPage extends StatelessWidget {
//   const DetailsPage({Key? key}) : super(key: key);

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//         home: Scaffold(
//             appBar: AppBar(
//               title: const Text('Home Page'),
//               flexibleSpace: Container(
//                 decoration: const BoxDecoration(
//                   gradient: LinearGradient(
//                       colors: [
//                         Color(0xFF3366FF),
//                         Color(0xFF00CCFF),
//                       ],
//                       begin: FractionalOffset(0.0, 0.0),
//                       end: FractionalOffset(1.0, 0.0),
//                       stops: [0.0, 1.0],
//                       tileMode: TileMode.clamp),
//                 ),
//               ),
//             ),
//             body: Center(
//                 child: Column(
//               children: [
//                 // Text(
//                 //   'Hello ${user.name}!',
//                 //   style: const TextStyle(
//                 //     fontSize: 40,
//                 //     color: Colors.black,
//                 //   ),
//                 //   textAlign: TextAlign.center,
//                 // ),
//               ],
//             ))));
//   }
// }
