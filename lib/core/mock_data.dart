class Product {
  final String id;
  final String name;
  final String category;
  final double price;
  final String unit;
  final String farmerName;
  final String location;
  final String imageUrl;
  final double rating;
  final int reviewsCount;
  final String description;
  final int stockQuantity;
  final String harvestDate;

  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.unit,
    required this.farmerName,
    required this.location,
    required this.imageUrl,
    required this.rating,
    this.reviewsCount = 0,
    required this.description,
    required this.stockQuantity,
    this.harvestDate = 'Oct 2023',
  });
}

class MockData {
  static final List<Product> products = [
    const Product(
      id: '1',
      name: 'Maïs Jaune Séché',
      category: 'Céréales',
      price: 15000,
      unit: 'sac (100kg)',
      farmerName: 'AgriFerme Faso',
      location: 'Bobo-Dioulasso, BF',
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCoUHG0fDwHeMkQ0WXyo1EHzsPxMECiU9A7_o0N7d-mmuQEJyOfHytyTo5rSyGZ0YvWQL_1My5elmmVYsHxr7V-p4DrNpaX4bvJjE--L5zigKhJsrofzvoqrMPh6CIVUTmbPhI9EXD646CTyT5jxJDDhjgc7CXe4aGOQuSa4r-ZCy3s6cKsVNBYaph5HD1CiRQvkE8IFSkQ13vW_sVM7npx0Fn2jB7UPTaTpuRO-ztZcsmvlAJORSjajDVA7WKE2LOxC7EinsNOiIM',
      rating: 4.8,
      reviewsCount: 34,
      stockQuantity: 50,
      description: 'Maïs jaune de première qualité, parfaitement séché au soleil. Idéal pour la consommation humaine ou la transformation animale. Les grains sont propres, triés et exempts d\'impuretés ou de moisissures.',
    ),
    const Product(
      id: '2',
      name: 'Tomates fraîches',
      category: 'Légumes',
      price: 7500,
      unit: 'caisse (25kg)',
      farmerName: 'Coopérative Maraîchère',
      location: 'Ouahigouya, BF',
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDnJ2HC37rt3ly6O08T_U7SGtretD8a04NIgzKZuBaovi5w63EfJio0-qVl4atlwiN3I89L9k2YRsWkwq9-MsEdeMfp8_sVMgh87DBinIIwbYwZ4l3hp244jf5GhTeX-6Zv61hrIAi_UNHkbLrUKJp3rknA_tm8C277wjFyffmHiaK-GqT-pvS3wY6rUGSj3fHJBeH1KAe-zeaFlfiSMzmff79k1HvMgBERC8HQizgQk0_PXB2WsnadAfyxtVysFKPV3vVRQyBJ9gE',
      rating: 4.5,
      reviewsCount: 12,
      stockQuantity: 20,
      description: 'Tomates fraîches et fermes du Nord du Burkina. Parfaites pour les sauces et les salades.',
    ),
    const Product(
      id: '3',
      name: 'Oignons Rouges',
      category: 'Légumes',
      price: 8000,
      unit: 'sac (25kg)',
      farmerName: 'Ferme Galmi Faso',
      location: 'Koudougou, BF',
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAhdkY0d931hIltGu_7t9zrW8cwZGHcQwIKDDGmMt0INWXUbwbcqHJV7qwNM1q-zOyvhnp7UmH6crbaRl0TFPvP41ahVESd5fDKps0eB9VTe37eeFgZaDhWuFHT4ms-h2iXUM9kb0p2VnJ7nv2hLQXFkBBqn3heHpbASdl3Zw8XMtwvmBCiOj4eMX8q4FRREE4kI8c3IbC_I6s4BmqOMKjQQBmZrOm4BkKFctskgE0woGq6z2CV_hnQbw-Tkh90DdeWqGZiLVWFTbk',
      rating: 4.9,
      reviewsCount: 56,
      stockQuantity: 15,
      description: 'Oignons de gros calibre, rouges et croquants. Excellente conservation.',
    ),
  ];
}
