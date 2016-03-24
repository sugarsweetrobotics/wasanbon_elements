@HtmlImport('host_ns_manager.html')
library host_ns_manager;

import 'dart:html';
import 'package:web_components/web_components.dart' show HtmlImport;
import 'package:polymer/polymer.dart';

import 'package:wasanbon_elements/message_dialog.dart';
//import 'package:nameservicemanager/nameservicemanager.dart';
import 'package:wasanbon_xmlrpc/wasanbon_xmlrpc.dart';
import '../collapse_block.dart';
import '../message_dialog.dart';

@PolymerRegister('host-ns-manager')
class HostNSManager extends PolymerElement {


  HostNSManager create() {
    return new Element.tag('host-ns-manager');
  }


  @property int port = 2809;
  @property var state = 'closed';
  @property var group = 'defaultGroup';
  MessageDialog messageDialog;

  WasanbonRPC _rpc;

  set rpc(WasanbonRPC rpc_) => _rpc = rpc_;

  HostNSManager.created() : super.created();

  void attached() {
    messageDialog = $$('#message-dialog');
  }

  @reflectable
  void onCheck(var e, var v) {
    messageDialog.show('NameService', 'Checking....');
    _rpc.nameService.checkRunning(port).then((bool launched) {
          print (launched);
          if (launched) {
            messageDialog.updateText("NameService", 'Launched');
          } else {
            messageDialog.updateText("NameService", 'Not Launched');
          }
        }
    )
    .catchError(
        (var e) {
          messageDialog.updateText("Error", e.toString());
        }
    );
  }

  @reflectable
  void onStart(var e, var v) {
    messageDialog.show('NameService', 'Starting....');
    _rpc.nameService.start(port).then((Process p) {
      if (p != null) {
        messageDialog.updateText("NameService", 'Successfully Launched');
      } else {
        messageDialog.updateText("NameService", 'Failed');
      }
    }).catchError((var e) {
      messageDialog.updateText("Error", e.toString());
    });
  }

  @reflectable
  void onStop(var e, var v) {
    messageDialog.show('NameService', 'Stopping....');
    _rpc.nameService.stop(port).then((Process p) {
      if (p != null) {
        messageDialog.updateText("NameService", 'Successfully Stopped');
      } else {
        messageDialog.updateText("NameService", 'Failed');
      }
    }).catchError((var e) {
      messageDialog.updateText("Error", e.toString());
    });
  }
}