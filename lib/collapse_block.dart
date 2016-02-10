@HtmlImport('collapse_block.html')
library collapse_block;

import 'dart:html' as html;
import 'package:web_components/web_components.dart' show HtmlImport;
import 'package:polymer/polymer.dart';

import 'package:polymer_elements/iron_collapse.dart';

@PolymerRegister('collapse-block')
class CollapseBlock extends PolymerElement {

  static CollapseBlock build() {
    return new html.Element.tag('collapse-block');
  }
  @property var toolbarTitle = 'hoge';
  @property var state = 'closed';
  @property var group = 'defaultGroup';

  IronCollapse collapse;
  CollapseBlock.created() : super.created();

  static Map _groupDictionary = {};

  @override
  void attached() {
    collapse = $$('#i-collapse');


    if (!_groupDictionary.containsKey(group)) {
      _groupDictionary[group] = [];
    }

    _groupDictionary[group].add(this);


    if (state == 'closed') {
      closeCollapse();
    } else {
      openCollapse();
    }
  }

  @reflectable
  void toggle(var e, var v) {
    if (collapse.opened) {
      closeCollapse();
    } else {
      openCollapse();
    }
  }

  void closeCollapse() {
    if(collapse.opened) {
      collapse.toggle();
    }
  }

  void openCollapse() {
    if(!collapse.opened) {
      collapse.toggle();
    }

    _groupDictionary[group].forEach(
        (var e) {
          if (e != this) {
            e.closeCollapse();
          }
        }
    );
  }
}
