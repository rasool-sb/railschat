
var nameDefault    = 'Name';
var messageDefault = 'Please, input the message';
var multilineEffect;
Event.observe(window, 'load', init);

function init() {
  var name     = $('name');
  if(name) {
    var message  = $('chat_input');
    var multibar = $('multiline_bar');

    setMultilineEffect();
    focusNameOrMessage(name, message);

    Event.observe(name,        'focus',  clearValue);
    Event.observe(name,        'blur',   resetDefaultValue);
    Event.observe(message,     'focus',  clearValue);
    Event.observe(message,     'blur',   resetDefaultValue);
    Event.observe(multibar,    'click',  multilineToggle);
    Event.observe('chat_form', 'submit', sendMessage);
  }
  prettyPrint();
}

function setMultilineEffect() {
  multilineEffect = new fx.Height('extension', {duration: 350});
  multilineEffect.hide();
}

function multilineToggle() {
  multilineEffect.toggle();
}

function focusNameOrMessage(name, message) {
  if (name.value == nameDefault) {
    message.style.color = '#aaa';
    name.focus();
    name.select();
  } else {
    message.focus();
    message.select();
  }
}

function clearValue(e) {
  var target = Event.element(e);
  if (target.value == target.defaultValue) {
    target.style.color = '#333';
    target.value       = '';
  }
}

function resetDefaultValue(e) {
  var target = Event.element(e);
  if (target.value == '') {
    target.style.color = '#aaa';
    target.value       = target.defaultValue;
  } else if (target.value == target.defaultValue) {
    target.style.color = '#aaa';
  }
}

function sendMessage(e) {
  var name       = $('name');
  var message    = $('chat_input');
  var attachment = $('attachment');
  var submit     = $('submit');
  Event.stop(e);
  
  if (message.value == messageDefault) {
    message.value = '';
  }
  if ((name.value == nameDefault)||(name.value == '')) {
    name.select();
    return;
  }
  if (message.value == '' && attachment.value == '') {
    message.value = messageDefault;
    message.select();
    return;
  }

  new Ajax.Request('/chat/send_data', {
    parameters: Form.serialize(Event.element(e)),
    onLoading:  function(){ 
      message.toggleClassName('sending');
      message.value = attachment.value = '';
      submit.disable();
    },
    onComplete: function(){
      submit.enable();
      message.focus();
      message.toggleClassName('sending');
    }
  });
}
