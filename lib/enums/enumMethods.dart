import 'package:attention_map/enums/marker_type.dart';

class EnumMethods {

  static String enumToString(dynamic enumMember) {
    return enumMember.toString().split('.').last;
  }

  static String getDescription(dynamic enumMember) {
    Map<MarkerType, String> descriptions = {
      MarkerType.camera : 'На этом участке стоит камера',
      MarkerType.other : 'Особенность',
      MarkerType.help : 'Кому-то нужна помощь',
      MarkerType.dtp : 'ДТП в этом месте',
      MarkerType.danger : 'Опасный участок дороги',
      MarkerType.dps : 'Пост ДПС',
      MarkerType.monument : 'Достопримечательность',
    };
    if (descriptions.containsKey(enumMember)){
      return descriptions[enumMember];
    }
    else {
      return '-';
    }
  }



}