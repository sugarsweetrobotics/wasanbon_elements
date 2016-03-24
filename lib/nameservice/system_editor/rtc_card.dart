@HtmlImport('rtc_card.html')
library rtc_card;

import 'dart:html' as html;
import 'package:web_components/web_components.dart' show HtmlImport;
import 'package:polymer/polymer.dart';

import 'package:polymer_elements/iron_icon.dart';
import 'package:polymer_elements/paper_icon_button.dart';

import 'package:wasanbon_xmlrpc/wasanbon_xmlrpc.dart';

import 'ns_inspector.dart';
import 'port_prop_card.dart';

import 'ns_configure_dialog.dart';


@PolymerRegister('rtc-prop-card')
class RTCPropCard extends PolymerElement {


  @property String name = 'name';
  @property String value = 'value';
  RTCPropCard.created() : super.created();

  void update(String name_, String value_) {
    set('name', name_);
    set('value', value_);
  }

  void setIcon(String icon_) {
    ($$('#rtc-prop-icon') as IronIcon).icon = icon_;
  }

  void attached() {
  }

  static RTCPropCard build() {
    return new html.Element.tag('rtc-prop-card');
  }
}


@PolymerRegister('rtc-card')
class RTCCard extends PolymerElement {

  static RTCCard build(WasanbonRPC rpc) {
    return (new html.Element.tag('rtc-card') as RTCCard)
        ..rpc = rpc;
  }

  @property String name;
  RTCCard.created() : super.created();
  @property String state = 'inactive';
  @property String group = 'defaultGroup';
  @property String fullpath = '';
  var backgroundColor_old = 'red';
  var icon_old;

  PaperIconButton icon;
  Component component;
  NSInspector parent;

  bool _waitChecked = false;
  bool _checked = false;

  WasanbonRPC _rpc;
  set rpc(WasanbonRPC rpc_) => _rpc = rpc_;

  static var activeColor = 'green';
  static var inactiveColor = 'blue';
  static var errorColor = 'red';
  static var zombieColor = 'gray';

  static Map<String, List<RTCCard>> _group = {};
  static List<RTCCard> getRTCCards(String groupName) {
    if (_group.keys.contains(groupName)) {
      return _group[groupName];
    } else {
      return [];
    }
  }


  void attached() {
    if (!_group.keys.contains(group)) {
      _group[group] = [];
    }

    if (!_group.values.contains(this)) {
      _group[group].add(this);
    }

    icon = $$('#rtc-icon');

  }

  void setGroup(String grp) {
    if(_group.keys.contains(group)) {
      _group[group].remove(this);
    }

    group = grp;
    if (!_group.keys.contains(group)) {
      _group[group] = [];
    }

    if(!_group.values.contains(this)) {
      _group[group].add(this);
    }
  }

  void setIconColor(bool flag) {
    if (component.state == 'Active') {
      icon.style.backgroundColor = activeColor;
      icon.style.color = "white";
    } else if (component.state == 'Inactive'){
      icon.style.backgroundColor = inactiveColor;
      icon.style.color = "white";
    } else {
      icon.style.backgroundColor = errorColor;
      icon.style.color = "white";
    }
  }

  void check() {
    icon.icon = 'check';
    setIconColor(false);
    _checked = true;
    _group[this.group].forEach(
        (RTCCard c) {
          c.deactivate();
          c.waitCheck(true);
        }
    );

    parent.refreshToolbar();
  }

  void uncheck() {
    _checked = false;
    icon.icon = 'extension';
    setIconColor(true);

    bool allNotChecked = true;
    _group[this.group].forEach(
        (RTCCard c) {
      allNotChecked = allNotChecked && !c.checked;
      }
    );

    _group[this.group].forEach(
        (RTCCard c) {
          if (allNotChecked) {
            c.waitCheck(false);
          } else {
            c.waitCheck(true);
          }

      }
    );
    parent.refreshToolbar();
  }

  void waitCheck(bool flag) {
    _waitChecked = flag;
    if (waitChecked && !checked) {
      icon.icon = 'check-box-outline-blank';
      setIconColor(false);
    } else if(!waitChecked) {
      icon.icon = 'extension';
      setIconColor(true);
    }
  }


  void toggleCheck() {
    if (checked) {
      uncheck();
    } else {
      check();
    }
  }

  bool get checked => _checked;
  bool get waitChecked => _waitChecked;

  @reflectable
  void onTapIcon(var e, var detail) {
    toggleCheck();
    e.stopPropagation();
  }

  void setParent(NSInspector parent) {
    this.parent = parent;
  }

  void setRTC(Component component) {
    this.component = component;
    set('name', component.name);
    var menu = $$('#basic-menu-content');
    menu.children.add( RTCPropCard.build()
      ..update('full_path', component.full_path)
    ..setIcon('chevron-right'));
    menu.children.add( RTCPropCard.build()
      ..update('state', component.state)
      ..setIcon('chevron-right'));


    var port_menu = $$('#port-menu-content');
    component.inPorts.forEach((PortBase port) {
      port_menu.children.add(PortPropCard.fromInPort(port, _rpc));
    });

    component.outPorts.forEach((PortBase port) {
      port_menu.children.add(PortPropCard.fromOutPort(port, _rpc));
    });

    component.servicePorts.forEach((PortBase port) {
      if (port is ServicePort) {
        port.properties.children.forEach((Node node) {
          print(':' + node.name + '.' + node.value);
        });
      }
      port_menu.children.add(PortPropCard.fromServicePort(port, _rpc));
    });


    var prop_menu = $$('#prop-menu-content');
    var keys = [];
    component.properties.children.forEach((Node node) {
      keys.add(node.name);
    });

    keys.sort();

    keys.forEach((String key) {
      if (!key.startsWith('conf.')) {
        var value = component.properties[key];
        prop_menu.children.add( RTCPropCard.build()
          ..update(key, value)
          ..setIcon('chevron-right')
        );
      }
    });


    var conf_menu = $$('#conf-menu-content');
    component.configurationSets.forEach((ConfigurationSet cset) {
      if (!cset.name.startsWith(('_'))) {
        cset.forEach((Configuration conf) {
          if (!conf.name.startsWith(('_'))) {
            conf_menu.children.add( RTCPropCard.build()
              ..update('Configuration',
                  'conf.' + cset.name + '.' + conf.name + ':' + conf.value)
              ..setIcon('create')
            );
          }
        });
      }

      if (cset.name.startsWith(('_'))) {
        cset.forEach((Configuration conf) {
          if (conf.name.startsWith(('_'))) {
            conf_menu.children.add(RTCPropCard.build()
              ..update('Configuration',
                  'conf.' + cset.name + '.' + conf.name + ':' + conf.value)
                ..setIcon('visibility-off')
            );
          }
        });
      }
    });

    component.configurationSets.forEach((ConfigurationSet cset) {
      if(cset.name.startsWith('_')) {
        cset.forEach((Configuration conf) {
          if (!conf.name.startsWith(('_'))) {
            conf_menu.children.add(RTCPropCard.build()
              ..update('Configuration',
                  'conf.' + cset.name + '.' + conf.name + ':' + conf.value)
              ..setIcon('visibility-off'));
          }
        });

        cset.forEach((Configuration conf) {
          if (conf.name.startsWith(('_'))) {
            conf_menu.children.add(RTCPropCard.build()
              ..update('Configuration',
                  'conf.' + cset.name + '.' + conf.name + ':' + conf.value)
              ..setIcon('visibility-off'));
          }
        });
      }
    });

    icon = $$('#rtc-icon');
    setIconColor(true);
  }

  @reflectable
  void onTap(var e, var detail) {
    toggle();
  }

  void toggle() {
    if (state == 'active') {
      deactivate();
    } else {
      activate();
    }
  }

  void activate() {
    $$('#container').style.setProperty('margin', '20px 20px 20px 20px');
    $$('#card-content-bar').style.setProperty('border-bottom-width', '1px solid, #B6B6B6');
//    $$('#card-content-bar').style.borderBottomStyle = 'solid:
//    $$('#card-content-bar').style.borderBottomColor = '#B6B6B6';
    state = 'active';
    for(RTCCard card in _group[group]) {
      if (card != this) {
        card.deactivate();
      }
    }

    var collapse = $$('#detail');
    if (!collapse.opened) {
      collapse.toggle();
    }

    //set('fullpath', component.full_path);

  }

  void deactivate() {
    var collapse = $$('#detail');
    if (collapse.opened) {
      collapse.toggle();
    }
    $$('#container').style.setProperty('margin', '0px 40px 0px 40px');
    $$('#card-content-bar').style.setProperty('border-bottom', 'none');
    state = 'inactive';
  }

  @reflectable
  void onActivateRTC(var e, var d) {
    _rpc.nameService.activateRTC(component.full_path);
    parent.onRefresh(e, d, withSpinner: false);
    e.stopPropagation();
  }

  @reflectable
  void onDeactivateRTC(var e, var d) {
    _rpc.nameService.deactivateRTC(component.full_path);
    parent.onRefresh(e, d, withSpinner: false);
    e.stopPropagation();

  }

  @reflectable
  void onResetRTC(var e, var d) {
    _rpc.nameService.resetRTC(component.full_path);
    parent.onRefresh(e, d, withSpinner: false);
    e.stopPropagation();

  }

  @reflectable
  void onExitRTC(var e, var d) {
    _rpc.nameService.exitRTC(component.full_path);
    parent.onRefresh(e, d, withSpinner: false);
    e.stopPropagation();

  }

  @reflectable
  void onConfigureRTC(var e, var d) {
    ($$('#configure-dialog') as NSConfigureDialog ).show(component, _rpc);
    e.stopPropagation();
  }


}
