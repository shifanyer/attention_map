class EnumMethods {

  static enumToString(dynamic enumMember) {
    return enumMember.toString().split('.').last;
  }

}