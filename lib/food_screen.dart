import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'cart_provider.dart';
import 'cart_screen.dart';

class FoodScreen extends StatelessWidget {
  final List<Map<String, dynamic>> foods = [
    {'id': '1', 'title': 'Burger', 'price': 5.99, 'image': 'assets/burger.png'},
    {'id': '2', 'title': 'Pizza', 'price': 8.99, 'image': 'assets/pizza.png'},
    // 추가 음식 데이터
  ];

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('음식 선택'),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.of(context).pushNamed(CartScreen.routeName);
            },
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(10.0),
        itemCount: foods.length,
        itemBuilder: (ctx, i) => FoodItem(
          id: foods[i]['id'],
          title: foods[i]['title'],
          price: foods[i]['price'],
          image: foods[i]['image'],
          onAddToCart: () {
            cart.addItem(foods[i]['id'], foods[i]['title'], foods[i]['price']);
          },
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3 / 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
      ),
    );
  }
}

class FoodItem extends StatelessWidget {
  final String id;
  final String title;
  final double price;
  final String image;
  final VoidCallback onAddToCart;

  FoodItem({
    required this.id,
    required this.title,
    required this.price,
    required this.image,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return GridTile(
      child: Image.asset(image, fit: BoxFit.cover),
      footer: GridTileBar(
        backgroundColor: Colors.black87,
        title: Text(title, textAlign: TextAlign.center),
        subtitle: Text('\$${price.toStringAsFixed(2)}', textAlign: TextAlign.center),
        trailing: IconButton(
          icon: Icon(Icons.add_shopping_cart),
          onPressed: onAddToCart,
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
    );
  }
}
