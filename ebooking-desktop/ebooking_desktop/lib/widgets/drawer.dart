import 'package:ebooking_desktop/pages/countries/manageCountry.dart';
import 'package:ebooking_desktop/pages/dashboard.dart';
import 'package:ebooking_desktop/pages/manageProperties.dart';
import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'My App',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=> DashboardPage()));
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () {
              // Add your settings page navigation logic here
            },
          ),
          ListTile(
            leading: Icon(Icons.location_city_outlined),
            title: Text('Manage Locations'),
            onTap: () { Navigator.push(context, MaterialPageRoute(builder: (context)=> ManageCountryPage())); },
          ),
          ListTile(
            leading: Icon(Icons.supervised_user_circle_rounded),
            title: Text('Manage Users'),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.house),
            title: Text('Manage Properties'),
            onTap: () { Navigator.push(context, MaterialPageRoute(builder: (context)=> PropertyManagementPage())); },
          ),
          ListTile(
            leading: Icon(Icons.report),
            title: Text('Reports'),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.message),
            title: Text('Messenger'),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: () {
              // Add your logout logic here
            },
          ),
        ],
      ),
    );
  }
}