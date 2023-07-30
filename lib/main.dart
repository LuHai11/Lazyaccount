import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
  List<String> addText = [];
  double totalAmount = 0.0; // 新增總和金額變數

  final TextEditingController myController = TextEditingController();

  void _add() {
    setState(() {
      double amount = double.tryParse(myController.text) ?? 0.0; // 取得輸入的金額
      totalAmount += amount; // 更新總和金額
      addText.add(myController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
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
            label: Text('Save'),
            onPressed: () {
              _add();
              myController.clear(); // 清空 TextField 內容
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: addText.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(addText[index]),
                );
              },
            ),
          ),
          Text(
            '總和金額: \$${totalAmount.toStringAsFixed(2)}',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ), // 顯示總和金額
        ],
      ),
    );
  }
}
