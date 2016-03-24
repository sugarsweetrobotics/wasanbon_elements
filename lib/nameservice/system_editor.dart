@HtmlImport('system_editor.html')
library ns_system_panel;

import 'dart:html' as html;
import 'package:web_components/web_components.dart' show HtmlImport;
import 'package:polymer/polymer.dart';

import 'package:wasanbon_xmlrpc/wasanbon_xmlrpc.dart';

import 'package:wasanbon_elements/message_dialog.dart';
import 'package:wasanbon_elements/collapse_block.dart';
import 'system_editor/ns_inspector.dart';


@PolymerRegister('system-editor')
class SystemEditor extends PolymerElement {

  @property var state = 'closed';
  @property var group = 'defaultGroup';

  SystemEditor.created() : super.created();

  MessageDialog messageDialog;
  InputDialog inputDialog;

  WasanbonRPC _rpc;
  set rpc(WasanbonRPC rpc_) => _rpc = rpc_;

  void attached() {
    inputDialog = $$('input-dialog');
    messageDialog = $$('message-dialog');
  }

  bool isNameServiceAlreadyShown(NameService ns) {
    bool return_value = false;
    $$('#ns-inspection-content').children.forEach(
        (html.Element e) {
      if (e is NSInspector) {
        if (e.nameService.name == ns.name) {
          return_value = true;
        }
      }
    }
    );
    return return_value;
  }

  @reflectable
  void onConnect(var e, var detail) {
    inputDialog.eventListener.ok.clear();
    inputDialog.eventListener.ok.add(
        (var e) {
      messageDialog.show("NameService", "Please Wait....");
      var hostname = inputDialog.value;
      var port = '2809';
      if (hostname.indexOf(':') >= 0) {
        port = (hostname.substring(hostname.indexOf(':') + 1));
        hostname = hostname.substring(0, hostname.indexOf(':'));
      }
      _rpc.nameService.tree(host: hostname, port: int.parse(port)).then((NameServerInfo info) {
        try {
          for (NameService ns in info.nameServers) {
            if (!isNameServiceAlreadyShown(ns)) {
              $$('#ns-inspection-content').children.add(
                  NSInspector.build(_rpc)
                    ..setParent(this)
                    ..inspect(ns)

              );
            }
          }
          messageDialog.hide();
          ($$('#collapse-blk') as CollapseBlock).openCollapse();
        } catch (e) {
          print(e);
        }
      }
      ).catchError(
          (var e) {
        messageDialog.updateText("NameService", "Error: " + e.toString());
      }
      );
    }
    );

    inputDialog.show("Connect Naming Service", "Input URL of Naming Service",
        "URL Naming Service", "localhost:2809");
  }


  void removeNSInspector(NSInspector obj) {
    var found = null;
    $$('#ns-inspection-content').children.forEach(
        (NSInspector e) {
      if (e.nameService.name == obj.nameService.name) {
        found = e;
      }
    }
    );
    $$('#ns-inspection-content').children.remove(obj);
  }

  @reflectable
  void onRefreshAll(var e, var detail) {
    $$('#ns-inspection-content').children.forEach((html.Element e) {
      if (e is NSInspector) {
        e.onRefresh(e, detail);
      }
    });

  }
}