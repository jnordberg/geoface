
if (console == undefined)
  var console = {log: Function(), warn: Function(), error: Function()};

var App = require('./app.coffee').App;

function main() {
  window.app = new App();
};

window.addEvent('domready', main);
