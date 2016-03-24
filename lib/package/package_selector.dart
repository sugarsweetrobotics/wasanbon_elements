@HtmlImport('package_selector.html')
library package_selector;

import 'dart:async' as async;
import 'dart:html' as html;
import 'package:web_components/web_components.dart' show HtmlImport;
import 'package:polymer/polymer.dart';

import 'package:wasanbon_elements/wasanbon_toolbar.dart';
import 'package:wasanbon_elements/message_dialog.dart';
import 'package:wasanbon_elements/collapse_block.dart';

import 'package:wasanbon_xmlrpc/wasanbon_xmlrpc.dart';

import 'package:polymer_elements/paper_drawer_panel.dart';
import 'package:polymer_elements/paper_spinner.dart';
import 'package:polymer_elements/paper_card.dart';


@PolymerRegister('package-card')
class PackageCard extends PolymerElement {
  @property
  String packageName = 'defaultName';

  PackageInfo packageInfo;

  PackageSelector parent;

  set info (PackageInfo i) {
    packageInfo = i;
    set('packageName', packageInfo.name);

  }

  static PackageCard build(PackageSelector parent_, PackageInfo info) {
    return (new html.Element.tag('package-card') as PackageCard)
    ..info = info
    ..parent = parent_;
  }

  PackageCard.created() : super.created();

  @reflectable
  void onTap(var e, var d) {
    print('package-card[$packageInfo] onTap');
    parent.onSelectPackageEvent(packageInfo);
  }
}



@PolymerRegister('package-selector')
class PackageSelector extends PolymerElement {

  WasanbonRPC _rpc;
  set rpc(WasanbonRPC rpc_) => _rpc = rpc_;

  PackageSelector.created() : super.created();

  PaperDrawerPanel _panel;
  html.Element _content;
  PaperCard errorContent;
  html.Element spin;
  async.StreamController<PackageInfo> _packageSelectStreamController = new async.StreamController<PackageInfo>();
  async.Stream get onSelectPackage => _packageSelectStreamController.stream;


  void attached() {
    print('package-selector attaching...');
    _panel = $$('#main-drawer-panel');
    _content = $$('#package-content');
    errorContent = $$('#error-content');
    spin = $$('#load_spinner');

    print('package-selector attached. ready');
  }

  void toggle() {
    _panel.togglePanel();
  }

  void openDrawer() {
    _panel.openDrawer();
  }

  void closeDrawer() {
    _panel.closeDrawer();
  }

  void refreshPackages() {
    print('Refreshing Packages...');
    spin.style.display = 'flex';
    errorContent.style.display = 'none';
    _content.style.display ='none';

    print('xml-rpc list');
    _rpc.adminPackage.list().then((List<PackageInfo> packages) {

      spin.style.display = 'none';
      errorContent.style.display = 'none';

      _content.children.clear();

      packages.forEach((PackageInfo package) {
        _content.children.add(PackageCard.build(this, package));
      });

      _content.style.display ='inline';

    }).catchError((var e) {
      print(e);
      spin.style.display = 'none';
      errorContent.style.display = 'inline';
      _content.style.display ='none';
    });
  }


  @reflectable
  void onRefreshPackages(var e, var d) {
    refreshPackages();
  }

  void onSelectPackageEvent(PackageInfo info) {
    print('controller.add($info)');
    _packageSelectStreamController.add(info);
  }
}
