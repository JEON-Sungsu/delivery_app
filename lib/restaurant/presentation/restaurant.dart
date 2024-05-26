import 'package:delivery_app/restaurant/component/restaurant_card.dart';
import 'package:delivery_app/restaurant/presentation/restaurant_detail_screen.dart';
import 'package:delivery_app/restaurant/provider/restaurant_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Restaurant extends ConsumerWidget {
  const Restaurant({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(restaurantProvider);

    if (data.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Container(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView.separated(
            itemBuilder: (_, index) {
              final item = data[index];

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => RestaurantDetailScreen(
                          id: item.id,
                        )),
                  );
                },
                child: RestaurantCard.fromModel(model: item),
              );
            },
            separatorBuilder: (_, index) {
              return const SizedBox(
                height: 16,
              );
            },
            itemCount: data.length,
          ),
          ),
        ),
      );
  }
}
