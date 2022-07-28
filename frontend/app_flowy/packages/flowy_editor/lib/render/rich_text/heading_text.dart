import 'package:flowy_editor/document/node.dart';
import 'package:flowy_editor/editor_state.dart';
import 'package:flowy_editor/infra/flowy_svg.dart';
import 'package:flowy_editor/render/node_widget_builder.dart';
import 'package:flowy_editor/render/render_plugins.dart';
import 'package:flowy_editor/render/rich_text/default_selectable.dart';
import 'package:flowy_editor/render/rich_text/flowy_rich_text.dart';
import 'package:flowy_editor/render/rich_text/rich_text_style.dart';
import 'package:flowy_editor/render/selection/selectable.dart';
import 'package:flowy_editor/extensions/object_extensions.dart';
import 'package:flutter/material.dart';

class HeadingTextNodeWidgetBuilder extends NodeWidgetBuilder {
  HeadingTextNodeWidgetBuilder.create({
    required super.editorState,
    required super.node,
    required super.key,
  }) : super.create();

  @override
  Widget build(BuildContext context) {
    return HeadingTextNodeWidget(
      key: key,
      textNode: node as TextNode,
      editorState: editorState,
    );
  }
}

class HeadingTextNodeWidget extends StatefulWidget {
  const HeadingTextNodeWidget({
    Key? key,
    required this.textNode,
    required this.editorState,
  }) : super(key: key);

  final TextNode textNode;
  final EditorState editorState;

  @override
  State<HeadingTextNodeWidget> createState() => _HeadingTextNodeWidgetState();
}

// customize

class _HeadingTextNodeWidgetState extends State<HeadingTextNodeWidget>
    with Selectable, DefaultSelectable {
  final _richTextKey = GlobalKey(debugLabel: 'heading_text');
  final topPadding = 5.0;
  final bottomPadding = 2.0;

  @override
  Selectable<StatefulWidget> get forward =>
      _richTextKey.currentState as Selectable;

  @override
  Offset get baseOffset {
    return Offset(0, topPadding);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: topPadding,
        ),
        FlowyRichText(
          key: _richTextKey,
          textSpanDecorator: _textSpanDecorator,
          textNode: widget.textNode,
          editorState: widget.editorState,
        ),
        SizedBox(
          height: bottomPadding,
        ),
      ],
    );
  }

  TextSpan _textSpanDecorator(TextSpan textSpan) {
    return TextSpan(
      children: textSpan.children
          ?.whereType<TextSpan>()
          .map(
            (span) => TextSpan(
              text: span.text,
              style: span.style?.copyWith(
                fontSize: widget.textNode.attributes.fontSize,
              ),
              recognizer: span.recognizer,
            ),
          )
          .toList(),
    );
  }
}
