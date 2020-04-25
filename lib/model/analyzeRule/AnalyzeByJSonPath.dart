import 'package:jsonpath/json_path.dart';

class AnalyzeByJSonPath {
  final _jsonRulePattern = new RegExp(r'(?<={)\$\..+?(?=})');
  dynamic _ctx = '';

  AnalyzeByJSonPath parse(json) {
    _ctx = json;
    return this;
  }

  String getString(String rule) {
    var result = '';
    if (null == rule || rule.isEmpty) return result;
    List<String> rules;
    String elementsType;
    if (rule.contains('&&')) {
      rules = rule.split('&&');
      elementsType = '&';
    } else {
      rules = rule.split('||');
      elementsType = '|';
    }
    if (rules.length == 1) {
      if (!rule.contains('{\$.')) {
        try {
          var ob = JPath.compile(rule).search(_ctx);
          if (null == ob) return result;
          if (ob is List) {
            final builder = <String>[];
            for (var o in ob) {
              builder..add('$o')..add('\n');
            }
            result = builder.join('').replaceFirst(new RegExp(r'\n$'), '');
          } else {
            result = ob.toString();
          }
        } catch (e) {
          print(e);
        }
        return result;
      } else {
        result = rule;
        var matcher = _jsonRulePattern.allMatches(rule);
        for (var m in matcher) {
          result = result.replaceAll(
              '{${m.group(0)}}', getString(m.group(0).trim()));
        }
        return result;
      }
    } else {
      final textS = <String>[];
      for (String rl in rules) {
        var temp = getString(rl);
        if (temp.isNotEmpty) {
          textS.add('$temp');
          if ('|' == elementsType) {
            break;
          }
        }
      }
      return textS.map((s) => s.trim()).join('\n');
    }
  }

  List<String> getStringList(String rule) {
    final result = <String>[];
    if (null == rule || rule.isEmpty) return result;
    List<String> rules;
    String elementsType;
    if (rule.contains('&&')) {
      rules = rule.split('&&');
      elementsType = '&';
    } else if (rule.contains('%%')) {
      rules = rule.split('%%');
      elementsType = '%';
    } else {
      rules = rule.split('||');
      elementsType = '|';
    }
    if (rules.length == 1) {
      if (!rule.contains('{\$.')) {
        try {
          var object = JPath.compile(rule).search(_ctx);
          if (null == object) return result;
          if (object is List) {
            for (var o in object) result.add(o.toString());
          } else {
            result.add(object.toString());
          }
        } catch (e) {
          print(e);
        }
        return result;
      } else {
        var matcher = _jsonRulePattern.allMatches(rule);
        for (var m in matcher) {
          var stringList = getStringList(m.group(0).trim());
          for (var s in stringList) {
            result.add(rule.replaceAll('{${m.group(0)}}', s));
          }
        }
        return result;
      }
    } else {
      final results = <List<String>>[];
      for (var rl in rules) {
        List<String> temp = getStringList(rl);
        if (temp != null && temp.isNotEmpty) {
          results.add(temp);
          if (temp.length > 0 && '|' == elementsType) {
            break;
          }
        }
      }
      if (results.length > 0) {
        if ('%' == elementsType) {
          for (int i = 0; i < results[0].length; i++) {
            for (var temp in results) {
              if (i < temp.length) {
                result.add('${temp[i]}');
              }
            }
          }
        } else {
          for (var temp in results) {
            result.addAll(temp);
          }
        }
      }
      return result;
    }
  }

  Object getObject(String rule) {
    try {
      return JPath.compile(rule).search(_ctx);
    } catch (e) {
      print(e);
      return '';
    }
  }

  List<Object> getList(String rule) {
    final result = <Object>[];
    if (null == rule || rule.isEmpty) return result;
    String elementsType;
    List<String> rules;
    if (rule.contains('&&')) {
      rules = rule.split('&&');
      elementsType = '&';
    } else if (rule.contains('%%')) {
      rules = rule.split('%%');
      elementsType = '%';
    } else {
      rules = rule.split('||');
      elementsType = '|';
    }
    if (rules.length == 1) {
      try {
        var res = JPath.compile(rules[0]).search(_ctx);
        if (null == res) return result;
//        print(res.runtimeType);
        if (res[0] is List) {
          res.forEach((r) => result.addAll(r));
        } else {
          result.addAll(res);
        }
      } catch (e) {
        print(e);
      }
      return result;
    } else {
      final results = <List<Object>>[];
      for (var rl in rules) {
        var temp = getList(rl);
        if (null != temp && temp.isNotEmpty) {
          results.add(temp);
          if (temp.length > 0 && '|' == elementsType) {
            break;
          }
        }
      }
      if (results.length > 0) {
        if ('%' == elementsType) {
          for (int i = 0; i < results[0].length; i++) {
            for (var temp in results) {
              if (i < temp.length) {
                result.add(temp[i]);
              }
            }
          }
        } else {
          for (var temp in results) {
            result.addAll(temp);
          }
        }
      }
    }
    return result;
  }
}
