'use strict';
const
  net = require('net'),
  client = net.connect({port: 8876});

client.on('data', function(data) {
  let message = JSON.parse(data);
  if (message.type === 'watching') {
    console.log("Now watching '" + message.file + "'");
  } else if (message.type === 'changed') {
    let date = new Date(message.timestamp);
    console.log("File '" + message.file + "' changed at '" + date);
  } else {
    console.log("Error: Unrecognized file '" + message.file + "'");
  }
});
