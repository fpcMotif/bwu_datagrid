library bwu_datagrid.plugins.cell_copymanager;

import 'dart:html' as dom;
import 'dart:async' as async;

import 'package:bwu_datagrid/plugins/plugin.dart';
import 'package:bwu_datagrid/bwu_datagrid.dart';
import 'package:bwu_datagrid/core/core.dart' as core;
import 'package:bwu_datagrid/datagrid/helpers.dart';

class CellCopyManager extends Plugin {
  List<core.Range> _copiedRanges;

  core.EventBus<core.EventData> get eventBus => _eventBus;
  core.EventBus<core.EventData> _eventBus = new core.EventBus<core.EventData>();

  CellCopyManager();

  async.StreamSubscription<core.KeyDown> keyDownSubscription;

  @override
  void init(BwuDatagrid grid) {
    super.init(grid);
    keyDownSubscription = grid.onBwuKeyDown.listen(_handleKeyDown);
  }

  void destroy() {
    if (keyDownSubscription != null) {
      keyDownSubscription.cancel();
    }
  }

  void _handleKeyDown(core.KeyDown e) {
    List<core.Range> ranges;
    if (!grid.getEditorLock.isActive) {
      if (e.causedBy.which == dom.KeyCode.ESC) {
        if (_copiedRanges != null) {
          e.preventDefault();
          clearCopySelection();
          eventBus.fire(core.Events.copyCancelled,
              new core.CopyCancelled(this, _copiedRanges));
          _copiedRanges = null;
        }
      }

      if (e.causedBy.which == 67 &&
          (e.causedBy.ctrlKey || e.causedBy.metaKey)) {
        ranges = grid.getSelectionModel.getSelectedRanges();
        if (ranges.length != 0) {
          e.preventDefault();
          _copiedRanges = ranges;
          _markCopySelection(ranges);
          eventBus.fire(
              core.Events.copyCells, new core.CopyCells(this, ranges));
        }
      }

      if (e.causedBy.which == 86 &&
          (e.causedBy.ctrlKey || e.causedBy.metaKey)) {
        if (_copiedRanges != null) {
          e.preventDefault();
          clearCopySelection();
          ranges = grid.getSelectionModel.getSelectedRanges();
          eventBus.fire(core.Events.pasteCells,
              new core.PasteCells(this, _copiedRanges, ranges));
          _copiedRanges = null;
        }
      }
    }
  }

  void _markCopySelection(List<core.Range> ranges) {
    final List<Column> columns = grid.getColumns;
    final Map<int, Map<String, String>> hash = <int, Map<String, String>>{};
    for (int i = 0; i < ranges.length; i++) {
      for (int j = ranges[i].fromRow; j <= ranges[i].toRow; j++) {
        hash[j] = {};
        for (int k = ranges[i].fromCell; k <= ranges[i].toCell; k++) {
          hash[j][columns[k].id] = "copied";
        }
      }
    }
    grid.setCellCssStyles("copy-manager", hash);
  }

  void clearCopySelection() {
    grid.removeCellCssStyles("copy-manager");
  }

  async.Stream<core.CopyCells> get onBwuCopyCells =>
      _eventBus.onEvent(core.Events.copyCells) as async.Stream<core.CopyCells>;

  async.Stream<core.CopyCancelled> get onBwuCopyCancelled =>
      _eventBus.onEvent(core.Events.copyCancelled)
      as async.Stream<core.CopyCancelled>;

  async.Stream<core.PasteCells> get onBwuPasteCells =>
      _eventBus.onEvent(core.Events.pasteCells)
      as async.Stream<core.PasteCells>;
}
