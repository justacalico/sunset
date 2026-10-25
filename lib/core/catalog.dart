enum PropKind { string, l10nKey, int, double, bool, color, enumProp, icon, align }

class PropDef {
  final String name;
  final PropKind kind;
  final Object? value;
  final List<String> options;

  const PropDef(this.name, this.kind, this.value, [this.options = const []]);
}

class WidgetDef {
  final String type;
  final List<PropDef> props;
  final int maxChildren;
  final String group;

  const WidgetDef(
    this.type, {
    this.props = const [],
    this.maxChildren = 0,
    this.group = 'content',
  });
}

const axisOptions = ['start', 'center', 'end', 'spaceBetween', 'spaceAround', 'spaceEvenly'];
const crossAxisOptions = ['start', 'center', 'end', 'stretch'];
const alignOptions = [
  'topLeft', 'topCenter', 'topRight',
  'centerLeft', 'center', 'centerRight',
  'bottomLeft', 'bottomCenter', 'bottomRight',
];
const textAlignOptions = ['left', 'center', 'right', 'justify'];
const fitOptions = ['contain', 'cover', 'fill', 'fitHeight', 'fitWidth', 'none'];
const buttonStyleOptions = ['filled', 'tonal', 'outlined', 'text'];

const iconNames = [
  'add', 'arrow_back', 'arrow_forward', 'calendar_today', 'camera', 'chat',
  'check', 'cloud', 'delete', 'download', 'edit', 'email', 'favorite',
  'folder', 'home', 'lock', 'map', 'menu', 'mic', 'music_note',
  'notifications', 'pause', 'person', 'phone', 'photo', 'play_arrow',
  'search', 'settings', 'share', 'shopping_cart', 'star', 'upload',
  'videocam', 'visibility', 'wb_sunny', 'dark_mode',
];

const catalog = <WidgetDef>[
  WidgetDef('scaffold', group: 'layout', maxChildren: 1, props: [
    PropDef('title', PropKind.string, 'Sunset'),
    PropDef('titleKey', PropKind.l10nKey, ''),
    PropDef('showAppBar', PropKind.bool, true),
    PropDef('centerTitle', PropKind.bool, true),
  ]),
  WidgetDef('column', group: 'layout', maxChildren: -1, props: [
    PropDef('mainAxis', PropKind.enumProp, 'start', axisOptions),
    PropDef('crossAxis', PropKind.enumProp, 'center', crossAxisOptions),
    PropDef('spacing', PropKind.double, 0.0),
  ]),
  WidgetDef('row', group: 'layout', maxChildren: -1, props: [
    PropDef('mainAxis', PropKind.enumProp, 'start', axisOptions),
    PropDef('crossAxis', PropKind.enumProp, 'center', crossAxisOptions),
    PropDef('spacing', PropKind.double, 0.0),
  ]),
  WidgetDef('stack', group: 'layout', maxChildren: -1, props: [
    PropDef('alignment', PropKind.align, 'topLeft', alignOptions),
  ]),
  WidgetDef('center', group: 'layout', maxChildren: 1),
  WidgetDef('padding', group: 'layout', maxChildren: 1, props: [
    PropDef('padding', PropKind.double, 16.0),
  ]),
  WidgetDef('expanded', group: 'layout', maxChildren: 1, props: [
    PropDef('flex', PropKind.int, 1),
  ]),
  WidgetDef('sizedBox', group: 'layout', maxChildren: 1, props: [
    PropDef('width', PropKind.double, 0.0),
    PropDef('height', PropKind.double, 0.0),
  ]),
  WidgetDef('container', group: 'layout', maxChildren: 1, props: [
    PropDef('width', PropKind.double, 0.0),
    PropDef('height', PropKind.double, 0.0),
    PropDef('color', PropKind.color, 0),
    PropDef('padding', PropKind.double, 0.0),
    PropDef('radius', PropKind.double, 0.0),
    PropDef('align', PropKind.align, 'topLeft', alignOptions),
  ]),
  WidgetDef('card', group: 'layout', maxChildren: 1, props: [
    PropDef('elevation', PropKind.double, 1.0),
    PropDef('radius', PropKind.double, 12.0),
    PropDef('padding', PropKind.double, 16.0),
  ]),
  WidgetDef('listView', group: 'layout', maxChildren: -1, props: [
    PropDef('spacing', PropKind.double, 0.0),
    PropDef('padding', PropKind.double, 0.0),
    PropDef('height', PropKind.double, 0.0),
  ]),
  WidgetDef('gridView', group: 'layout', maxChildren: -1, props: [
    PropDef('columns', PropKind.int, 2),
    PropDef('spacing', PropKind.double, 8.0),
    PropDef('height', PropKind.double, 0.0),
  ]),
  WidgetDef('divider', group: 'layout', props: [
    PropDef('thickness', PropKind.double, 1.0),
  ]),
  WidgetDef('spacer', group: 'layout', props: [
    PropDef('flex', PropKind.int, 1),
  ]),
  WidgetDef('text', props: [
    PropDef('text', PropKind.string, 'Text'),
    PropDef('textKey', PropKind.l10nKey, ''),
    PropDef('size', PropKind.double, 14.0),
    PropDef('bold', PropKind.bool, false),
    PropDef('color', PropKind.color, 0),
    PropDef('align', PropKind.enumProp, 'left', textAlignOptions),
  ]),
  WidgetDef('icon', props: [
    PropDef('icon', PropKind.icon, 'star', iconNames),
    PropDef('size', PropKind.double, 24.0),
    PropDef('color', PropKind.color, 0),
  ]),
  WidgetDef('image', props: [
    PropDef('url', PropKind.string, ''),
    PropDef('height', PropKind.double, 160.0),
    PropDef('fit', PropKind.enumProp, 'cover', fitOptions),
  ]),
  WidgetDef('circleAvatar', props: [
    PropDef('icon', PropKind.icon, 'person', iconNames),
    PropDef('radius', PropKind.double, 24.0),
    PropDef('color', PropKind.color, 0),
  ]),
  WidgetDef('button', props: [
    PropDef('label', PropKind.string, 'Button'),
    PropDef('labelKey', PropKind.l10nKey, ''),
    PropDef('style', PropKind.enumProp, 'filled', buttonStyleOptions),
    PropDef('icon', PropKind.icon, '', ['', ...iconNames]),
  ]),
  WidgetDef('textField', props: [
    PropDef('hint', PropKind.string, 'Enter text'),
    PropDef('hintKey', PropKind.l10nKey, ''),
    PropDef('label', PropKind.string, ''),
    PropDef('labelKey', PropKind.l10nKey, ''),
    PropDef('dense', PropKind.bool, true),
  ]),
  WidgetDef('switcher', props: [
    PropDef('label', PropKind.string, 'Switch'),
    PropDef('labelKey', PropKind.l10nKey, ''),
    PropDef('value', PropKind.bool, true),
  ]),
  WidgetDef('checkbox', props: [
    PropDef('label', PropKind.string, 'Checkbox'),
    PropDef('labelKey', PropKind.l10nKey, ''),
    PropDef('value', PropKind.bool, false),
  ]),
  WidgetDef('slider', props: [
    PropDef('value', PropKind.double, 0.5),
  ]),
  WidgetDef('progress', props: [
    PropDef('value', PropKind.double, 0.5),
  ]),
];

WidgetDef? widgetDef(String type) {
  for (final def in catalog) {
    if (def.type == type) return def;
  }
  return null;
}

Object? propDefault(String type, String prop) {
  final def = widgetDef(type);
  if (def == null) return null;
  for (final p in def.props) {
    if (p.name == prop) return p.value;
  }
  return null;
}

Object? parsePropValue(PropDef def, String raw) {
  switch (def.kind) {
    case PropKind.int:
      return int.tryParse(raw);
    case PropKind.double:
      return double.tryParse(raw);
    case PropKind.bool:
      return switch (raw.toLowerCase()) {
        'true' || '1' || 'yes' || 'on' => true,
        'false' || '0' || 'no' || 'off' => false,
        _ => null,
      };
    case PropKind.color:
      final cleaned = raw.replaceAll('#', '').replaceAll('0x', '').replaceAll('0X', '');
      final value = int.tryParse(cleaned, radix: 16);
      if (value == null) return null;
      return cleaned.length <= 6 ? 0xFF000000 | value : value;
    case PropKind.enumProp || PropKind.icon || PropKind.align:
      return def.options.contains(raw) ? raw : null;
    case PropKind.string || PropKind.l10nKey:
      return raw;
  }
}
