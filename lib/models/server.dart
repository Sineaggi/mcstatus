class Server {
  final int? id;
  final String name;
  final String address;
  final String image;

  Server({
    this.id,
    required this.name,
    required this.address,
    required this.image,
  });

  Map<String, dynamic> toMap() {
    final map = {
      'id': id,
      'name': name,
      'address': address,
      'image': image,
    };
    map.removeWhere((key, value) => key == 'id' && value == null);
    return map;
  }

  static Server fromMapObject(Map<String, dynamic> map) {
    return Server(id: map['id'], name: map['name'], address: map['address'], image: map['image']);
  }

  @override
  String toString() {
    return 'Server{id: $id, name: $name, address: $address, image: $image}';
  }
}
