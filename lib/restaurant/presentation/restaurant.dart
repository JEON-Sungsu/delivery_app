import 'package:delivery_app/restaurant/component/restaurant_card.dart';
import 'package:flutter/material.dart';

class Restaurant extends StatelessWidget {
  const Restaurant({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: RestaurantCard(
            image: Image.asset('asset/img/food/ddeok_bok_gi.jpg'),
            tags: ['떡볶이', '치즈', '매운맛'],
            name: '불타는 떡볶이',
            ratingCount: 100,
            deliveryTime: 15,
            deliveryFee: 2000,
            rating: 4.52,
          ),
        ),
      ),
    );
  }
}
