import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:html/dom.dart' as Dom;
import 'package:html/parser.dart';

class HtmlFunctions extends InheritedWidget {
  const HtmlFunctions({
    super.key,
    required super.child,
    this.onLinkTap,
    this.onLinkLongPress,
    this.onImgTap,
    this.onImgLongPress,
  });
  final Function(String)? onLinkTap;
  final Function(String)? onLinkLongPress;
  final Function(String)? onImgTap;
  final Function(String)? onImgLongPress;

  static HtmlFunctions of(BuildContext context) {
    final HtmlFunctions? result =
        context.dependOnInheritedWidgetOfExactType<HtmlFunctions>();
    assert(result != null, 'Unable to find an instance of HtmlFunctions...');
    return result!;
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return oldWidget.child != oldWidget.child;
  }
}

class HtmlView extends StatefulWidget {
  const HtmlView({
    super.key,
    required this.html,
    this.onLinkTap,
    this.onLinkLongPress,
    this.onImgTap,
    this.onImgLongPress,
  });
  final String html;
  final Function(String)? onLinkTap;
  final Function(String)? onLinkLongPress;
  final Function(String)? onImgTap;
  final Function(String)? onImgLongPress;

  @override
  State<HtmlView> createState() => _HtmlViewState();
}

class _HtmlViewState extends State<HtmlView> {
  @override
  Widget build(BuildContext context) {
    // print(widget.html);
    return HtmlFunctions(
      onImgLongPress: widget.onImgLongPress,
      onImgTap: widget.onImgTap,
      onLinkLongPress: widget.onLinkLongPress,
      onLinkTap: widget.onLinkTap,
      child: Builder(
        builder: (context) {
          return SelectableText.rich(
            TextSpan(
              children: [
                getSpans(
                    context,
                    parse(
                      widget.html
                          .replaceAll("<br>", "\n")
                          .replaceAll("<br />", "\n"),
                    )),
              ],
            ),
          );
        },
      ),
    );
  }
}

InlineSpan getSpans(BuildContext context, Dom.Node node) {
  List<InlineSpan> spans = [];
  if (node.children.isEmpty) {
    // print("${node.nodeType}: ${node.text}");
    spans.add(generateSpan(context, node));
  } else {
    for (Dom.Node child in node.nodes) {
      // print("${child.nodeType}: ${child.text}");
      if (child.nodes.isNotEmpty) {
        spans.add(getSpans(context, child));
      } else if ((child.nodeType == Dom.Node.TEXT_NODE &&
              child.parent?.localName != "a" &&
              child.parent?.localName != "p") ||
          child.attributes.containsKey("src") ||
          child.attributes.containsKey("href")) {
        spans.add(generateSpan(context, child));
      }
    }
  }

  return TextSpan(children: spans);
}

InlineSpan generateSpan(BuildContext context, Dom.Node element) {
  if (element.attributes.containsKey("href")) {
    return WidgetSpan(
        child: GestureDetector(
      onTap: () {
        if (HtmlFunctions.of(context).onLinkTap != null &&
            element.attributes.containsKey("href")) {
          HtmlFunctions.of(context).onLinkTap!(element.attributes["href"]!);
        }
      },
      onLongPress: () {
        if (HtmlFunctions.of(context).onLinkLongPress != null &&
            element.attributes.containsKey("href")) {
          HtmlFunctions.of(context)
              .onLinkLongPress!(element.attributes["href"]!);
        }
      },
      child: Text(
        element.text ?? "",
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          decoration: TextDecoration.underline,
        ),
      ),
    ));
  } else if (element.attributes.containsKey("src")) {
    return WidgetSpan(
        child: Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: GestureDetector(
        onTap: () {
          if (HtmlFunctions.of(context).onImgTap != null &&
              element.attributes.containsKey("src")) {
            HtmlFunctions.of(context).onImgTap!(element.attributes["src"]!);
          }
        },
        onLongPress: () {
          if (HtmlFunctions.of(context).onImgLongPress != null &&
              element.attributes.containsKey("src")) {
            HtmlFunctions.of(context)
                .onImgLongPress!(element.attributes["src"]!);
          }
        },
        child: CachedNetworkImage(
          fit: BoxFit.fitWidth,
          width: double.infinity,
          imageUrl: element.attributes["src"]!,
          progressIndicatorBuilder: (context, url, progress) {
            return SizedBox(
              height: 48,
                  width: 48,
              child: FittedBox(
                child: CircularProgressIndicator.adaptive(
                  value: progress.progress,
                ),
              ),
            );
          },
          errorWidget: (context, url, error) {
            debugPrint("$url: $error");
            return Placeholder(child: Text(error.toString()));
          },
        ),
      ),
    ));
  } else if (element.nodeType == 1) {
    return TextSpan(text: "\n${element.text}\n");
  } else {
    return TextSpan(text: element.text);
  }
}
