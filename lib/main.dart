import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'LazyAccount'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}
class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }
  final TextEditingController myController = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
          //mainAxisAlignment: MainAxisAlignment.,
          children: <Widget>[
            TextField(
              controller: myController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: '輸入金額',
              ),
            ),
            ElevatedButton.icon(
              icon: Icon(Icons.save),
              onPressed: (){
                final snackBar1 = SnackBar(
                  content: Text('你按了ElevatedButton.icon'),
                  action: SnackBarAction(
                    label: 'Toast訊息',
                    onPressed:() =>Fluttertoast.showToast(msg: '你按下snackBar'),
                  ),);
              },
            ),
          ],
        ),
    );
  }
}
