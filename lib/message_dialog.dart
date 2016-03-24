
@HtmlImport('message_dialog.html')
library message_dialog;

import 'dart:html' as html;
import 'dart:async' as async;
import 'package:web_components/web_components.dart' show HtmlImport;
import 'package:polymer/polymer.dart';

import 'package:polymer_elements/paper_dialog.dart';
import 'package:polymer_elements/paper_input.dart';

@PolymerRegister('dialog-base')
class DialogBase extends PolymerElement {

  async.StreamController<html.Event> _onOKEvent = new async.StreamController<html.Event>();
  async.Stream get onOK => _onOKEvent.stream;


  async.StreamController<html.Event> _onCanceledEvent = new async.StreamController<html.Event>();
  async.Stream get onCanceled => _onCanceledEvent.stream;


  async.StreamController<html.Event> _onClosedEvent = new async.StreamController<html.Event>();
  async.Stream get onClosed => _onClosedEvent.stream;

  @property String header = 'Header';
  @property String msg = 'Here is the message';

  DialogBase.created() : super.created();

  @override
  void attached() {
    ($$('#dialog') as PaperDialog).addEventListener('iron-overlay-canceled',
        (var e) {
          onTapCanceled(e);
        });
    ($$('#dialog') as PaperDialog).addEventListener('iron-overlay-closed',
        (var e) {
      onTapClosed(e);
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
  void onTapOK(var e) {
    _onOKEvent.add(e);
  }

  void onTapCanceled(var e) {
    _onCanceledEvent.add(e);
  }

  void onTapClosed(var e) {
    _onClosedEvent.add(e);
  }
}


@PolymerRegister('message-dialog')
class MessageDialog extends PolymerElement {

  MessageDialog.created() : super.created();

  DialogBase get ptr => $$('#dialog');

  @reflectable
  toggle() => ($$('#dialog') as DialogBase).toggle();
  show(header,message) => ($$('#dialog') as DialogBase).show(header,message);
  hide() => ($$('#dialog') as DialogBase).hide();
  updateText(header, message) => ($$('#dialog') as DialogBase).updateText(header, message);
  @reflectable
  onOk(var e, var d) => ($$('#dialog') as DialogBase).onTapOK(e);
}


@PolymerRegister('confirm-dialog')
class ConfirmDialog extends PolymerElement {

  ConfirmDialog.created() : super.created();


  DialogBase get ptr => $$('#dialog');

  @reflectable
  toggle() => ($$('#dialog') as DialogBase).toggle();
  show(header,message) => ($$('#dialog') as DialogBase).show(header,message);
  hide() => ($$('#dialog') as DialogBase).hide();
  updateText(header, message) => ($$('#dialog') as DialogBase).updateText(header, message);

  @reflectable
  onOk(var e, var d) => ($$('#dialog') as DialogBase).onTapOK(e);
}

@PolymerRegister('input-dialog')
class InputDialog extends PolymerElement {


  DialogBase get ptr => $$('#dialog');

  @property String value;

  InputDialog.created() : super.created();

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
  onOk(var e, var d) => ($$('#dialog') as DialogBase).onTapOK(e);
}