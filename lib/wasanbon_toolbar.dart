
@HtmlImport('wasanbon_toolbar.html')
library wasanbon_toolbar;

import 'dart:html' as html;
import 'dart:async' as async;
import 'package:web_components/web_components.dart' show HtmlImport;
import 'package:polymer/polymer.dart';


@PolymerRegister('wasanbon-toolbar')
class WasanbonToolbar extends PolymerElement {

  @property
  var onBack;

  WasanbonToolbar.created() : super.created();

//  async.StreamController<dynamic> onback;

  void attached() {
//    onback = new async.Stream.empty();
    onBack = (var e, var d) {};
  }

  void goBack() {
    html.window.location.assign('http://${Uri.base.host}:${Uri.base.port}');
  }

  @reflectable
  void onTap(var e, var d) {
    onBack(e, d);
  }
}
