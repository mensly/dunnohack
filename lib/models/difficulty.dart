enum Difficulty {
  easy, medium, hard
}

extension ToString on Difficulty {
  String toApiString() {
    return toString().split('.').last;
  }
  String toLabelString() {
    final name = toString().split('.').last;
    return "${name[0].toUpperCase()}${name.substring(1)}";
  }
}