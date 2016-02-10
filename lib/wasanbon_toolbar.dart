
@HtmlImport('wasanbon_toolbar.html')
library wasanbon_toolbar;

import 'dart:html' as html;
import 'package:web_components/web_components.dart' show HtmlImport;
import 'package:polymer/polymer.dart';

@PolymerRegister('wasanbon-toolbar')
class WasanbonToolbar extends PolymerElement {

  WasanbonToolbar.created() : super.created();

  @reflectable
  void onTap(var e, var d) {
    html.window.location.assign('http://${Uri.base.host}:${Uri.base.port}');
  }
}
