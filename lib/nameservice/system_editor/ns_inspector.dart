@HtmlImport('ns_inspector.html')
library ns_inspector;

import 'dart:html' as html;

import 'package:web_components/web_components.dart' show HtmlImport;
import 'package:polymer/polymer.dart';

import 'package:wasanbon_elements/message_dialog.dart';
import 'package:wasanbon_xmlrpc/wasanbon_xmlrpc.dart';

import '../system_editor.dart';
import 'rtc_card.dart';

import 'package:polymer_elements/paper_icon_button.dart';

import 'package:wasanbon_elements/nameservice/system_editor/ns_connection_dialog.dart';

@PolymerRegister('ns-inspector')
class NSInspector extends PolymerElement {

  static NSInspector build(WasanbonRPC rpc) {
    return (new html.Element.tag('ns-inspector') as NSInspector)
        ..rpc = rpc;
  }

  @property String address = 'none';
  @property String state = 'closed';
  @property var group = 'defaultGroup';

  PaperIconButton activateAllButton;
  PaperIconButton deactivateAllButton;
  PaperIconButton resetAllButton;

  NameService nameService;
  NSInspector.created() : super.created();
  SystemEditor parent;
  InputDialog inputDialog;
  ConfirmDialog confirmDialog;
  MessageDialog messageDialog;

  WasanbonRPC _rpc;

  set rpc(WasanbonRPC rpc_) => _rpc = rpc_;

  void attached() {
    inputDialog =  $$('input-dialog');
    confirmDialog = $$('confirm-dialog');
    messageDialog = $$('message-dialog');

    activateAllButton = $$('#activateAllButton');
    deactivateAllButton = $$('#deactivateAllButton');
    resetAllButton = $$('#resetAllButton');


    deactivateToolbar();


    confirmDialog.ptr.onOK.listen((var e) {
      parent.removeNSInspector(this);
    }
    );

  }

  void clearRTCs() {
    $$('#content').children.clear();
  }

  void inspectNode(Node node) {
    if (node is HostContext) {
      node.children.forEach((Node n) {inspectNode(n);});
    } else if (node is Component) {
      $$('#content').children.add(
        RTCCard.build(_rpc)
          ..setParent(this)
          ..setGroup(this.nameService.name)
          ..setRTC(node)
      );
    } else {
      print('Unknown:' + node.toString());
    }
  }

  void setParent(SystemEditor parent) {
    this.parent = parent;
  }

  void inspect(NameService ns) {
    nameService = ns;
    set('address', ns.name);
    ns.children.forEach(
        (Node node) {
          inspectNode(node);
        }
    );


    $$('#load_spinner').style.display = 'none';
    $$('#content').style.display = 'inline';
  }

  @reflectable
  void onClose(var e, var detail) {
    confirmDialog.show('NameService', 'Remove from this view?');

  }

  @reflectable
  void onRefresh(var e, var d, {bool withSpinner : true}) {
    var hostname = nameService.name;
    var port = '2809';
    if (hostname.indexOf(':') >= 0) {
      port = (hostname.substring(hostname.indexOf(':') + 1));
      hostname = hostname.substring(0, hostname.indexOf(':'));
    }

    if(withSpinner) {
      $$('#load_spinner').style.display = 'flex';

      $$('#content').style.display = 'none';
    }
    _rpc.nameService.tree(host: hostname, port: int.parse(port))
        .then(
        (NameServerInfo info) {

          for (NameService ns in info.nameServers) {
            if (ns.name == nameService.name) {
              clearRTCs();
              inspect(ns);
            }
          }

        }
    ).catchError(
        (var e) {
          messageDialog.show('Error: NameService.tree', e.toString());
        }
    );
  }

  @reflectable
  void onConnectRTCs(var e, var d) {
    _rpc.nameService.listConnectablePairs([nameService.name]).then((List<ConnectablePortPair> pair) {
      ($$('#connection-dialog') as NSConnectionDialog).show(pair, _rpc);
    }).catchError((var e) {
      messageDialog.show('Error: NameService.ConnectRTCs', e.toString());
    });
  }

  void activateToolbar() {

    activateAllButton.style.color = RTCCard.activeColor;
    deactivateAllButton.style.color = RTCCard.inactiveColor;
    resetAllButton.style.color = RTCCard.errorColor;
    activateAllButton.disabled = false;//.enable;//style.color = RTCCard.activeColor;
    deactivateAllButton.disabled = false;//.style.color = RTCCard.inactiveColor;
    resetAllButton.disabled = false;//.style.color = RTCCard.errorColor;
  }


  void deactivateToolbar() {
    activateAllButton.style.color = '';
    deactivateAllButton.style.color = '';
    resetAllButton.style.color = '';
    activateAllButton.disabled = true;//.style.color = '';
    deactivateAllButton.disabled = true;
    resetAllButton.disabled = true;
  }

  void refreshToolbar() {
    bool checkAtLeastOne = false;
    RTCCard.getRTCCards(this.nameService.name).forEach(
        (RTCCard c) {
          if (c.waitChecked) {
            checkAtLeastOne = true;
          }
        }
    );
    if (checkAtLeastOne) {
      activateToolbar();
    } else {
      deactivateToolbar();
    }
  }

  @reflectable
  void onActivateAllRTCs(var e, var d) {
    RTCCard.getRTCCards(this.nameService.name).forEach(
        (RTCCard c) {
          if (c.checked) {
            c.onActivateRTC(e,d);
            c.uncheck();
          }
        }
    );


  }
  @reflectable
  void onDeactivateAllRTCs(var e, var d) {
    RTCCard.getRTCCards(this.nameService.name).forEach(
        (RTCCard c) {
      if (c.checked) {
        c.onDeactivateRTC(e,d);
        c.uncheck();
      }
    }
    );
  }
  @reflectable
  void onResetAllRTCs(var e, var d) {
    RTCCard.getRTCCards(this.nameService.name).forEach(
        (RTCCard c) {
      if (c.checked) {
        c.onResetRTC(e,d);
        c.uncheck();
      }
    }
    );
  }
}