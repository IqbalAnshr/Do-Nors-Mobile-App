import 'package:flutter/material.dart';
import '../components/appbar.dart';
import '../components/navigation.dart';

class SearchFilterPage extends StatefulWidget {
  @override
  _SearchFilterPageState createState() => _SearchFilterPageState();
}

class _SearchFilterPageState extends State<SearchFilterPage> {
  String? selectedLocation;
  String? selectedOrganType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Search & Filter'),
      bottomNavigationBar: FluidNavBar(selectedIndex: 1),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ),
          SizedBox(height: 20.0),
          Text(
            'Filter Options',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10.0),
          ListTile(
            leading: Icon(Icons.location_on),
            title: Text('Location'),
            subtitle: DropdownButton<String>(
              value: selectedLocation,
              hint: Text('Select Location'),
              onChanged: (String? newValue) {
                setState(() {
                  selectedLocation = newValue;
                });
              },
              items: <String>['Location A', 'Location B', 'Location C']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.category),
            title: Text('Organ Type'),
            subtitle: DropdownButton<String>(
              value: selectedOrganType,
              hint: Text('Select Organ Type'),
              onChanged: (String? newValue) {
                setState(() {
                  selectedOrganType = newValue;
                });
              },
              items: <String>['Heart', 'Liver', 'Kidney']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                // Apply filter logic here
              },
              child: Text('Apply'),
            ),
          ),
        ],
      ),
    );
  }
}
