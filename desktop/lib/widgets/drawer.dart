import 'package:ebooking_desktop/pages/countries/manageCountry.dart';
import 'package:ebooking_desktop/pages/dashboard.dart';
import 'package:ebooking_desktop/pages/login.dart';
import 'package:ebooking_desktop/pages/manageProperties.dart';
import 'package:ebooking_desktop/pages/manageUsers.dart';
import 'package:ebooking_desktop/pages/messenger_screen.dart';
import 'package:ebooking_desktop/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'eBooking Admin',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=>  DashboardPage()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.location_city_outlined),
            title: const Text('Manage Locations'),
            onTap: () { Navigator.push(context, MaterialPageRoute(builder: (context)=> const ManageCountryPage())); },
          ),
          ListTile(
            leading: const Icon(Icons.supervised_user_circle_rounded),
            title: const Text('Manage Users'),
            onTap: () { Navigator.push(context, MaterialPageRoute(builder: (context)=> const UsersManagementPage())); },
          ),
          ListTile(
            leading: const Icon(Icons.house),
            title: const Text('Manage Properties'),
            onTap: () { Navigator.push(context, MaterialPageRoute(builder: (context)=> const PropertyManagementPage())); },
          ),
          ListTile(
            leading: const Icon(Icons.message),
            title: const Text('Messenger'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ContactListScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
            },
          ),
        ],
      ),
    );
  }
}