class Cryptocurrency {
  final String id;
  final String name;
  final String symbol;
  final double currentPrice;
  final double priceChangePercentage24h;
  final String image;

  Cryptocurrency({
    required this.id,
    required this.name,
    required this.symbol,
    required this.currentPrice,
    required this.priceChangePercentage24h,
    required this.image,
  });

  factory Cryptocurrency.fromJson(Map<String, dynamic> json) {
    return Cryptocurrency(
      id: json['id'],
      name: json['name'],
      symbol: json['symbol'],
      currentPrice: json['current_price']?.toDouble() ?? 0.0,
      priceChangePercentage24h: json['price_change_percentage_24h']?.toDouble() ?? 0.0,
      image: json['image'],
    );
  }
}