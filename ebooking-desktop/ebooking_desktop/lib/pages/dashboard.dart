import 'package:ebooking_desktop/providers/admin_provider.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
// Make sure this import points to your actual drawer.dart file location
import 'package:ebooking_desktop/widgets/drawer.dart';
import 'package:provider/provider.dart';

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
    BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 8)]),
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
    final accommodationWithHighestRents = Provider.of<AdminProvider>(context, listen: false).getHighestRent();
    final accommodationWithLowestRents = Provider.of<AdminProvider>(context, listen: false).getLowestRent();
    final activeUsers = Provider.of<AdminProvider>(context, listen: false).profiles.length;
    final activeProperties = Provider.of<AdminProvider>(context, listen: false).accommodations.length;
    final reservations = Provider.of<AdminProvider>(context, listen: false).reservations;
    calculateNumberOfRentsPerDay() {
      final List<BarChartGroupData> barGroups = [];
      
      List<DateTime> last30Days = [];
      DateTime today = DateTime.now();
      for (int i = 0; i < 30; i++) {
        last30Days.add(today.subtract(Duration(days: i)));
      }

      Map<DateTime, int> counts = {};

      for (var day in last30Days) {
        counts[day] = reservations.where((reservation) => reservation.startDate.isBefore(day.add(Duration(days: 1))) && reservation.endDate.isAfter(day.subtract(Duration(days: 1)))).length;
      }

      for (int i = 0; i < last30Days.length; i++) {
        barGroups.add(BarChartGroupData(x: last30Days[i].day, barRods: [BarChartRodData(toY: counts[last30Days[i]] != null ? counts[last30Days[i]]!.toDouble() : 0)]));
      }
      return barGroups;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
      ),
      drawer: CustomDrawer(),
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
                  label: 'Property with Highest Price',
                  value: '${accommodationWithHighestRents.name} - ${accommodationWithHighestRents.pricePerNight}',
                ),
                buildStatCard(
                  icon: Icons.attach_money,
                  label: 'Property with Lowest Price',
                  value: '${accommodationWithLowestRents.name} - ${accommodationWithLowestRents.pricePerNight}',
                ),
                buildStatCard(
                  icon: Icons.person,
                  label: 'Number of Active Users',
                  value: activeUsers.toString(),
                ),
                buildStatCard(
                  icon: Icons.home,
                  label: 'Number of Active Properties',
                  value: activeProperties.toString(),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              'Trends of Rents for Last Month',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 16),
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
                  
                  barGroups: calculateNumberOfRentsPerDay(),
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
