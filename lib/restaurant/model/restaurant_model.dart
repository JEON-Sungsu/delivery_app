enum RestaurantPriceRange{
  expensive,
  medium,
  cheap,
}

class RestaurantModel {
  final String id;
  final String name;
  final String thumbUrl;
  final List<String> tags;
  final RestaurantPriceRange priceRange;
  final double ratings;
  final int ratingsCount;
  final int deliveryTime;
  final int deliveryFee;

  const RestaurantModel({
    required this.id,
    required this.name,
    required this.thumbUrl,
    required this.tags,
    required this.priceRange,
    required this.ratings,
    required this.ratingsCount,
    required this.deliveryTime,
    required this.deliveryFee,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'thumbUrl': thumbUrl,
      'tags': tags,
      'priceRange': priceRange,
      'ratings': ratings,
      'ratingsCount': ratingsCount,
      'deliveryTime': deliveryTime,
      'deliveryFee': deliveryFee,
    };
  }

  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    return RestaurantModel(
      id: json['id'] as String,
      name: json['name'] as String,
      thumbUrl: json['thumbUrl'] as String,
      tags: List<String>.from(json['tags']),
      priceRange: RestaurantPriceRange.values.firstWhere((e) => e.name == json['priceRange']),
      ratings: json['ratings'] as double,
      ratingsCount: json['ratingsCount'] as int,
      deliveryTime: json['deliveryTime'] as int,
      deliveryFee: json['deliveryFee'] as int,
    );
  }
}