
@HtmlImport('wasanbon_toolbar.html')
library wasanbon_toolbar;

import 'dart:html' as html;
import 'dart:async' as async;
import 'package:web_components/web_components.dart' show HtmlImport;
import 'package:polymer/polymer.dart';

@PolymerRegister('wasanbon-toolbar')
class WasanbonToolbar extends PolymerElement {

  WasanbonToolbar.created() : super.created();

  async.StreamController<html.MouseEvent> _onBack = new async.StreamController<html.MouseEvent>();
  async.Stream get onBack => _onBack.stream;

  void attached() {
  }

  @reflectable
  void onTapBack(var e, var d) {
    print('WasanbonToolbar.onTapBack button clicekd');
    _onBack.add(e);
  }
}
