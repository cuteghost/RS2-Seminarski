import 'package:ebooking_desktop/models/profile_model.dart';
import 'package:ebooking_desktop/providers/admin_provider.dart';
import 'package:flutter/material.dart';
import 'package:ebooking_desktop/widgets/drawer.dart';
import 'package:provider/provider.dart';


class UsersManagementPage extends StatelessWidget {
  const UsersManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    const crossAxisCount = 6;
    final users = Provider.of<AdminProvider>(context, listen: false).profiles;
    return Scaffold(
    drawer: const CustomDrawer(),
      appBar: AppBar(
        title: const Text('Users Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Handle search action
            },
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(8.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount, // Adjust based on screen size
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
          childAspectRatio: 1 / 1.2, // Adjust the aspect ratio of the card
        ),
        itemCount: users.length, // The number of items to show
        itemBuilder: (context, index) {
          return UserCard(user: users[index]);
        },
      ),
    );
  }
}

class UserCard extends StatelessWidget {
  final Profile user;
  
  const UserCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8), // Rounded corners for Card
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Image(
              image: FileImage(user.profilePicture),
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              user.displayName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(user.emailAddress), // Replace with actual property location
          ),
          OverflowBar(
            alignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  // Handle directions action
                },
              ),
],
          ),
        ],
      ),
    );
  }
}
