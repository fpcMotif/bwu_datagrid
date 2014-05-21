library app_element;

import 'package:polymer/polymer.dart';

import 'package:bwu_datagrid/datagrid/helpers.dart';
import 'package:bwu_datagrid/bwu_datagrid.dart';
import 'package:bwu_datagrid/editors/editors.dart';

import 'context_menu.dart';

@CustomTag('app-element')
class AppElement extends PolymerElement {
  AppElement.created() : super.created();

  BwuDatagrid grid;
  List<Column> columns = [
    new Column(id: "title", name: "Title", field: "title", width: 200, cssClass: "cell-title", editor: new TextEditor()),
    new Column(id: "priority", name: "Priority", field: "priority", width: 80, selectable: false, resizable: false)
  ];

  var gridOptions = new GridOptions(
      editable: true,
      enableAddRow: false,
      enableCellNavigation: true,
      asyncEditorLoading: false,
      rowHeight: 30
  );

  @override
  void attached() {
    super.attached();

    try {
      grid = $['myGrid'];
      var data = new List<Map>(500);
      for (var i = 0; i < 500; i++) {
        data[i] = {
          'title': 'Task ${i}',
          'priority': 'Medium'
        };
      }

      grid.setup(dataMap: data, columns: columns, gridOptions: gridOptions);

      // setup context menu handler
      grid.onBwuContextMenu.listen((e) {
        e.stopImmediatePropagation();
        e.preventDefault();
        ($['contextMenu'] as ContextMenu)
            ..cell = e.cell
            ..setPosition(e.causedBy.page.x, e.causedBy.page.y)
            ..show();
      });

      // setup context menu select handler
      ($['contextMenu'] as ContextMenu).onContextMenuSelect.listen((e) {
        if (!grid.getEditorLock.commitCurrentEdit()) {
          return;
        }
        var cell = ($['contextMenu'] as ContextMenu).cell;
        data[cell.row]['priority'] = e.detail;
        grid.updateRow(cell.row);
        ($['contextMenu'] as ContextMenu).hide();
      });

      // setup next value on cell click
      grid.onBwuClick.listen((e) {
        if (grid.getColumns[e.cell.cell].id == 'priority') {
          if (!grid.getEditorLock.commitCurrentEdit()) {
            return;
          }

          var states = { 'Low': 'Medium', 'Medium': 'High', 'High': 'Low' };
          data[e.cell.row]['priority'] = states[data[e.cell.row]['priority']];
          grid.updateRow(e.cell.row);
          e.stopPropagation();
        }
      });

    } on NoSuchMethodError catch (e) {
      print('$e\n\n${e.stackTrace}');
    }  on RangeError catch (e) {
      print('$e\n\n${e.stackTrace}');
    } on TypeError catch(e) {
      print('$e\n\n${e.stackTrace}');
    } catch(e) {
      print('$e');
    }
  }
}