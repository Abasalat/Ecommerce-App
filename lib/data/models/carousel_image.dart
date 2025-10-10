class CarouselImage {
  final String imageUrl;

  CarouselImage({required this.imageUrl});

  factory CarouselImage.fromJson(Map<String, dynamic> json) {
    return CarouselImage(imageUrl: json['imageUrl']);
  }
}
