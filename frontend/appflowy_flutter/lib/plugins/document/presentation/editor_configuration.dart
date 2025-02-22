import 'package:appflowy/generated/locale_keys.g.dart';
import 'package:appflowy/plugins/document/presentation/editor_plugins/actions/mobile_block_action_buttons.dart';
import 'package:appflowy/plugins/document/presentation/editor_plugins/image/custom_image_block_component.dart';
import 'package:appflowy/plugins/document/presentation/editor_plugins/plugins.dart';
import 'package:appflowy/plugins/document/presentation/editor_style.dart';
import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flowy_infra/theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Map<String, BlockComponentBuilder> getEditorBuilderMap({
  required BuildContext context,
  required EditorState editorState,
  required EditorStyleCustomizer styleCustomizer,
  List<SelectionMenuItem>? slashMenuItems,
  bool editable = true,
  ShowPlaceholder? showParagraphPlaceholder,
  String Function(Node)? placeholderText,
}) {
  final standardActions = [
    OptionAction.delete,
    OptionAction.duplicate,
    // OptionAction.divider,
    // OptionAction.moveUp,
    // OptionAction.moveDown,
  ];

  final calloutBGColor = AFThemeExtension.of(context).calloutBGColor;

  final configuration = BlockComponentConfiguration(
    padding: (_) => const EdgeInsets.symmetric(vertical: 5.0),
    indentPadding: (node, textDirection) => textDirection == TextDirection.ltr
        ? const EdgeInsets.only(left: 26.0)
        : const EdgeInsets.only(right: 26.0),
  );

  final customBlockComponentBuilderMap = {
    PageBlockKeys.type: PageBlockComponentBuilder(),
    ParagraphBlockKeys.type: ParagraphBlockComponentBuilder(
      configuration: configuration.copyWith(placeholderText: placeholderText),
      showPlaceholder: showParagraphPlaceholder,
    ),
    TodoListBlockKeys.type: TodoListBlockComponentBuilder(
      configuration: configuration.copyWith(
        placeholderText: (_) => LocaleKeys.blockPlaceholders_todoList.tr(),
      ),
      toggleChildrenTriggers: [
        LogicalKeyboardKey.shift,
        LogicalKeyboardKey.shiftLeft,
        LogicalKeyboardKey.shiftRight,
      ],
    ),
    BulletedListBlockKeys.type: BulletedListBlockComponentBuilder(
      configuration: configuration.copyWith(
        placeholderText: (_) => LocaleKeys.blockPlaceholders_bulletList.tr(),
      ),
    ),
    NumberedListBlockKeys.type: NumberedListBlockComponentBuilder(
      configuration: configuration.copyWith(
        placeholderText: (_) => LocaleKeys.blockPlaceholders_numberList.tr(),
      ),
    ),
    QuoteBlockKeys.type: QuoteBlockComponentBuilder(
      configuration: configuration.copyWith(
        placeholderText: (_) => LocaleKeys.blockPlaceholders_quote.tr(),
      ),
    ),
    HeadingBlockKeys.type: HeadingBlockComponentBuilder(
      configuration: configuration.copyWith(
        padding: (_) => const EdgeInsets.only(top: 12.0, bottom: 4.0),
        placeholderText: (node) => LocaleKeys.blockPlaceholders_heading.tr(
          args: [node.attributes[HeadingBlockKeys.level].toString()],
        ),
      ),
      textStyleBuilder: (level) => styleCustomizer.headingStyleBuilder(level),
    ),
    ImageBlockKeys.type: CustomImageBlockComponentBuilder(
      configuration: configuration,
      showMenu: true,
      menuBuilder: (Node node, CustomImageBlockComponentState state) =>
          Positioned(
        top: 0,
        right: 10,
        child: ImageMenu(
          node: node,
          state: state,
        ),
      ),
    ),
    TableBlockKeys.type: TableBlockComponentBuilder(
      menuBuilder: (node, editorState, position, dir, onBuild, onClose) =>
          TableMenu(
        node: node,
        editorState: editorState,
        position: position,
        dir: dir,
        onBuild: onBuild,
        onClose: onClose,
      ),
    ),
    TableCellBlockKeys.type: TableCellBlockComponentBuilder(
      menuBuilder: (node, editorState, position, dir, onBuild, onClose) =>
          TableMenu(
        node: node,
        editorState: editorState,
        position: position,
        dir: dir,
        onBuild: onBuild,
        onClose: onClose,
      ),
    ),
    DatabaseBlockKeys.gridType: DatabaseViewBlockComponentBuilder(
      configuration: configuration.copyWith(
        padding: (_) => const EdgeInsets.symmetric(vertical: 10),
      ),
    ),
    DatabaseBlockKeys.boardType: DatabaseViewBlockComponentBuilder(
      configuration: configuration.copyWith(
        padding: (_) => const EdgeInsets.symmetric(vertical: 10),
      ),
    ),
    DatabaseBlockKeys.calendarType: DatabaseViewBlockComponentBuilder(
      configuration: configuration.copyWith(
        padding: (_) => const EdgeInsets.symmetric(vertical: 10),
      ),
    ),
    CalloutBlockKeys.type: CalloutBlockComponentBuilder(
      configuration: configuration,
      defaultColor: calloutBGColor,
    ),
    DividerBlockKeys.type: DividerBlockComponentBuilder(
      configuration: configuration,
      height: 28.0,
      wrapper: (context, node, child) {
        return MobileBlockActionButtons(
          showThreeDots: false,
          node: node,
          editorState: editorState,
          child: child,
        );
      },
    ),
    MathEquationBlockKeys.type: MathEquationBlockComponentBuilder(
      configuration: configuration,
    ),
    CodeBlockKeys.type: CodeBlockComponentBuilder(
      configuration: configuration.copyWith(
        textStyle: (_) => styleCustomizer.codeBlockStyleBuilder(),
        placeholderTextStyle: (_) => styleCustomizer.codeBlockStyleBuilder(),
      ),
      padding: const EdgeInsets.only(
        left: 30,
        right: 30,
        bottom: 36,
      ),
    ),
    AutoCompletionBlockKeys.type: AutoCompletionBlockComponentBuilder(),
    SmartEditBlockKeys.type: SmartEditBlockComponentBuilder(),
    ToggleListBlockKeys.type: ToggleListBlockComponentBuilder(
      configuration: configuration,
    ),
    OutlineBlockKeys.type: OutlineBlockComponentBuilder(
      configuration: configuration.copyWith(
        placeholderTextStyle: (_) =>
            styleCustomizer.outlineBlockPlaceholderStyleBuilder(),
        padding: (_) => const EdgeInsets.only(
          top: 12.0,
          bottom: 4.0,
        ),
      ),
    ),
    errorBlockComponentBuilderKey: ErrorBlockComponentBuilder(
      configuration: configuration,
    ),
  };

  final builders = {
    ...standardBlockComponentBuilderMap,
    ...customBlockComponentBuilderMap,
  };

  if (editable) {
    // customize the action builder. actually, we can customize them in their own builder. Put them here just for convenience.
    for (final entry in builders.entries) {
      if (entry.key == PageBlockKeys.type) {
        continue;
      }
      final builder = entry.value;

      // customize the action builder.
      final supportColorBuilderTypes = [
        ParagraphBlockKeys.type,
        HeadingBlockKeys.type,
        BulletedListBlockKeys.type,
        NumberedListBlockKeys.type,
        QuoteBlockKeys.type,
        TodoListBlockKeys.type,
        CalloutBlockKeys.type,
        OutlineBlockKeys.type,
        ToggleListBlockKeys.type,
      ];

      final supportAlignBuilderType = [
        ImageBlockKeys.type,
      ];

      final colorAction = [
        OptionAction.divider,
        OptionAction.color,
      ];

      final alignAction = [
        OptionAction.divider,
        OptionAction.align,
      ];

      final List<OptionAction> actions = [
        ...standardActions,
        if (supportColorBuilderTypes.contains(entry.key)) ...colorAction,
        if (supportAlignBuilderType.contains(entry.key)) ...alignAction,
      ];

      if (PlatformExtension.isDesktop) {
        builder.showActions =
            (node) => node.parent?.type != TableCellBlockKeys.type;

        builder.actionBuilder = (context, state) {
          final top = builder.configuration.padding(context.node).top;
          final padding = context.node.type == HeadingBlockKeys.type
              ? EdgeInsets.only(top: top + 8.0)
              : EdgeInsets.only(top: top + 2.0);
          return Padding(
            padding: padding,
            child: BlockActionList(
              blockComponentContext: context,
              blockComponentState: state,
              editorState: editorState,
              actions: actions,
              showSlashMenu: slashMenuItems != null
                  ? () => customSlashCommand(
                        slashMenuItems,
                        shouldInsertSlash: false,
                        style: styleCustomizer.selectionMenuStyleBuilder(),
                      ).handler.call(editorState)
                  : () {},
            ),
          );
        };
      }
    }
  }

  return builders;
}
