
@HtmlImport('wasanbon_toolbar.html')
library wasanbon_toolbar;

import 'dart:html' as html;
import 'package:web_components/web_components.dart' show HtmlImport;
import 'package:polymer/polymer.dart';

import 'global_information_manager.dart';
import 'application_manager.dart';

import 'package:polymer_elements/paper_dialog.dart';

@PolymerRegister('wasanbon-toolbar')
class WasanbonToolbar extends PolymerElement {

  WasanbonToolbar.created() : super.created();

  @reflectable
  void onTap(var e, var d) {
    html.window.location.assign('../');
  }
}
