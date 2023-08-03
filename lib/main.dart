import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'chart.dart';
import 'caleder.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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

class Account {
  final String id;
  final String category;
  final double amount;

  Account({
    required this.id,
    required this.category,
    required this.amount,
  });

  factory Account.fromMap(Map<String, dynamic> map, String id) {
    return Account(
      id: id,
      category: map['category'] ?? '未知類別',
      amount: (map['amount'] ?? 0.0).toDouble(),
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
  List<Account> addText = [];
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

  // 監聽器設定
  @override
  void initState() {
    super.initState();
    _getTotalAmount();
  }

  void _getTotalAmount() {
    FirebaseFirestore.instance.collection('account').get().then((querySnapshot) {
      double total = 0.0;
      List<Account> texts = [];
      querySnapshot.docs.forEach((doc) {
        Account account = Account.fromMap(doc.data(), doc.id);
        total += account.amount;
        texts.add(account);
      });
      setState(() {
        totalAmount = total;
        addText = texts;
      });
    });
  }

  void _add() {
    if (_formKey.currentState!.validate()) {
      double amount = double.parse(myController.text);
      String selectedCategory = _selectedCategory; // Save the value before calling setState
      setState(() {
        totalAmount += amount;
        addText.add(
          Account(
            id: '',
            category: selectedCategory,
            amount: amount,
          ),
        );
        _selectedCategory = ''; // 清空選擇的類別
      });
      myController.clear();
      _isExpanded = false; // 選擇後自動收起
      // 將使用者輸入的數值和類別記錄到 Firebase
      FirebaseFirestore.instance.collection('account').add({
        'category': selectedCategory,
        'amount': amount,
      });
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

  void _deleteTransaction(String id, double amount) {
    setState(() {
      totalAmount -= amount;
      addText.removeWhere((transaction) => transaction.id == id);
    });
    FirebaseFirestore.instance.collection('account').doc(id).delete();
  }

  void _deleteCategory(int index) {
    if (index >= 0 && index < _categoryOptions.length) {
      setState(() {
        _categoryOptions.removeAt(index);
      });
    }
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
              child: ListView.builder(
                itemCount: addText.length,
                itemBuilder: (context, index) {
                  String id = addText[index].id;
                  return Dismissible(
                    key: Key(id),
                    background: Container(
                      color: Colors.red,
                      child: Icon(Icons.delete, color: Colors.white),
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(right: 20.0),
                    ),
                    onDismissed: (direction) {
                      double amount = addText[index].amount;
                      _deleteTransaction(id, amount);
                    },
                    child: ListTile(
                      title: Text(
                        '${addText[index].category} - \$${addText[index].amount.toStringAsFixed(2)}',
                      ),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton.icon(
              icon: Icon(Icons.save),
              label: Text('Save'),
              onPressed: _add,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChartPage()), // 跳轉到 ChartPage
                );
              },
              child: Text('chart'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Calendar()), // 跳轉到 Calendar
                );
              },
              child: Text('顯示日曆'),
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
