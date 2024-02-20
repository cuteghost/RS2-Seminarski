import 'package:flutter/material.dart';
import 'package:ebooking_desktop/widgets/drawer.dart';
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Property Management',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),
      home: PropertyManagementPage(),
    );
  }
}

class PropertyManagementPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Using MediaQuery to get the screen width and calculate the number of items in a row
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = 150.0; // Desired width of each card
    final crossAxisCount = 6;
    return Scaffold(
    drawer: CustomDrawer(),
      appBar: AppBar(
        title: Text('Property Management'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Handle search action
            },
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(8.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount, // Adjust based on screen size
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
          childAspectRatio: 1 / 1.2, // Adjust the aspect ratio of the card
        ),
        itemCount: 20, // The number of items to show
        itemBuilder: (context, index) {
          return PropertyCard();
        },
      ),
    );
  }
}

class PropertyCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8), // Rounded corners for Card
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: Image.network(
              'https://via.placeholder.com/150', // Replace with your image URL
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Property X', // Replace with actual property name
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text('Sarajevo'), // Replace with actual property location
          ),
          ButtonBar(
            alignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  // Handle play action
                },
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  // Handle directions action
                },
              ),
              PopupMenuButton<String>(
                onSelected: (String result) {},
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                      value: 'Block', child: Row(children: [
                        Icon(Icons.block),
                        SizedBox(width: 8),
                        Text('Block')
                      ])),
                  const PopupMenuItem<String>(
                      value: 'Reports',
                      child: Row(children: [
                        Icon(Icons.report),
                        SizedBox(width: 8),
                        Text('Reports')
                      ])),
                  const PopupMenuItem<String>(
                      value: 'Promote', child: Row(children: [
                        Icon(Icons.upgrade_outlined),
                        SizedBox(width: 8),
                        Text('Promote')
                      ])),
                ],
                icon: Icon(Icons.more_vert),
              )
            ],
          ),
        ],
      ),
    );
  }
}
