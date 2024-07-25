import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

void showErrorDialog(BuildContext context, String message, String asset) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 250,
            child: SvgPicture.asset(asset),
          ),
          SizedBox(height: 20),
          Text(
            message,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: <Widget>[
        Center(
          child: TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Icon(Icons.arrow_forward, color: Colors.red, size: 30),
          ),
        ),
      ],
    ),
  );
}

void showSuccessDialog(
    BuildContext context, String message, String asset, String route) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 250,
            child: SvgPicture.asset(asset),
          ),
          SizedBox(height: 20),
          Text(
            message,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: <Widget>[
        Center(
          child: TextButton(
            onPressed: () {
              Navigator.pushNamed(context, route);
            },
            child: Icon(Icons.arrow_forward, color: Colors.red, size: 30),
          ),
        ),
      ],
    ),
  );
}
