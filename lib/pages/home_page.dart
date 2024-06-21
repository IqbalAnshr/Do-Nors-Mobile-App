import 'package:flutter/material.dart';
import '../components/navigation.dart';
import '../components/drawer.dart';
import '../pages/dashboard.dart';
import '../components/appbar.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int _selectedIndex = 0;

  Widget _buildBody(int index) {
    switch (index) {
      case 0:
        return Dashboard();
      case 1:
        return Page2();
      case 3:
        return Page4();
      case 4:
        return Page3();
      default:
        return Container();
    }
  }

  List _pagenames = [
    'Dashboard',
    'Search',
    'Add',
    'Donation Request',
    'Profile',
  ];

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: _selectedIndex == 0
          ? HomeAppBar(scaffoldKey: _scaffoldKey)
          : CustomAppBar(
              title: _pagenames[_selectedIndex]), //sesuai nama halaman
      body: _buildBody(_selectedIndex),
      drawer: CustomDrawer(),
      bottomNavigationBar: FluidNavBar(
        selectedIndex: _selectedIndex,
        // onNavItemTapped: _onNavItemTapped,
      ),
    );
  }
}

class Page2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Page 2',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}

class Page3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Page 3',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}

class Page4 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Page 4',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}
