import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
class _ExpensePage extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  _ExpensePage({Key? key}) : super(key: key);

  @override
  _ExpensePageState createState() => _ExpensePageState();
}

class _ExpensePageState extends State<_ExpensePage> {
  List<_SalesData> data = [
    _SalesData('1', 35),
    _SalesData('6', 28),
    _SalesData('18', 34),
    _SalesData('24', 32),
    _SalesData('30', 40)
  ];
  List<_SalesData> data2 = [
    _SalesData('1', 10),
    _SalesData('6', 15),
    _SalesData('18', 34),
    _SalesData('24', 40),
    _SalesData('30', 60)
  ];
  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
          //Initialize the chart widget
          SfCartesianChart(
              primaryXAxis: CategoryAxis(),
              // Chart title
              title: ChartTitle(text: 'Month To Date Trends'),
              // Enable legend
              legend: Legend(isVisible: true),
              // Enable tooltip
              tooltipBehavior: TooltipBehavior(enable: true),
              series: <ChartSeries<_SalesData, String>>[
                LineSeries<_SalesData, String>(
                    dataSource: data2,
                    xValueMapper: (_SalesData sales, _) => sales.year,
                    yValueMapper: (_SalesData sales, _) => sales.sales,
                    name: 'Revenue',
                    // Enable data label
                    dataLabelSettings: DataLabelSettings(isVisible: false)),
                LineSeries<_SalesData, String>(
                    dataSource: data,
                    xValueMapper: (_SalesData sales, _) => sales.year,
                    yValueMapper: (_SalesData sales, _) => sales.sales,
                    name: 'Expenses',
                    // Enable data label
                    dataLabelSettings: DataLabelSettings(isVisible: false))

              ]),
          Row(
            children: [
              Column(
                children: [
                  const Text("0%"),
                  const Text('Daily Expenses'),
                ],
              ),
              Column(
                children: [
                  const Text('Average'),
                  const Text("\$0.00"),
                  const Text('Daily Expenses'),
                ],
              ),
              Column(
                children: [
                  const Text('Month to Date'),
                  const Text("\$0.00"),
                  const Text('Expenses'),
                ],
              )
            ],
          )
        ]);

  }
}

class _SalesData {
  _SalesData(this.year, this.sales);

  final String year;
  final double sales;
}