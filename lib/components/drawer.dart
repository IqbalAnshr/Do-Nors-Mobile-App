import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.white, // Ubah warna latar belakang drawer menjadi putih
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/pattern_organ.jpg'),
                  fit: BoxFit.cover,
                ),
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      ' ', // text apa aja
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            DrawerNavigationItem(
              iconData: Icons.message_outlined,
              title: 'Message',
              onTap: () {
                // Action when "Message" drawer item is tapped
              },
            ),
            DrawerNavigationItem(
              iconData: Icons.bookmark_outline,
              title: 'Saved Donations',
              onTap: () {
                // Action when "Saved Post" drawer item is tapped
              },
            ),
            DrawerNavigationItem(
              iconData: Icons.headset_outlined,
              title: 'Customer Service',
              onTap: () {
                // Action when "Customer Service" drawer item is tapped
              },
            ),
            DrawerNavigationItem(
              iconData: Icons.info_outline,
              title: 'About',
              onTap: () {
                // Action when "About" drawer item is tapped
              },
            ),
          ],
        ),
      ),
    );
  }
}

class DrawerNavigationItem extends StatelessWidget {
  final IconData iconData;
  final String title;
  final Function() onTap;

  const DrawerNavigationItem({
    Key? key,
    required this.iconData,
    required this.title,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        iconData,
        color: Color(0xFFFF2156),
        size: 30,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: Colors.black,
        ),
      ),
      onTap: onTap,
    );
  }
}
