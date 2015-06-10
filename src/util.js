'use strict';

const debug = require('debug');
const inspect = require('util').inspect;

// debug.log = function (input) {
//   console.log(inspect(input, { colors: true, showHidden: false, depth: null }));
// };

exports.logger = debug;
