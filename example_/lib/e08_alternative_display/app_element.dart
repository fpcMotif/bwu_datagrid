@HtmlImport('app_element.html')
library app_element;

import 'dart:html' as dom;
import 'dart:math' as math;

import 'package:polymer/polymer.dart';
import 'package:web_components/web_components.dart' show HtmlImport;

import 'package:bwu_datagrid/core/core.dart' as core;
import 'package:bwu_datagrid/datagrid/helpers.dart';
import 'package:bwu_datagrid/bwu_datagrid.dart';
import 'package:bwu_datagrid/formatters/formatters.dart' as fm;

import 'package:bwu_datagrid_examples/asset/example_style.dart';
import 'package:bwu_datagrid_examples/shared/options_panel.dart';

import 'row_item.dart';
import 'custom_style.dart';

class CellFormatter extends fm.CellFormatter {
  @override
  void format(dom.Element target, int row, int cell, dynamic value,
      Column columnDef, core.ItemBase<dynamic, dynamic> dataContext) {
    target.children.clear();

    target.append(new RowItem()..data = dataContext);
  }
}

/// Silence analyzer [exampleStyleSilence], [customThemeSilence], [OptionsPanel]
@PolymerRegister('app-element')
class AppElement extends PolymerElement {
  AppElement.created() : super.created();

  final List<Column> columns = <Column>[
    new Column(
        id: "contact-card",
        name: "Contacts",
        formatter: new CellFormatter(),
        width: 500,
        cssClass: "contact-card-cell")
  ];

  final GridOptions gridOptions = new GridOptions(
      rowHeight: 140,
      editable: false,
      enableAddRow: false,
      enableCellNavigation: false,
      enableColumnReorder: false);

  math.Random rnd = new math.Random();

  BwuDatagrid grid;
  MapDataItemProvider<core.ItemBase<dynamic, dynamic>> data;

  @override
  void attached() {
    super.attached();

    try {
      grid = $['myGrid'];

      // prepare the data
      data = new MapDataItemProvider<core.ItemBase<dynamic, dynamic>>();
      for (int i = 0; i < 100; i++) {
        data.items.add(new MapDataItem<dynamic, dynamic>({
          'name': 'User ${i}',
          'email': 'test.user@nospam.org',
          'title': 'Regional sales manager',
          'phone': '206-000-0000'
        }));
      }

      grid.setup(
          dataProvider: data, columns: columns, gridOptions: gridOptions);
    } on NoSuchMethodError catch (e) {
      print('$e\n\n${e.stackTrace}');
    } on RangeError catch (e) {
      print('$e\n\n${e.stackTrace}');
    } on TypeError catch (e) {
      print('$e\n\n${e.stackTrace}');
    } catch (e) {
      print('$e');
    }
  }
}
