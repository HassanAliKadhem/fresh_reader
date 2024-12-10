import 'package:flutter/material.dart';

import '../util/formatting_setting.dart';

class FormattingSheet extends StatelessWidget {
  const FormattingSheet({
    super.key,
    required this.formattingSetting,
  });

  final FormattingSetting formattingSetting;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: formattingSetting,
        builder: (context, child) {
          return DraggableScrollableSheet(
            expand: false,
            builder: (context, scrollController) => ListView(
              controller: scrollController,
              children: [
                const ListTile(
                  title: Text(
                    "Text Formatting",
                    textScaler: TextScaler.linear(1.25),
                  ),
                ),
                ListTile(
                  title: const Text("Font Size"),
                  subtitle: Slider.adaptive(
                    value: formattingSetting.fontSize,
                    min: 10,
                    max: 30,
                    divisions: 20,
                    label: formattingSetting.fontSize.toString(),
                    onChanged: (value) {
                      formattingSetting.setSize(value);
                    },
                  ),
                ),
                ListTile(
                  title: const Text("Line Height"),
                  subtitle: Slider.adaptive(
                    value: formattingSetting.lineHeight,
                    min: 1.0,
                    max: 2.0,
                    divisions: 10,
                    label: formattingSetting.lineHeight.toString(),
                    onChanged: (value) {
                      formattingSetting.setLineHeight(value);
                    },
                  ),
                ),
                ListTile(
                  title: const Text("Word Spacing"),
                  subtitle: Slider.adaptive(
                    value: formattingSetting.wordSpacing,
                    min: 0,
                    max: 10,
                    divisions: 10,
                    label: formattingSetting.wordSpacing.toString(),
                    onChanged: (value) {
                      formattingSetting.setSpacing(value);
                    },
                  ),
                ),
                const ListTile(
                  title: Text("Font"),
                ),
                ...formattingSetting.fonts.map((font) => RadioListTile.adaptive(
                      groupValue: formattingSetting.font,
                      value: font,
                      dense: true,
                      title: Text(font),
                      onChanged: (value) {
                        formattingSetting.setFontFamily(font);
                      },
                    ))
              ],
            ),
          );
        });
  }
}
