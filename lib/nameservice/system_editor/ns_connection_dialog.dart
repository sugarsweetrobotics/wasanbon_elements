
@HtmlImport('ns_connection_dialog.html')
library ns_connection_dialog;

import 'dart:html';
import 'package:web_components/web_components.dart' show HtmlImport;
import 'package:polymer/polymer.dart';

import 'package:polymer_elements/paper_dialog.dart';
import 'package:polymer_elements/iron_collapse.dart';
import 'package:polymer_elements/paper_button.dart';
import 'package:wasanbon_xmlrpc/wasanbon_xmlrpc.dart';


@PolymerRegister('ns-connect-tool')
class NSConnectTool extends PolymerElement {

  static NSConnectTool build() {
    return new Element.tag('ns-connect-tool');
  }

  List<String> ports = [];
  @property String port0 = "portA";
  @property String port1 = "portB";
  @property String labelName;
  @property String port0name = '';
  @property String port0component = '';
  @property String port1name = '';
  @property String port1component = '';

  ConnectablePortPair pair;
  String param = '';
  PaperButton connectButton = null;
  PaperButton disconnectButton = null;

  NSConnectTool.created() : super.created();

  bool willConnect = false;
  bool willDisconnect = false;

  IronCollapse detailCollapse;


  void attached() {
    connectButton = $$('#connect-btn');
    disconnectButton = $$('#disconnect-btn');

    if(pair != null) {
      updateView(pair.connected);
    }

    detailCollapse = ($$('#detail') as IronCollapse);
  }

  void load(ConnectablePortPair pair) {
    this.pair = pair;
    this.ports.addAll(pair.ports);
    set('port0', pair.ports[0]);
    set('port1', pair.ports[1]);

    var index0 = pair.ports[0].indexOf(':');
    set('port0component', pair.ports[0].substring(0, index0));
    set('port0name', pair.ports[0].substring(index0+1));
    var index1 = pair.ports[1].indexOf(':');
    set('port1component', pair.ports[1].substring(0, index1));
    set('port1name', pair.ports[1].substring(index1+1));

    willConnect = pair.connected;
    updateView(pair.connected);

    if (!pair.connected) {
      $$('#connected-icon').style.display = 'none';
      $$('#disconnected-icon').style.display = 'inline';
    } else {
      $$('#connected-icon').style.display = 'inline';
      $$('#disconnected-icon').style.display = 'none';
    }
  }

  void updateView(bool connected) {
    if (connectButton != null && disconnectButton != null) {
      if (connected) {
        connectButton.style.display = 'none';
        disconnectButton.style.display = 'inline';
      } else {
        connectButton.style.display = 'inline';
        disconnectButton.style.display = 'none';
      }
    }
  }

  @reflectable
  void onConnect(var e, var d) {
    willConnect = true;
    willDisconnect = false;
    connectButton.style.display = 'none';
    disconnectButton.style.display = 'inline';
//    e.stopPropagation();
  }

  @reflectable
  void onDisconnect(var e, var d) {
    willConnect = false;
    willDisconnect = true;
    connectButton.style.display = 'inline';
    disconnectButton.style.display = 'none';
//    e.stopPropagation();
  }

  @reflectable
  void onTap(var e, var d) {
    toggleCollapse();
  }


  bool isCollapseOpened() => ($$('#detail') as IronCollapse).opened;

  void openCollapse() {
    if (!isCollapseOpened()) {
      detailCollapse.toggle();

    }
  }

  void closeCollapse() {
    if (isCollapseOpened()) {
      detailCollapse.toggle();
    }
  }

  void toggleCollapse() {
    detailCollapse.toggle();
  }
}

@PolymerRegister('ns-connection-dialog')
class NSConnectionDialog extends PolymerElement {

  @property String header = 'Header';
  @property String msg = 'Here is the message';

  NSConnectionDialog.created() : super.created();

  WasanbonRPC _rpc;
  set rcp(WasanbonRPC rpc_) => _rpc = rpc_;

  @override
  void attached() {
    ($$('#dialog') as PaperDialog).addEventListener('iron-overlay-canceled',
        (var e) {
      onCanceled(e, null);
    });
    ($$('#dialog') as PaperDialog).addEventListener('iron-overlay-closed',
        (var e) {
      onClosed(e, null);
    });
  }

  @reflectable
  void toggle() {
    ($$('#dialog') as PaperDialog).toggle();
  }

  void show(List<ConnectablePortPair> pairs, WasanbonRPC rpc_) {
    _rpc = rpc_;
    HtmlElement content = $$('#content');
    content.children.clear();
    pairs.forEach(
        (ConnectablePortPair pair) {
          content.children.add(NSConnectTool.build()
              ..load(pair));
        }
    );

    print(pairs);
    if (!($$('#dialog') as PaperDialog).opened) {
      toggle();
    }
  }

  void hide() {
    if (($$('#dialog') as PaperDialog).opened) {
      toggle();
    }
  }

  @reflectable
  void onOk(var e, var d) {
    HtmlElement content = $$('#content');
    content.children.forEach(
        (NSConnectTool nst) {
          if(nst.willConnect) {
            _rpc.nameService.connectPorts(nst.pair, param: nst.param);
          } else if(nst.willDisconnect) {
            _rpc.nameService.disconnectPorts(nst.pair);
          }
        }
    );
  }

  @reflectable
  void onCanceled(var e, var d) {
  }

  void onClosed(var e, var d) {
  }
}
