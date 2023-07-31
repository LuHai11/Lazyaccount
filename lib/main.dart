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
      home: MyHomePage(title: 'LazyAccount'),
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
  List<Map<String, dynamic>> addText = [];
  double totalAmount = 0.0;

  final TextEditingController myController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // 新增 Form 的 GlobalKey

  String? _validateInput(String? value) {
    if (value == null || value.isEmpty) {
      return '金額不能為空';
    }
    double? amount = double.tryParse(value);
    if (amount == null || amount <= 0) {
      return '請輸入有效金額';
    }
    return null; // 驗證通過返回 null
  }

  String _selectedCategory = ''; // 儲存選擇的類別
  bool _isExpanded = false; // 控制展開或收起

  List<String> _categoryOptions = [
    '食',
    '衣',
    '住',
    '行',
  ];

  void _add() {
    if (_formKey.currentState!.validate()) {
      double amount = double.parse(myController.text);
      setState(() {
        totalAmount += amount;
        addText.add({
          'category': _selectedCategory,
          'amount': amount,
        });
        _selectedCategory = ''; // 清空選擇的類別
      });
      myController.clear();
      _isExpanded = false; // 選擇後自動收起
    }
  }

  void _addCustomCategory(BuildContext context) {
    String newCategory = '';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('新增類別'),
          content: TextField(
            onChanged: (value) {
              newCategory = value;
            },
            decoration: InputDecoration(
              hintText: '輸入類別名稱',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 取消後返回上一頁
              },
              child: Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                if (newCategory.isNotEmpty) {
                  setState(() {
                    _categoryOptions.add(newCategory);
                  });
                  Navigator.of(context).pop(); // 確定後返回上一頁
                }
              },
              child: Text('確定'),
            ),
          ],
        );
      },
    );
  }

  void _deleteCategory(int index) {
    setState(() {
      _categoryOptions.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            TextFormField(
              controller: myController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              validator: _validateInput,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: '輸入金額或類別',
              ),
            ),
            SingleChildScrollView(
              child: ExpansionPanelList(
                expansionCallback: (index, isExpanded) {
                  setState(() {
                    _isExpanded = !isExpanded; // 切換展開狀態
                  });
                },
                children: [
                  ExpansionPanel(
                    headerBuilder: (context, isExpanded) {
                      return ListTile(
                        title: Text(_selectedCategory.isNotEmpty
                            ? _selectedCategory
                            : '支出類別'),
                      );
                    },
                    body: Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: [
                        ..._categoryOptions.asMap().entries.map((entry) {
                          int index = entry.key;
                          String category = entry.value;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedCategory = category;
                              });
                            },
                            child: Chip(
                              label: Text(category),
                              onDeleted: () {
                                _deleteCategory(index);
                              },
                            ),
                          );
                        }),
                        GestureDetector(
                          onTap: () {
                            _addCustomCategory(context);
                          },
                          child: Chip(
                            label: Text('新增類別'),
                          ),
                        ),
                      ],
                    ),
                    isExpanded: _isExpanded,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey)),
                ),
                child: ListView.builder(
                  itemCount: addText.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                          '${addText[index]['category']} - \$${addText[index]['amount'].toStringAsFixed(2)}'),
                    );
                  },
                ),
              ),
            ),
            ElevatedButton.icon(
              icon: Icon(Icons.save),
              label: Text('Save'),
              onPressed: _add,
            ),
            Text(
              '總和金額: \$${totalAmount.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
