import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? actions;

  const CustomAppBar({
    Key? key,
    this.title,
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: title != null
          ? Text(title!,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 25,
                  fontWeight: FontWeight.bold))
          : null,
      centerTitle: true,
      toolbarHeight: 70,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      leading: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Container(
          padding: EdgeInsets.all(10),
          margin: EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.grey[200],
          ),
          child: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
        ),
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(70);
}

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const HomeAppBar({required this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.red[100],
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
