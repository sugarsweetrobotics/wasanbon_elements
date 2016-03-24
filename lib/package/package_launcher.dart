@HtmlImport('package_launcher.html')
library package_launcher;

import 'dart:async' as async;
import 'dart:html' as html;
import 'package:web_components/web_components.dart' show HtmlImport;
import 'package:polymer/polymer.dart';

import 'package:wasanbon_elements/wasanbon_toolbar.dart';
import 'package:wasanbon_elements/message_dialog.dart';
import 'package:wasanbon_elements/collapse_block.dart';

import 'package:wasanbon_xmlrpc/wasanbon_xmlrpc.dart';

import 'package:polymer_elements/paper_checkbox.dart';
import 'package:polymer_elements/paper_spinner.dart';
import 'package:polymer_elements/paper_card.dart';


@PolymerRegister('package-rtc-card')
class PackageRtcCard extends PolymerElement {

  static PackageRtcCard build(String name) {
    return (new html.Element.tag('package-rtc-card') as PackageRtcCard)
        ..set('packageName', name);
  }

  @property
  String packageName = 'Default RTC Name';

  PackageRtcCard.created() : super.created();
}

@PolymerRegister('package-launcher')
class PackageLauncher extends PolymerElement {

  WasanbonRPC _rpc;

  set rpc(WasanbonRPC rpc_) => _rpc = rpc_;

  @property
  String packageName = 'No packages are selected';
  @property
  String packagePath = '';
  @property
  String packageDescription = 'Default description';

  PackageInfo packageInfo;

  html.Element packageContent;
  html.Element errorContent;
  html.Element runContent;
  html.Element terminateContent;
  //PaperToast toast;
  MessageDialog messageDialog;

  CollapseBlock collapseBlock;

  set info (PackageInfo i) {
    print('package-launcher setInfo($i)');
    packageInfo = i;
    set('packageName', packageInfo.name);
    set('packagePath', packageInfo.path);
    set('packageDescription', packageInfo.description);
    errorContent.style.display = 'none';
    packageContent.style.display = 'block';
    running = i.running;

    $$('#rtc-card-content').children.clear();
    i.rtcNames.forEach((String name) {
      $$('#rtc-card-content').children.add(PackageRtcCard.build(name));
    });
  }

  set running (bool f) {
    if (f) {
      runContent.style.display = 'none';
      terminateContent.style.display = 'block';
    } else {
      runContent.style.display = 'block';
      terminateContent.style.display = 'none';
    }
  }

  PackageLauncher.created() : super.created();

  void attached() {
    collapseBlock = $$('#title-area');
    packageContent = $$('#package-content');
    errorContent = $$('#error-content');
    terminateContent = $$('#terminate-content');
    runContent = $$('#run-content');
    messageDialog = $$('#message-dialog');
    //toast = $$('#package-launcher-toast');
    //running = false;
  }


  void openCollapse() {
    collapseBlock.openCollapse();
  }

  @reflectable
  void onRun(var e, var d) {
    bool buildSystem = !(($$('#plain-run-checkbox') as PaperCheckbox).checked);
    bool activateSystem = !(($$('#inactive-run-checkbox') as PaperCheckbox).checked);
    _rpc.mgrSystem.run(packageInfo.name, packageInfo.defaultSystem, buildSystem: buildSystem, activateSystem: activateSystem).then((bool f) {
      messageDialog.show('Run', 'Success');
      onRefresh(null, null);
    }).catchError((var e) {
      messageDialog.show('Run', 'Failed. $e');
    });
  }

  @reflectable
  void onTerminate(var e, var d) {
    _rpc.mgrSystem.terminate(packageInfo.name).then((bool f) {
      messageDialog.show('Terminate', 'Success');
      onRefresh(null, null);
    }).catchError((var e) {
      messageDialog.show('Run', 'Failed. $e');
    });
  }

  @reflectable
  void onRefresh(var e, var d) {
    _rpc.mgrSystem.is_running(packageInfo.name).then((bool flag) {
      running = flag;
    }).catchError((var e) {
      messageDialog.show('Error', 'Error. Connecting Wasanbon Server: $e');
    });
  }
}
