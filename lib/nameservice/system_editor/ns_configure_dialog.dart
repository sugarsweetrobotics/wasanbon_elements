
@HtmlImport('ns_configure_dialog.html')
library ns_configure_dialog;

import 'dart:html' as html;
import 'package:web_components/web_components.dart' show HtmlImport;
import 'package:polymer/polymer.dart';

import 'package:polymer_elements/paper_dialog.dart';
import 'package:wasanbon_xmlrpc/wasanbon_xmlrpc.dart';



@PolymerRegister('conf-card')
class ConfCard extends PolymerElement {

  static ConfCard build(WasanbonRPC rpc) {
    return (new html.Element.tag('conf-card') as ConfCard)
        ..rpc = rpc;
  }
  Configuration _configuration;
  @property String confName;
  @property String confValue;

  ConfCard.created() : super.created();

  WasanbonRPC _rpc;
  set rpc(WasanbonRPC rpc_) => _rpc = rpc_;

  void update(Configuration configuration, {String widget : 'text', String constraints : ''}) {
    _configuration = configuration;
    this.confName = configuration.name;
    this.confValue = configuration.value;
    set('confName', confName);
    set('confValue', confValue);

    print('ConfCard.load(' + configuration.name + ', ' + widget + ', ' + constraints + ')');
  }

  void configure(Component component, ConfigurationSet confSet) {
    print('Configuring [${component.full_path}.${confSet.name}.$confName.$confValue');
    _rpc.nameService.configureRTC(component.full_path, confSet.name, confName, confValue).then((var e) {
      print(e);
    }).catchError((var d) {
      print(d);
    });

  }
}


@PolymerRegister('ns-configure-tool')
class NSConfigureTool extends PolymerElement {

  static NSConfigureTool build(WasanbonRPC rpc) {
    return (new html.Element.tag('ns-configure-tool') as NSConfigureTool)
        ..rpc = rpc;
  }
  Component _component;
  ConfigurationSet _configurationSet;

  NSConfigureTool.created() : super.created();

  @property String configurationSetName = 'defaultTitle';

  WasanbonRPC _rpc;
  set rpc(WasanbonRPC rpc_) => _rpc = rpc_;

  void attached() {
    if(_component != null) {
      updateView();
    }

    // $$('#detail').openCollapse();
  }

  String getConfigurationWidget(Configuration conf) {
    String return_value = 'text';
    _component.configurationSets.forEach((ConfigurationSet confSet) {
      if (confSet.name == '__widget__') {
        confSet.forEach((Configuration wConf) {
          if(wConf.name == conf.name) {
            return_value = wConf.value.toString();
          }
        });
      }
    });
    return return_value;
  }

  String getConfigurationConstraint(Configuration conf) {
    String return_value = '';
    _component.configurationSets.forEach((ConfigurationSet confSet) {
      if (confSet.name.toString() == '__constraints__') {
        confSet.forEach((Configuration wConf) {
          if(wConf.name.toString() == conf.name.toString()) {
            return_value = wConf.value;
          }
        });
      }
    });
    return return_value;
  }

  void load(Component component, ConfigurationSet configurationSet) {
    _component = component;
    _configurationSet = configurationSet;
    updateView();
  }

  void updateView() {

    set('configurationSetName', _configurationSet.name);

    var content = $$('#configure-content');

    content.children.clear();
    _configurationSet.forEach((Configuration conf) {
      var e = ConfCard.build(_rpc)
          ..update(conf, widget: getConfigurationWidget(conf), constraints: getConfigurationConstraint(conf));
      content.children.add(e);
    });


    if(_configurationSet.name == 'default') {
      //openCollapse();
      //$$('#detail').opened = true;
    } else {
      //closeCollapse();
    }

  }

  void configure() {

    var content = $$('#configure-content');
    content.children.forEach((ConfCard cc) {
      cc.configure(_component, _configurationSet);
    });
  }

  @reflectable
  void onTap(var e, var d) {
    //toggleCollapse();
  }


  /*
  bool isCollapseOpened() => $$('#detail').isCollapseOpened();

  void openCollapse() {
    if (!isCollapseOpened()) {
      print('openCollapse');
      $$('#detail').toggleCollapse();
      this.classes.add('opened-collapse');
    }
  }

  void closeCollapse() {
    if (isCollapseOpened()) {
      print('closeCollapse');
      $$('#detail').toggleCollapse();
      this.classes.remove('opened-collapse');
    }
  }

  void toggleCollapse() {
    if(isCollapseOpened()) {
      closeCollapse();
    } else {
      openCollapse();
    }
  }
  */
}

@PolymerRegister('ns-configure-dialog')
class NSConfigureDialog extends PolymerElement {

  @property String header = 'Header';
  @property String msg = 'Here is the message';

  NSConfigureDialog.created() : super.created();

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

  void show(Component component, WasanbonRPC rpc_) {

    html.HtmlElement content = $$('#content');
    content.children.clear();
    component.configurationSets.forEach((ConfigurationSet confSet) {
      if (!confSet.name.startsWith('_')) {
        content.children.add(NSConfigureTool.build(rpc_) //new html.Element.tag('ns-configure-tool')
          ..load(component, confSet));
      }
    });

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

    html.HtmlElement content = $$('#content');
    content.children.forEach((NSConfigureTool tool) {
      tool.configure();
    });
    /*
    HtmlElement content = $$('#content');
    content.children.forEach(
        (NSConnectTool nst) {
          if(nst.willConnect) {
             rpc.nameService.connectPorts(nst.pair, param: nst.param);
          } else if(nst.willDisconnect) {
            rpc.nameService.disconnectPorts(nst.pair);
          }
        }
    );
    */
  }

  @reflectable
  void onCanceled(var e, var d) {
  }

  void onClosed(var e, var d) {
  }
}
