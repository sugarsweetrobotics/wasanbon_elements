@HtmlImport('collapse_paper_item.html')
library collapse_paper_item;

import 'dart:html' as html;

import 'package:web_components/web_components.dart' show HtmlImport;
import 'package:polymer/polymer.dart';

import 'package:nameservicemanager/nameservicemanager.dart';
import 'package:nameservicemanager/message_dialog.dart';
import 'package:nameservicemanager/ns_inspector.dart';

import 'package:wasanbon_xmlrpc/wasanbon_xmlrpc.dart';
import 'package:polymer_elements/iron_icon.dart';
import 'package:polymer_elements/iron_collapse.dart';


import 'package:polymer_elements/paper_menu.dart';
import 'package:polymer_elements/paper_icon_button.dart';



@PolymerRegister('collapse-paper-item')
class CollapsePaperItem extends PolymerElement {
  @reflectable String title='default_title';

  static CollapsePaperItem build() {
    return new html.Element.tag('collapse-paper-item');
  }

  bool opened = false;
  CollapsePaperItem.created() : super.created();

  IronCollapse collapse;

  var on_attached_listener = null;

  var customIcon = null;
  var content;
  var titleContent;

  void attached() {
    this.notifyPath('title', this.title);
    collapse = $$('#prop-menu-collapse');
    content = $$('#menu-content');
    titleContent = $$('#title-content');

    closeCollapse();

    if (on_attached_listener != null) {
      on_attached_listener(this);
    }

    if (opened) {
      openCollapse();
    }
  }

  void onAttached(var func) {
    on_attached_listener = func;
  }


  @reflectable
  void onPropTap(var e, var d) {
    toggleCollapse();
    //e.stopPropagation();
  }


  bool isCollapseOpened() {
    if (collapse == null) return false;
    return collapse.opened;
  }

  void toggleCollapse() {
    collapse = $$('#prop-menu-collapse');
    if(isCollapseOpened()) {
      closeCollapse();
    } else {
      openCollapse();
    }
  }

  void openCollapse() {
    if (!isCollapseOpened()) {
      if (collapse != null) {
        collapse.toggle();
      }
    }

    if(customIcon == null) {
      ($$('#prop-menu-icon') as IronIcon).icon = 'expand-less';
    }
  }

  void closeCollapse() {
    if (isCollapseOpened()) {
      if (collapse != null) {
        collapse.toggle();
      }
    }

    if(customIcon == null) {
      ($$('#prop-menu-icon') as IronIcon).icon = 'expand-more';
    }
  }

  void setIcon(String icon) {
    customIcon = icon;
    ($$('#prop-menu-icon') as IronIcon).icon = customIcon;
  }

}