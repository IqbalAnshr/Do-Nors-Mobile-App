import 'package:flutter/material.dart';

class FluidNavBar extends StatelessWidget {
  final int selectedIndex;
  // final Function(int) onNavItemTapped;

  // FluidNavBar({required this.selectedIndex, required this.onNavItemTapped});

  FluidNavBar({required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    List<NavItem> _navItems = [
      NavItem(Icons.home_outlined, "Dashboard"),
      NavItem(Icons.explore_outlined, "find_requests"),
      NavItem(Icons.add, "Add"),
      NavItem(Icons.chat_outlined, "Messages"),
      NavItem(Icons.person_outline_rounded, "Profile"),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(100),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: BottomAppBar(
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _navItems.map((item) {
              var index = _navItems.indexOf(item);
              return index == 2
                  ? FloatingActionButton(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return Container(
                              padding: EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Text(
                                    'What do you want to do?',
                                    style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 16.0),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pushNamed(context,
                                          '/add_request'); // Tutup modal
                                    },
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor: Color(0xFFFF2156),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 24, vertical: 20),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons
                                            .request_page), // Icon di sebelah kiri teks
                                        SizedBox(
                                            width:
                                                8), // Spasi antara icon dan teks
                                        Text(
                                          'Request Donation',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 16.0),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pushNamed(
                                          context, '/add_donor');
                                    },
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor: Color(0xFFFF2156),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 24, vertical: 20),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons
                                            .volunteer_activism), // Icon di sebelah kiri teks
                                        SizedBox(
                                            width:
                                                8), // Spasi antara icon dan teks
                                        Text(
                                          'Give Donation',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      backgroundColor:
                          Color(0xFFFF2156), // Warna latar belakang
                      child: Icon(
                        item.icon,
                        color: Colors.white, // Warna ikon
                        size: 30.0,
                      ),
                    )
                  : IconButton(
                      // onPressed: () => onNavItemTapped(index),
                      onPressed: () =>
                          Navigator.pushNamed(context, '/' + item.title),
                      icon: Icon(
                        item.icon,
                        size: 30.0,
                        color: selectedIndex == index
                            ? Color(0xFFFF2156)
                            : Colors.grey,
                      ),
                    );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class NavItem {
  IconData icon;
  String title;

  NavItem(this.icon, this.title);
}
