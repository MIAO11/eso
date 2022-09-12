import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../hive/theme_mode_box.dart';

class DarkModpage extends StatelessWidget {
  const DarkModpage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('夜间模式')),
      body: ValueListenableBuilder<Box<int>>(
        valueListenable: themeModeBox.listenable(),
        builder: (BuildContext context, Box<int> box, Widget child) {
          return ListView.builder(
            itemCount: ThemeMode.values.length,
            itemBuilder: (BuildContext context, int index) {
              final name = {
                ThemeMode.system.index: "系统",
                ThemeMode.light.index: "白天",
                ThemeMode.dark.index: "黑夜",
              };
              final title = Text(name[index] ?? ThemeMode.values[index].name);
              return index == themeMode
                  ? ListTile(title: title, trailing: Icon(Icons.done, size: 32))
                  : ListTile(
                      title: title,
                      onTap: () => themeMode = index,
                    );
            },
          );
        },
      ),
    );
  }
}
