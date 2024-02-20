import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
// Make sure this import points to your actual drawer.dart file location
import 'package:ebooking_desktop/widgets/drawer.dart';

void main() {
  runApp(DashboardApp());
}

class DashboardApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dashboard',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: DashboardPage(),
    );
  }
}

class DashboardPage extends StatelessWidget {
  // Dummy data for the bar chart
  final List<BarChartGroupData> barGroups = [
    BarChartGroupData(x: 1, barRods: [BarChartRodData(y: 8)]),
    BarChartGroupData(x: 2, barRods: [BarChartRodData(y: 8)]),
    BarChartGroupData(x: 3, barRods: [BarChartRodData(y: 10)]),
    BarChartGroupData(x: 4, barRods: [BarChartRodData(y: 14)]),
    BarChartGroupData(x: 5, barRods: [BarChartRodData(y: 15)]),
    BarChartGroupData(x: 6, barRods: [BarChartRodData(y: 13)]),
    BarChartGroupData(x: 7, barRods: [BarChartRodData(y: 10)]),
    BarChartGroupData(x: 8, barRods: [BarChartRodData(y: 8)]),
    BarChartGroupData(x: 9, barRods: [BarChartRodData(y: 10)]),
    BarChartGroupData(x: 10, barRods: [BarChartRodData(y: 14)]),
    BarChartGroupData(x: 11, barRods: [BarChartRodData(y: 15)]),
    BarChartGroupData(x: 12, barRods: [BarChartRodData(y: 13)]),
    BarChartGroupData(x: 13, barRods: [BarChartRodData(y: 10)]),BarChartGroupData(x: 0, barRods: [BarChartRodData(y: 8)]),
    BarChartGroupData(x: 14, barRods: [BarChartRodData(y: 10)]),
    BarChartGroupData(x: 15, barRods: [BarChartRodData(y: 14)]),
    BarChartGroupData(x: 16, barRods: [BarChartRodData(y: 15)]),
    BarChartGroupData(x: 17, barRods: [BarChartRodData(y: 13)]),
    BarChartGroupData(x: 18, barRods: [BarChartRodData(y: 10)]),BarChartGroupData(x: 0, barRods: [BarChartRodData(y: 8)]),
    BarChartGroupData(x: 19, barRods: [BarChartRodData(y: 10)]),
    BarChartGroupData(x: 20, barRods: [BarChartRodData(y: 14)]),
    BarChartGroupData(x: 21, barRods: [BarChartRodData(y: 15)]),
    BarChartGroupData(x: 22, barRods: [BarChartRodData(y: 13)]),
    BarChartGroupData(x: 23, barRods: [BarChartRodData(y: 10)]),BarChartGroupData(x: 0, barRods: [BarChartRodData(y: 8)]),
    BarChartGroupData(x: 24, barRods: [BarChartRodData(y: 10)]),
    BarChartGroupData(x: 25, barRods: [BarChartRodData(y: 14)]),
    BarChartGroupData(x: 26, barRods: [BarChartRodData(y: 15)]),
    BarChartGroupData(x: 27, barRods: [BarChartRodData(y: 13)]),
    BarChartGroupData(x: 28, barRods: [BarChartRodData(y: 10)]),
    BarChartGroupData(x: 29, barRods: [BarChartRodData(y: 10)]),
    BarChartGroupData(x: 30, barRods: [BarChartRodData(y: 155)]),
  ];

  // Function to build a stat card
  Widget buildStatCard({required IconData icon, required String label, required String value}) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Rounded corners
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: DashboardStat(
          icon: icon,
          label: label,
          value: value,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
      ),
      drawer: CustomDrawer(), // Ensure you have this CustomDrawer class in your project
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            
            SizedBox(height: 32),
            Wrap(
              alignment: WrapAlignment.spaceEvenly,
              runSpacing: 16.0,
              children: <Widget>[
                buildStatCard(
                  icon: Icons.attach_money,
                  label: 'Property with Highest # Rents',
                  value: 'Property A',
                ),
                buildStatCard(
                  icon: Icons.attach_money,
                  label: 'Property with Lowest # Rents',
                  value: 'Property B',
                ),
                buildStatCard(
                  icon: Icons.account_circle,
                  label: 'Account with Most Rents',
                  value: 'User XYZ',
                ),
                buildStatCard(
                  icon: Icons.person,
                  label: 'Number of Active Users',
                  value: '1000',
                ),
                buildStatCard(
                  icon: Icons.home,
                  label: 'Number of Active Properties',
                  value: '200',
                ),
                buildStatCard(
                  icon: Icons.home,
                  label: 'Number of Active Properties',
                  value: '200',
                ),
                buildStatCard(
                  icon: Icons.home,
                  label: 'Number of Active Properties',
                  value: '200',
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              'Trends of Rents for Last Month',
              style: TextStyle(fontSize: 20),
            ),
            Container(
              height: 250,
              child: BarChart(
                BarChartData(
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(
                      color: const Color(0xff37434d),
                      width: 1,
                    ),
                  ),
                  
                  barGroups: barGroups,
                ),
              ),

            ),
            
          ],
        ),
      ),
    );
  }
}

class DashboardStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const DashboardStat({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 24),
        SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 16),
            ),
            Text(
              value,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }
}
