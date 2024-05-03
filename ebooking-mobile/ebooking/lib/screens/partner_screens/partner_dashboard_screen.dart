import 'package:ebooking/providers/auth_provider.dart';
import 'package:ebooking/screens/login_screen.dart';
import 'package:ebooking/widgets/CustomPartnerBottomNavigationBar.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class PartnerDashboardScreen extends StatefulWidget {
  @override
  _PartnerDashboardScreenState createState() => _PartnerDashboardScreenState();
}

class _PartnerDashboardScreenState extends State<PartnerDashboardScreen> {
  List<double> salesData = [];
  TooltipBehavior _tooltipBehavior = TooltipBehavior(enable: true);
  final List<PieData> data = [
    PieData('Hotel', 35),
    PieData('Motel', 28),
    PieData('Inn', 34),
    PieData('Resort', 32),
    PieData('Hostel', 40),
  ];

  @override
  void initState() {
    super.initState();
    fetchSalesData();
  }

  // Future<void> fetchSalesData() async {
  //   // Replace with your API endpoint
  //   final response = await http.get('https://api.example.com/sales');

  //   if (response.statusCode == 200) {
  //     List<dynamic> data = jsonDecode(response.body);
  //     setState(() {
  //       salesData = data.map((item) => item['sales'].toDouble()).toList();
  //     });
  //   } else {
  //     throw Exception('Failed to load sales data');
  //   }
  // }
  Future<void> fetchSalesData() async {
  // Dummy data
  List<dynamic> data = [
    {"sales": 100.0},
    {"sales": 120.0},
    {"sales": 150.0},
    {"sales": 130.0},
    {"sales": 170.0},
    {"sales": 160.0},
    {"sales": 180.0},
    {"sales": 200.0},
    {"sales": 220.0},
    {"sales": 210.0},
    {"sales": 230.0},
    {"sales": 240.0}
  ];

  setState(() {
    salesData = data.map<double>((item) => item['sales'].toDouble()).toList();
  });
}

 @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Partner Dashboard'),
     actions: //logout button
      [
        IconButton(
          icon: Icon(Icons.logout),
          onPressed: () {
            Provider.of<AuthProvider>(context, listen: false).logout();
            // Navigate to the LoginScreen
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
          },
        ),
      ],
    ),
    body: SingleChildScrollView(
      child: Column (
        children: <Widget>[

          Container(
              height: MediaQuery.of(context).size.height * 0.5,
              child: SfCartesianChart(

                primaryXAxis: CategoryAxis(),
                // Chart title
                title: ChartTitle(text: 'Half yearly sales analysis'),
                // Enable tooltip
                tooltipBehavior: _tooltipBehavior,

                series: <LineSeries<SalesData, String>>[
                  LineSeries<SalesData, String>(
                    dataSource:  <SalesData>[
                      SalesData('Jan', 0),
                      SalesData('Feb', 28),
                      SalesData('Mar', 34),
                      SalesData('Apr', 32),
                      SalesData('May', 40),
                      SalesData('Jun', 0)

                    ],
                    xValueMapper: (SalesData sales, _) => sales.year,
                    yValueMapper: (SalesData sales, _) => sales.sales,
                    // Enable data label
                    dataLabelSettings: DataLabelSettings(isVisible: true)
                  )
                ]
              )
            ),
            Container(
              child: SfCircularChart(
                title: ChartTitle(text: 'Accommodation with most sales'),
                legend: Legend(isVisible: true),
                series: <PieSeries<PieData, String>>[
                  PieSeries<PieData, String>(
                    dataSource: <PieData> [
                      PieData('Hotel', 35),
                      PieData('Motel', 28),
                      PieData('Inn', 34),
                      PieData('Resort', 32),
                      PieData('Hostel', 40),
                    ],
                    xValueMapper: (PieData data, _) => data.accommodation,
                    yValueMapper: (PieData data, _) => data.sales,
                    dataLabelSettings: DataLabelSettings(isVisible: true),
                  )
                ],
              ),
            ),
          ]
        )
      ),
      bottomNavigationBar: CustomPartnerBottomNavigationBar(),
    );
  }
}
class SalesData {
  SalesData(this.year, this.sales);
  final String year;
  final double sales;
}
class PieData {
  PieData(this.accommodation, this.sales);

  final String accommodation;
  final double sales;
}