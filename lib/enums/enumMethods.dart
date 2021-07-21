import 'package:attention_map/enums/marker_type.dart';
import '../global/languages.dart' as languages;
import '../global/globals.dart' as globals;

class EnumMethods {

  static String enumToString(dynamic enumMember) {
    return enumMember.toString().split('.').last;
  }

  static String getDescription(dynamic enumMember) {
    Map<MarkerType, String> descriptions = {
      // MarkerType.camera : 'На этом участке стоит камера',
      MarkerType.camera :   languages.textsMap[globals.languages]['enums']['enumMethods']['getDescription']['camera'],
      MarkerType.other :    languages.textsMap[globals.languages]['enums']['enumMethods']['getDescription']['other'],
      MarkerType.help :     languages.textsMap[globals.languages]['enums']['enumMethods']['getDescription']['help'],
      MarkerType.dtp :      languages.textsMap[globals.languages]['enums']['enumMethods']['getDescription']['dtp'],
      MarkerType.danger :   languages.textsMap[globals.languages]['enums']['enumMethods']['getDescription']['danger'],
      MarkerType.dps :      languages.textsMap[globals.languages]['enums']['enumMethods']['getDescription']['dps'],
      MarkerType.monument : languages.textsMap[globals.languages]['enums']['enumMethods']['getDescription']['monument'],
    };
    if (descriptions.containsKey(enumMember)){
      return descriptions[enumMember];
    }
    else {
      return '-';
    }
  }

  static String translate(dynamic enumMember) {
    Map<MarkerType, String> descriptions = {
      MarkerType.camera :   languages.textsMap[globals.languages]['enums']['enumMethods']['translate']['camera'],
      MarkerType.other :    languages.textsMap[globals.languages]['enums']['enumMethods']['translate']['other'],
      MarkerType.help :     languages.textsMap[globals.languages]['enums']['enumMethods']['translate']['help'],
      MarkerType.dtp :      languages.textsMap[globals.languages]['enums']['enumMethods']['translate']['dtp'],
      MarkerType.danger :   languages.textsMap[globals.languages]['enums']['enumMethods']['translate']['danger'],
      MarkerType.dps :      languages.textsMap[globals.languages]['enums']['enumMethods']['translate']['dps'],
      MarkerType.monument : languages.textsMap[globals.languages]['enums']['enumMethods']['translate']['monument'],
    };
    if (descriptions.containsKey(enumMember)){
      return descriptions[enumMember];
    }
    else {
      return '-';
    }
  }



}