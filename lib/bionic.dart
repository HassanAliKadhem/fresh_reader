import 'package:html/dom.dart';
import 'package:html/dom_parsing.dart';
import 'package:html/parser.dart';

String getBionicContent(String oldContent) {
  Document document = parse(oldContent);
  // if (document.body != null) {
  //   for (var i = 0; i < document.body!.nodes.length; i++) {
  //     document.body!.nodes[i] = _traverseNode(document.body!.nodes[i]);
  //   }
  // }
  _BionicVisitor().visit(document);
  return document.outerHtml;
}

Node _traverseNode(Node node) {
  if (node.children.isNotEmpty) {
    for (var i = 0; i < node.children.length; i++) {
      node.children[i] = _traverseChildren(node.children[i]);
    }
  }
  // if (node.nodes.isNotEmpty) {
  //   for (var i = 0; i < node.nodes.length; i++) {
  //     node.nodes[i] = _traverseNode(node.nodes[i]);
  //   }
  // }
  return node;
}

Element _traverseChildren(Element element) {
  if (element.children.isNotEmpty) {
    for (var i = 0; i < element.children.length; i++) {
      element.children[i] = _traverseChildren(element.children[i]);
    }
  } else {
    String oldLine = element.innerHtml;
    if (oldLine.length > 1) {
      String newLine = "";
      int start = 0;
      for (var i = 0; i < oldLine.length; i++) {
        if ([" ", ",", "."].contains(oldLine[i]) || i == oldLine.length - 1) {
          newLine += _splitAndStrong(oldLine.substring(start, i + 1));
          start = i + 1;
        }
      }
      element.innerHtml = newLine;
    }
  }
  return element;
}

String _splitAndStrong(String oldWord) {
  String newWord = "";
  newWord += "<emp><strong>${oldWord.substring(0, oldWord.length ~/ 2)}</strong></emp>";
  newWord += oldWord.substring(oldWord.length ~/ 2);
  return newWord;
}

class _BionicVisitor extends TreeVisitor {
  @override
  void visitElement(Element node) {
    super.visitElement(node);
    String oldLine = node.innerHtml;
    if (oldLine.length > 1 && node.children.isEmpty) {
      String newLine = "";
      int start = 0;
      for (var i = 0; i < oldLine.length; i++) {
        if ([" ", ",", "."].contains(oldLine[i]) || i == oldLine.length - 1) {
          newLine += _splitAndStrong(oldLine.substring(start, i + 1));
          start = i + 1;
        }
      }
      node.innerHtml = newLine;
    }
  }
}
