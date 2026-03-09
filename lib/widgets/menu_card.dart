import 'package:flutter/material.dart';
import 'package:dinebook/menu_detail_page.dart';

class MenuCard extends StatelessWidget {
  final String title;
  final String description;
  final String imageUrl;

  const MenuCard({
    Key? key,
    required this.title,
    required this.description,
    required this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MenuDetailPage(
              title: title,
              description: description,
              imageUrls: [imageUrl], // ✅ Updated to match new constructor
            ),
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.all(12),
        elevation: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(imageUrl, fit: BoxFit.cover),
            Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 6),
                  Text(description),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MenuDetailPage(
                            title: title,
                            description: description,
                            imageUrls: [imageUrl],
                          ),
                        ),
                      );
                    },
                    child: Text("View Details"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
