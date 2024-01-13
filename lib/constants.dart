import 'package:flutter/material.dart';

// Public enum
enum PostType { accident, robberyAssault, fireAccident }

Map<PostType, IconData> crimeTypeIcons = {
  PostType.accident: Icons.pin_drop,
  PostType.robberyAssault: Icons.pin_drop,
  PostType.fireAccident: Icons.pin_drop,
};

Map<PostType, Color> crimeTypeColors = {
  PostType.accident: Colors.blue,
  PostType.robberyAssault: Colors.purple,
  PostType.fireAccident: Colors.orange,
};

Color getColorForType(PostType crimeType) {
  switch (crimeType) {
    case PostType.accident:
      return Colors.blue; // Or any color you prefer for accident type
    case PostType.robberyAssault:
      return Colors.purple; // Or any color for robbery/assault type
    case PostType.fireAccident:
      return Colors.orange; // Or any color for fire accident type
    default:
      return Colors.black; // Default color for other types or unknown
  }
}

IconData getIconForType(PostType type) {
  switch (type) {
    case PostType.accident:
      return Icons.location_pin;
    case PostType.robberyAssault:
      return Icons.location_pin;
    case PostType.fireAccident:
      return Icons.location_pin;
    default:
      return Icons.error; // Default icon if not found
  }
}

String getCrimeType(PostType type) {
  switch (type) {
    case PostType.accident:
      return 'CarAccident';
    case PostType.robberyAssault:
      return 'robberyAssault';
    case PostType.fireAccident:
      return 'fireAccident';
    default:
      return 'accident'; // Default value if not found
  }
}
