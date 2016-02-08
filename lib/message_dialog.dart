
@HtmlImport('message_dialog.html')
library message_dialog;

import 'dart:html';
import 'package:web_components/web_components.dart' show HtmlImport;
import 'package:polymer/polymer.dart';

import 'package:polymer_elements/paper_dialog.dart';
import 'package:polymer_elements/paper_input.dart';

class DialogEventListener {

  DialogEventListener();

  var ok = [];
  var close = [];
  var cancel = [];
}



@PolymerRegister('dialog-base')
class DialogBase extends PolymerElement {

  @property String header = 'Header';
  @property String msg = 'Here is the message';

  DialogBase.created() : super.created();

  DialogEventListener eventListener = new DialogEventListener();
  @override
  void attached() {
    ($$('#dialog') as PaperDialog).addEventListener('iron-overlay-canceled',
        (var e) {
          onCanceled(e);
        });
    ($$('#dialog') as PaperDialog).addEventListener('iron-overlay-closed',
        (var e) {
      onClosed(e);
    });
  }

  @reflectable
  void toggle() {
    ($$('#dialog') as PaperDialog).toggle();
  }

  void show(String header_, String message) {
    updateText(header_, message);
    toggle();
  }

  void hide() {
    if (($$('#dialog') as PaperDialog).opened) {
      toggle();
    }
  }

  void updateText(String header_, String message) {
    set('header', header_);
    set('msg', message);
//    ($$('#header_msg') as HtmlElement).innerHtml = header;
//    ($$('#message_box') as HtmlElement).innerHtml = message;
  }

  @reflectable
  void onOk(var e) {
    for (var func in eventListener.ok) {
      func(this);
    }
  }

  void onCanceled(var e) {
    for (var func in eventListener.cancel) {
      func(this);
    }
  }

  void onClosed(var e) {
    for (var func in eventListener.close) {
      func(this);
    }
  }
}


@PolymerRegister('message-dialog')
class MessageDialog extends PolymerElement {

  MessageDialog.created() : super.created();

  DialogEventListener get eventListener => ($$('#dialog') as DialogBase).eventListener;

  @reflectable
  toggle() => ($$('#dialog') as DialogBase).toggle();
  show(header,message) => ($$('#dialog') as DialogBase).show(header,message);
  hide() => ($$('#dialog') as DialogBase).hide();
  updateText(header, message) => ($$('#dialog') as DialogBase).updateText(header, message);
  @reflectable
  onOk(var e, var d) => ($$('#dialog') as DialogBase).onOk(e);
}


@PolymerRegister('confirm-dialog')
class ConfirmDialog extends PolymerElement {

  ConfirmDialog.created() : super.created();

  DialogEventListener get eventListener  => ($$('#dialog') as DialogBase).eventListener;

  @reflectable
  toggle() => ($$('#dialog') as DialogBase).toggle();
  show(header,message) => ($$('#dialog') as DialogBase).show(header,message);
  hide() => ($$('#dialog') as DialogBase).hide();
  updateText(header, message) => ($$('#dialog') as DialogBase).updateText(header, message);

  @reflectable
  onOk(var e, var d) => ($$('#dialog') as DialogBase).onOk(e);
}

@PolymerRegister('input-dialog')
class InputDialog extends PolymerElement {

  @property String value;

  InputDialog.created() : super.created();

  DialogEventListener get eventListener  => ($$('#dialog') as DialogBase).eventListener;

  @reflectable
  toggle() => ($$('#dialog') as DialogBase).toggle();

  void show(header, message, label, defaultValue) {
    ($$('#dialog') as DialogBase).show(header, message);

    ($$('#input-box') as PaperInput).label = label;
    ($$('#input-box') as PaperInput).value = defaultValue;
  }
  hide() => ($$('#dialog') as DialogBase).hide();
  updateText(header, message) => ($$('#dialog') as DialogBase).updateText(header, message);

  @reflectable
  onOk(var e, var d) => ($$('#dialog') as DialogBase).onOk(e);
}