import 'package:flutter/material.dart';

class CustomMarkerWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  const CustomMarkerWidget({super.key, required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: CustomMarkerClipper(),
      child: Container(
        height: 40,
        constraints: BoxConstraints(maxWidth: 125),
        decoration: BoxDecoration(
          color: Color(0xFFFFFFF5),
          boxShadow: [
            BoxShadow(blurRadius: 5, spreadRadius: 5, color: Colors.black45),
          ],
        ),
        padding: EdgeInsets.only(left: 2, top: 2, right: 2, bottom: 13),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 2,
          children: [
            CircleAvatar(radius: 16, child: Icon(icon, size: 18)),
            Flexible(child: Text(title, maxLines: 1, style: TextStyle(fontSize: 12))),
          ],
        ),
      ),
    );
  }
}

class CustomMarkerClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    double w = size.width;
    double exh = size.height;
    double h = exh - 10;
    double r = h / 2;

    path.moveTo(r, h);
    path.arcToPoint(Offset(r, 0), radius: Radius.circular(r));
    path.lineTo(w - r, 0);
    path.arcToPoint(Offset(w - r, h), radius: Radius.circular(r));
    path.lineTo(w / 2 - 8, h);
    path.lineTo(w / 2, exh);
    path.lineTo(w / 2 + 8, h);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}
