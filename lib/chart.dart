import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';


class ChartPage extends StatefulWidget {
  @override
  _ChartPageState createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
  List<Map<String, dynamic>> addText = [];

  @override
  void initState() {
    super.initState();
    _getDataFromFirebase();
  }

  void _getDataFromFirebase() {
    FirebaseFirestore.instance.collection('account').get().then((querySnapshot) {
      List<Map<String, dynamic>> texts = [];
      querySnapshot.docs.forEach((doc) {
        texts.add({
          'category': doc.data()['category'] ?? '未知類別',
          'amount': doc.data()['amount'] ?? 0.0,
        });
      });
      setState(() {
        addText = texts;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data Chart'),
      ),
      body: _buildChart(),
    );
  }

  Widget _buildChart() {
    List<PieChartSectionData> pieChartSections = _getPieChartSections();
    return Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: PieChart(
          PieChartData(
            sections: pieChartSections,
            centerSpaceRadius: 40,
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> _getPieChartSections() {
    Map<String, double> categoryAmounts = {};
    addText.forEach((data) {
      String category = data['category'];
      double amount = data['amount'];
      if (categoryAmounts.containsKey(category)) {
        categoryAmounts[category] = categoryAmounts[category]! + amount;
      } else {
        categoryAmounts[category] = amount;
      }
    });

    int colorIndex = 0;
    List<Color> colors = [
      Colors.blue,
      Colors.green,
      Colors.red,
      Colors.yellow,
      Colors.orange,
      Colors.purple,
    ];

    List<PieChartSectionData> sections = [];
    categoryAmounts.forEach((category, amount) {
      sections.add(
        PieChartSectionData(
          color: colors[colorIndex],
          value: amount,
          title: '$category\n${amount.toStringAsFixed(2)}',
          radius: 80,
          titleStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      );
      colorIndex = (colorIndex + 1) % colors.length;
    });

    return sections;
  }
}