import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const HomeAppBar({required this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: SvgPicture.asset(
          'assets/svg/icon_drawer.svg',
          width: 24,
          height: 24,
        ),
        onPressed: () {
          scaffoldKey.currentState?.openDrawer();
        },
        tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.notifications_outlined,
            size: 35,
            color: Color(0xFFFF2156),
          ),
          onPressed: () {
            // Action when notification icon is pressed
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
