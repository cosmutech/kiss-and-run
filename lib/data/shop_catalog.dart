import 'package:flutter/material.dart';

class ShopItem {
  final String id;
  final String name;
  final String category; // 'gender', 'hair', 'shirt', 'pants', 'accessory'
  final int price;
  final dynamic value;
  final String iconEmoji;

  const ShopItem({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.value,
    required this.iconEmoji,
  });
}

class ShopCatalog {
  static const List<ShopItem> items = [
    // Genders
    ShopItem(
      id: 'char_male',
      name: 'Romeo (Male)',
      category: 'gender',
      price: 0,
      value: 'male',
      iconEmoji: '👦',
    ),
    ShopItem(
      id: 'char_female',
      name: 'Juliet (Female)',
      category: 'gender',
      price: 0,
      value: 'female',
      iconEmoji: '👧',
    ),

    // Hair Styles
    ShopItem(
      id: 'hair_0',
      name: 'Classic Hair',
      category: 'hair',
      price: 0,
      value: 0,
      iconEmoji: '💇',
    ),
    ShopItem(
      id: 'hair_1',
      name: 'Spiky Punk',
      category: 'hair',
      price: 100,
      value: 1,
      iconEmoji: '⚡',
    ),
    ShopItem(
      id: 'hair_2',
      name: 'Curly Waves',
      category: 'hair',
      price: 200,
      value: 2,
      iconEmoji: '🌀',
    ),
    ShopItem(
      id: 'hair_3',
      name: 'High Ponytail',
      category: 'hair',
      price: 250,
      value: 3,
      iconEmoji: '🎀',
    ),

    // Shirts
    ShopItem(
      id: 'shirt_0',
      name: 'Berry Pink Shirt',
      category: 'shirt',
      price: 0,
      value: Color(0xFFFF4081),
      iconEmoji: '👕',
    ),
    ShopItem(
      id: 'shirt_1',
      name: 'Electric Cyan Shirt',
      category: 'shirt',
      price: 150,
      value: Color(0xFF00E5FF),
      iconEmoji: '👕',
    ),
    ShopItem(
      id: 'shirt_2',
      name: 'Neon Lime Shirt',
      category: 'shirt',
      price: 250,
      value: Color(0xFF76FF03),
      iconEmoji: '👕',
    ),
    ShopItem(
      id: 'shirt_3',
      name: 'Midnight Onyx Hoodie',
      category: 'shirt',
      price: 400,
      value: Color(0xFF212121),
      iconEmoji: '🧥',
    ),
    ShopItem(
      id: 'shirt_4',
      name: 'Golden Champion Shirt',
      category: 'shirt',
      price: 800,
      value: Color(0xFFFFD700),
      iconEmoji: '✨',
    ),

    // Pants
    ShopItem(
      id: 'pants_0',
      name: 'Classic Jeans',
      category: 'pants',
      price: 0,
      value: Color(0xFF1976D2),
      iconEmoji: '👖',
    ),
    ShopItem(
      id: 'pants_1',
      name: 'Jet Black Joggers',
      category: 'pants',
      price: 150,
      value: Color(0xFF263238),
      iconEmoji: '👖',
    ),
    ShopItem(
      id: 'pants_2',
      name: 'Khaki Slacks',
      category: 'pants',
      price: 200,
      value: Color(0xFFD7CCC8),
      iconEmoji: '👖',
    ),

    // Accessories
    ShopItem(
      id: 'acc_0',
      name: 'None',
      category: 'accessory',
      price: 0,
      value: 0,
      iconEmoji: '🚫',
    ),
    ShopItem(
      id: 'acc_1',
      name: 'Thug Life Shades',
      category: 'accessory',
      price: 200,
      value: 1,
      iconEmoji: '🕶️',
    ),
    ShopItem(
      id: 'acc_2',
      name: 'Streetwear Cap',
      category: 'accessory',
      price: 350,
      value: 2,
      iconEmoji: '🧢',
    ),
    ShopItem(
      id: 'acc_3',
      name: 'DJ Headphones',
      category: 'accessory',
      price: 500,
      value: 3,
      iconEmoji: '🎧',
    ),
    ShopItem(
      id: 'acc_4',
      name: 'Hero Bandana',
      category: 'accessory',
      price: 650,
      value: 4,
      iconEmoji: '🧣',
    ),
    ShopItem(
      id: 'acc_5',
      name: 'Golden Angel Halo',
      category: 'accessory',
      price: 1000,
      value: 5,
      iconEmoji: '😇',
    ),
  ];
}
