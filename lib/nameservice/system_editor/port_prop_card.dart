@HtmlImport('port_prop_card.html')
library port_prop_card;

import 'dart:html' as html;

import 'package:web_components/web_components.dart' show HtmlImport;
import 'package:polymer/polymer.dart';

import 'package:wasanbon_elements/collapse_paper_item.dart';
import 'ns_inspector.dart';

import 'package:wasanbon_xmlrpc/wasanbon_xmlrpc.dart';
import 'package:polymer_elements/iron_icon.dart';

import 'package:polymer_elements/iron_collapse.dart';
import 'rtc_card.dart';




@PolymerRegister('port-prop-card')
class PortPropCard extends PolymerElement {

  static PortPropCard build(WasanbonRPC rpc) {
    return (new  html.Element.tag('port-prop-card') as PortPropCard)
    ..rpc = rpc;
  }

  @property String name = 'name';
  @property String value = 'value';

  @property String title = 'default_title';
  PortPropCard.created() : super.created();

  IronCollapse collapse;
  html.HtmlElement content;

  var on_attached_litener = null;

  WasanbonRPC _rpc;
  set rpc(WasanbonRPC rpc_) => _rpc = rpc_;

  void update(String name_, String value_) {
    set('name', name_);
    set('value', value_);
  }

  void attached() {
    collapse = $$('#port-menu-collapse');
    content = $$('#port-prop-content');
    closeCollapse();

    if(on_attached_litener != null) {
      on_attached_litener(this);
    }
  }

  void onAttached(var func) {
    on_attached_litener = func;
  }

  @reflectable
  void onPropTap(var e, var d) {
    toggleCollapse();
    e.stopPropagation();
  }

  bool isCollapseOpened() {
    return collapse.opened;
  }
  void toggleCollapse() {
    if(isCollapseOpened()) {
      closeCollapse();
    } else {
      openCollapse();
    }
  }

  void openCollapse() {
    if (!isCollapseOpened()) {
      collapse.toggle();
    }
  }

  void closeCollapse() {
    if (isCollapseOpened()) {
      collapse.toggle();
    }
  }

  static PortPropCard fromInPort(DataInPort port, WasanbonRPC rpc) {
    PortPropCard e = PortPropCard.build(rpc)
      ..update('DataInPort', port.name)
      ..setIcon('label-outline');

    var keys = [];
    port.properties.children.forEach((Node n) => keys.add(n.name));
    keys.sort();

    e.onAttached((var elem) {
      keys.forEach((String key) {
        elem.content.children.add( RTCPropCard.build()
          ..update(key, port.properties[key])
          ..setIcon('chevron-right'));
      });
    });

    return e;
  }

  static PortPropCard fromOutPort(PortBase port, WasanbonRPC rpc) {
    PortPropCard e =  PortPropCard.build(rpc)
      ..update('DataOutPort', port.name)
      ..setIcon('label');

    var keys = [];
    port.properties.children.forEach((Node n) => keys.add(n.name));
    keys.sort();

    e.onAttached((var elem) {
      keys.forEach((String key) {
        elem.content.children.add( RTCPropCard.build()
          ..update(key, port.properties[key])
          ..setIcon('chevron-right'));
      });
    });

    return e;
  }

  static PortPropCard fromServicePort(ServicePort port, WasanbonRPC rpc) {
    PortPropCard e = PortPropCard.build(rpc)
      ..update('ServicePort', port.name)
      ..setIcon('av:stop');



    var keys = [];
    port.properties.children.forEach((Node n) => keys.add(n.name));
    keys.sort();

    e.onAttached((var elem) {
      keys.forEach((String key) {
        if (key != 'port.port_type') {
          elem.content.children.add(RTCPropCard.build()
            ..update(key, port.properties[key])
            ..setIcon('chevron-right'));
        }
      });

      port.interfaces.forEach((ServiceInterface interface) {
        var icon = 'toll';
        if (interface.polarity == 'Provided') {
          icon = 'av:fiber-smart-record';
        }

        elem.content.children.add(CollapsePaperItem.build()
          ..setIcon(icon)
          ..onAttached((var element) {
            element.titleContent.children.add(new html.Element.html('''
          <div class="vertical layout"></div>
          ''')
              ..children.add(new html.Element.html('''
            <div>${interface.type_name}</div>
          '''))
              ..children.add(new html.Element.html('''
            <div class="secondary-title">ServiceInterface.type_name</div>
          ''')
                ..style.fontSize = '14px'
                ..style.color = '#727272'
                ..style.fontFamily = "'Roboto', 'Noto', sans-serif"
                ..style.setProperty('-webkit-font-smoothing', 'antialiased')
              )
            );

            element.content.children.add(RTCPropCard.build()
              ..update('instance_name', interface.instance_name)
              ..setIcon('chevron-right'));
            element.content.children.add(RTCPropCard.build()
              ..update('polarity', interface.polarity)
              ..setIcon('chevron-right'));
          }));
      });
    });

    return e;
  }

  void setIcon(String icon_) {
    ($$('#port-prop-icon') as IronIcon).icon = icon_;

    //($$('#port-prop-icon') as IronIcon).style.setProperty('transform', 'rotateX( 90deg)');
  }
}
