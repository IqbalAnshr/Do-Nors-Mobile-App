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
      NavItem(Icons.search_outlined, "Search"),
      NavItem(Icons.add, "Add"),
      NavItem(Icons.explore_outlined, "Explore"),
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
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0), // Margin
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
                      onPressed: () {},
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
