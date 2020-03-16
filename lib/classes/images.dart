class Images {

  String name;
  String path;

  Images(this.name, this.path);

  factory Images.fromJson(dynamic json) {
    return Images(
        json['files'] as String,
        json['path'] as String);
  }

  @override
  String toString() {
    return '{${this.name}, ${this.path} }';
  }
}