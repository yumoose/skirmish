/******/ (function(modules) { // webpackBootstrap
/******/ 	// The module cache
/******/ 	var installedModules = {};
/******/
/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {
/******/
/******/ 		// Check if module is in cache
/******/ 		if(installedModules[moduleId]) {
/******/ 			return installedModules[moduleId].exports;
/******/ 		}
/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = installedModules[moduleId] = {
/******/ 			i: moduleId,
/******/ 			l: false,
/******/ 			exports: {}
/******/ 		};
/******/
/******/ 		// Execute the module function
/******/ 		modules[moduleId].call(module.exports, module, module.exports, __webpack_require__);
/******/
/******/ 		// Flag the module as loaded
/******/ 		module.l = true;
/******/
/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}
/******/
/******/
/******/ 	// expose the modules object (__webpack_modules__)
/******/ 	__webpack_require__.m = modules;
/******/
/******/ 	// expose the module cache
/******/ 	__webpack_require__.c = installedModules;
/******/
/******/ 	// define getter function for harmony exports
/******/ 	__webpack_require__.d = function(exports, name, getter) {
/******/ 		if(!__webpack_require__.o(exports, name)) {
/******/ 			Object.defineProperty(exports, name, {
/******/ 				configurable: false,
/******/ 				enumerable: true,
/******/ 				get: getter
/******/ 			});
/******/ 		}
/******/ 	};
/******/
/******/ 	// getDefaultExport function for compatibility with non-harmony modules
/******/ 	__webpack_require__.n = function(module) {
/******/ 		var getter = module && module.__esModule ?
/******/ 			function getDefault() { return module['default']; } :
/******/ 			function getModuleExports() { return module; };
/******/ 		__webpack_require__.d(getter, 'a', getter);
/******/ 		return getter;
/******/ 	};
/******/
/******/ 	// Object.prototype.hasOwnProperty.call
/******/ 	__webpack_require__.o = function(object, property) { return Object.prototype.hasOwnProperty.call(object, property); };
/******/
/******/ 	// __webpack_public_path__
/******/ 	__webpack_require__.p = "/dist";
/******/
/******/ 	// Load entry module and return exports
/******/ 	return __webpack_require__(__webpack_require__.s = 0);
/******/ })
/************************************************************************/
/******/ ([
/* 0 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


var _amber = __webpack_require__(1);

var _amber2 = _interopRequireDefault(_amber);

__webpack_require__(2);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

if (!Date.prototype.toGranite) {
  (function () {

    function pad(number) {
      if (number < 10) {
        return '0' + number;
      }
      return number;
    }

    Date.prototype.toGranite = function () {
      return this.getUTCFullYear() + '-' + pad(this.getUTCMonth() + 1) + '-' + pad(this.getUTCDate()) + ' ' + pad(this.getUTCHours()) + ':' + pad(this.getUTCMinutes()) + ':' + pad(this.getUTCSeconds());
    };
  })();
}

/***/ }),
/* 1 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


Object.defineProperty(exports, "__esModule", {
  value: true
});

var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

var EVENTS = {
  join: 'join',
  leave: 'leave',
  message: 'message'
};
var STALE_CONNECTION_THRESHOLD_SECONDS = 100;
var SOCKET_POLLING_RATE = 10000;

/**
 * Returns a numeric value for the current time
 */
var now = function now() {
  return new Date().getTime();
};

/**
 * Returns the difference between the current time and passed `time` in seconds
 * @param {Number|Date} time - A numeric time or date object
 */
var secondsSince = function secondsSince(time) {
  return (now() - time) / 1000;
};

/**
 * Class for channel related functions (joining, leaving, subscribing and sending messages)
 */

var Channel = exports.Channel = function () {
  /**
   * @param {String} topic - topic to subscribe to
   * @param {Socket} socket - A Socket instance
   */
  function Channel(topic, socket) {
    _classCallCheck(this, Channel);

    this.topic = topic;
    this.socket = socket;
    this.onMessageHandlers = [];
  }

  /**
   * Join a channel, subscribe to all channels messages
   */


  _createClass(Channel, [{
    key: 'join',
    value: function join() {
      this.socket.ws.send(JSON.stringify({ event: EVENTS.join, topic: this.topic }));
    }

    /**
     * Leave a channel, stop subscribing to channel messages
     */

  }, {
    key: 'leave',
    value: function leave() {
      this.socket.ws.send(JSON.stringify({ event: EVENTS.leave, topic: this.topic }));
    }

    /**
     * Calls all message handlers with a matching subject
     */

  }, {
    key: 'handleMessage',
    value: function handleMessage(msg) {
      this.onMessageHandlers.forEach(function (handler) {
        if (handler.subject === msg.subject) handler.callback(msg.payload);
      });
    }

    /**
     * Subscribe to a channel subject
     * @param {String} subject - subject to listen for: `msg:new`
     * @param {function} callback - callback function when a new message arrives
     */

  }, {
    key: 'on',
    value: function on(subject, callback) {
      this.onMessageHandlers.push({ subject: subject, callback: callback });
    }

    /**
     * Send a new message to the channel
     * @param {String} subject - subject to send message to: `msg:new`
     * @param {Object} payload - payload object: `{message: 'hello'}`
     */

  }, {
    key: 'push',
    value: function push(subject, payload) {
      this.socket.ws.send(JSON.stringify({ event: EVENTS.message, topic: this.topic, subject: subject, payload: payload }));
    }
  }]);

  return Channel;
}();

/**
 * Class for maintaining connection with server and maintaining channels list
 */


var Socket = exports.Socket = function () {
  /**
   * @param {String} endpoint - Websocket endpont used in routes.cr file
   */
  function Socket(endpoint) {
    _classCallCheck(this, Socket);

    this.endpoint = endpoint;
    this.ws = null;
    this.channels = [];
    this.lastPing = now();
    this.reconnectTries = 0;
    this.attemptReconnect = true;
  }

  /**
   * Returns whether or not the last received ping has been past the threshold
   */


  _createClass(Socket, [{
    key: '_connectionIsStale',
    value: function _connectionIsStale() {
      return secondsSince(this.lastPing) > STALE_CONNECTION_THRESHOLD_SECONDS;
    }

    /**
     * Tries to reconnect to the websocket server using a recursive timeout
     */

  }, {
    key: '_reconnect',
    value: function _reconnect() {
      var _this = this;

      clearTimeout(this.reconnectTimeout);
      this.reconnectTimeout = setTimeout(function () {
        _this.reconnectTries++;
        _this.connect(_this.params);
        _this._reconnect();
      }, this._reconnectInterval());
    }

    /**
     * Returns an incrementing timeout interval based around the number of reconnection retries
     */

  }, {
    key: '_reconnectInterval',
    value: function _reconnectInterval() {
      return [1000, 2000, 5000, 10000][this.reconnectTries] || 10000;
    }

    /**
     * Sets a recursive timeout to check if the connection is stale
     */

  }, {
    key: '_poll',
    value: function _poll() {
      var _this2 = this;

      this.pollingTimeout = setTimeout(function () {
        if (_this2._connectionIsStale()) {
          _this2._reconnect();
        } else {
          _this2._poll();
        }
      }, SOCKET_POLLING_RATE);
    }

    /**
     * Clear polling timeout and start polling
     */

  }, {
    key: '_startPolling',
    value: function _startPolling() {
      clearTimeout(this.pollingTimeout);
      this._poll();
    }

    /**
     * Sets `lastPing` to the curent time
     */

  }, {
    key: '_handlePing',
    value: function _handlePing() {
      this.lastPing = now();
    }

    /**
     * Clears reconnect timeout, resets variables an starts polling
     */

  }, {
    key: '_reset',
    value: function _reset() {
      clearTimeout(this.reconnectTimeout);
      this.reconnectTries = 0;
      this.attemptReconnect = true;
      this._startPolling();
    }

    /**
     * Connect the socket to the server, and binds to native ws functions
     * @param {Object} params - Optional parameters
     * @param {String} params.location - Hostname to connect to, defaults to `window.location.hostname`
     * @param {String} parmas.port - Port to connect to, defaults to `window.location.port`
     * @param {String} params.protocol - Protocol to use, either 'wss' or 'ws'
     */

  }, {
    key: 'connect',
    value: function connect(params) {
      var _this3 = this;

      this.params = params;

      var opts = {
        location: window.location.hostname,
        port: window.location.port,
        protocol: window.location.protocol === 'https:' ? 'wss:' : 'ws:'
      };

      if (params) Object.assign(opts, params);
      if (opts.port) opts.location += ':' + opts.port;

      return new Promise(function (resolve, reject) {
        _this3.ws = new WebSocket(opts.protocol + '//' + opts.location + _this3.endpoint);
        _this3.ws.onmessage = function (msg) {
          _this3.handleMessage(msg);
        };
        _this3.ws.onclose = function () {
          if (_this3.attemptReconnect) _this3._reconnect();
        };
        _this3.ws.onopen = function () {
          _this3._reset();
          resolve();
        };
      });
    }

    /**
     * Closes the socket connection permanently
     */

  }, {
    key: 'disconnect',
    value: function disconnect() {
      this.attemptReconnect = false;
      clearTimeout(this.pollingTimeout);
      clearTimeout(this.reconnectTimeout);
      this.ws.close();
    }

    /**
     * Adds a new channel to the socket channels list
     * @param {String} topic - Topic for the channel: `chat_room:123`
     */

  }, {
    key: 'channel',
    value: function channel(topic) {
      var channel = new Channel(topic, this);
      this.channels.push(channel);
      return channel;
    }

    /**
     * Message handler for messages received
     * @param {MessageEvent} msg - Message received from ws
     */

  }, {
    key: 'handleMessage',
    value: function handleMessage(msg) {
      if (msg.data === "ping") return this._handlePing();

      var parsed_msg = JSON.parse(msg.data);
      this.channels.forEach(function (channel) {
        if (channel.topic === parsed_msg.topic) channel.handleMessage(parsed_msg);
      });
    }
  }]);

  return Socket;
}();

module.exports = {
  Socket: Socket

  /**
   * Allows delete links to post for security and ease of use similar to Rails jquery_ujs
   */
};document.addEventListener("DOMContentLoaded", function () {
  document.querySelectorAll("a[data-method='delete']").forEach(function (element) {
    element.addEventListener("click", function (e) {
      e.preventDefault();
      var message = element.getAttribute("data-confirm") || "Are you sure?";
      if (confirm(message)) {
        var form = document.createElement("form");
        var input = document.createElement("input");
        form.setAttribute("action", element.getAttribute("href"));
        form.setAttribute("method", "POST");
        input.setAttribute("type", "hidden");
        input.setAttribute("name", "_method");
        input.setAttribute("value", "DELETE");
        form.appendChild(input);
        document.body.appendChild(form);
        form.submit();
      }
      return false;
    });
  });
});

/***/ }),
/* 2 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


if (document.getElementById('simple-logger')) {
  var statusField = document.getElementById('status');
  var statusDropdown = document.getElementById('status-dropdown');
  var statusDropdownOptions = document.getElementById('status-dropdown-options');

  Array.from(statusDropdownOptions.children).forEach(function (dropdownItem) {
    dropdownItem.addEventListener('click', function (e) {
      var item = e.target;
      var newStatus = item.getAttribute('data-status').trim();
      var newStatusTitle = item.innerText.trim();

      item.innerText = statusDropdown.innerText.trim();
      item.setAttribute('data-status', statusField.getAttribute('content').trim());

      statusDropdown.innerText = newStatusTitle;
      statusField.setAttribute('content', newStatus);
    });
  });

  var playerField = document.getElementById('other-player-id');
  var playerDropdown = document.getElementById('player-dropdown');
  var playerDropdownOptions = document.getElementById('player-dropdown-options');

  Array.from(playerDropdownOptions.children).forEach(function (dropdownItem) {
    dropdownItem.addEventListener('click', function (e) {
      var item = e.target;
      var newPlayerId = item.getAttribute('data-player-id').trim();
      var newPlayerName = item.innerText.trim();

      item.innerText = playerDropdown.innerText.trim();
      item.setAttribute('data-player-id', playerField.getAttribute('content').trim());

      playerDropdown.innerText = newPlayerName;
      playerField.setAttribute('content', newPlayerId);
    });
  });
}

/***/ })
/******/ ]);
//# sourceMappingURL=data:application/json;charset=utf-8;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbIndlYnBhY2s6Ly8vd2VicGFjay9ib290c3RyYXAgYjk3MDExZWJiNmYxM2RlYTA0MmUiLCJ3ZWJwYWNrOi8vLy4vc3JjL2Fzc2V0cy9qYXZhc2NyaXB0cy9tYWluLmpzIiwid2VicGFjazovLy8uL2xpYi9hbWJlci9hc3NldHMvanMvYW1iZXIuanMiLCJ3ZWJwYWNrOi8vLy4vc3JjL2Fzc2V0cy9qYXZhc2NyaXB0cy9nYW1lLmpzIl0sIm5hbWVzIjpbIkRhdGUiLCJwcm90b3R5cGUiLCJ0b0dyYW5pdGUiLCJwYWQiLCJudW1iZXIiLCJnZXRVVENGdWxsWWVhciIsImdldFVUQ01vbnRoIiwiZ2V0VVRDRGF0ZSIsImdldFVUQ0hvdXJzIiwiZ2V0VVRDTWludXRlcyIsImdldFVUQ1NlY29uZHMiLCJFVkVOVFMiLCJqb2luIiwibGVhdmUiLCJtZXNzYWdlIiwiU1RBTEVfQ09OTkVDVElPTl9USFJFU0hPTERfU0VDT05EUyIsIlNPQ0tFVF9QT0xMSU5HX1JBVEUiLCJub3ciLCJnZXRUaW1lIiwic2Vjb25kc1NpbmNlIiwidGltZSIsIkNoYW5uZWwiLCJ0b3BpYyIsInNvY2tldCIsIm9uTWVzc2FnZUhhbmRsZXJzIiwid3MiLCJzZW5kIiwiSlNPTiIsInN0cmluZ2lmeSIsImV2ZW50IiwibXNnIiwiZm9yRWFjaCIsImhhbmRsZXIiLCJzdWJqZWN0IiwiY2FsbGJhY2siLCJwYXlsb2FkIiwicHVzaCIsIlNvY2tldCIsImVuZHBvaW50IiwiY2hhbm5lbHMiLCJsYXN0UGluZyIsInJlY29ubmVjdFRyaWVzIiwiYXR0ZW1wdFJlY29ubmVjdCIsImNsZWFyVGltZW91dCIsInJlY29ubmVjdFRpbWVvdXQiLCJzZXRUaW1lb3V0IiwiY29ubmVjdCIsInBhcmFtcyIsIl9yZWNvbm5lY3QiLCJfcmVjb25uZWN0SW50ZXJ2YWwiLCJwb2xsaW5nVGltZW91dCIsIl9jb25uZWN0aW9uSXNTdGFsZSIsIl9wb2xsIiwiX3N0YXJ0UG9sbGluZyIsIm9wdHMiLCJsb2NhdGlvbiIsIndpbmRvdyIsImhvc3RuYW1lIiwicG9ydCIsInByb3RvY29sIiwiT2JqZWN0IiwiYXNzaWduIiwiUHJvbWlzZSIsInJlc29sdmUiLCJyZWplY3QiLCJXZWJTb2NrZXQiLCJvbm1lc3NhZ2UiLCJoYW5kbGVNZXNzYWdlIiwib25jbG9zZSIsIm9ub3BlbiIsIl9yZXNldCIsImNsb3NlIiwiY2hhbm5lbCIsImRhdGEiLCJfaGFuZGxlUGluZyIsInBhcnNlZF9tc2ciLCJwYXJzZSIsIm1vZHVsZSIsImV4cG9ydHMiLCJkb2N1bWVudCIsImFkZEV2ZW50TGlzdGVuZXIiLCJxdWVyeVNlbGVjdG9yQWxsIiwiZWxlbWVudCIsImUiLCJwcmV2ZW50RGVmYXVsdCIsImdldEF0dHJpYnV0ZSIsImNvbmZpcm0iLCJmb3JtIiwiY3JlYXRlRWxlbWVudCIsImlucHV0Iiwic2V0QXR0cmlidXRlIiwiYXBwZW5kQ2hpbGQiLCJib2R5Iiwic3VibWl0IiwiZ2V0RWxlbWVudEJ5SWQiLCJzdGF0dXNGaWVsZCIsInN0YXR1c0Ryb3Bkb3duIiwic3RhdHVzRHJvcGRvd25PcHRpb25zIiwiQXJyYXkiLCJmcm9tIiwiY2hpbGRyZW4iLCJkcm9wZG93bkl0ZW0iLCJpdGVtIiwidGFyZ2V0IiwibmV3U3RhdHVzIiwidHJpbSIsIm5ld1N0YXR1c1RpdGxlIiwiaW5uZXJUZXh0IiwicGxheWVyRmllbGQiLCJwbGF5ZXJEcm9wZG93biIsInBsYXllckRyb3Bkb3duT3B0aW9ucyIsIm5ld1BsYXllcklkIiwibmV3UGxheWVyTmFtZSJdLCJtYXBwaW5ncyI6IjtBQUFBO0FBQ0E7O0FBRUE7QUFDQTs7QUFFQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTs7QUFFQTtBQUNBOztBQUVBO0FBQ0E7O0FBRUE7QUFDQTtBQUNBOzs7QUFHQTtBQUNBOztBQUVBO0FBQ0E7O0FBRUE7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQSxhQUFLO0FBQ0w7QUFDQTs7QUFFQTtBQUNBO0FBQ0E7QUFDQSxtQ0FB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LFNBQWYsR0FBMkJLLGFBQTNCO0FBQ0FKLGtCQUFZbEIsWUFBWixDQUF5QixTQUF6QixFQUFvQ3FCLFdBQXBDO0FBQ0QsS0FWRDtBQVdELEdBWkQ7QUFhRCxDIiwiZmlsZSI6Im1haW4uYnVuZGxlLmpzIiwic291cmNlc0NvbnRlbnQiOlsiIFx0Ly8gVGhlIG1vZHVsZSBjYWNoZVxuIFx0dmFyIGluc3RhbGxlZE1vZHVsZXMgPSB7fTtcblxuIFx0Ly8gVGhlIHJlcXVpcmUgZnVuY3Rpb25cbiBcdGZ1bmN0aW9uIF9fd2VicGFja19yZXF1aXJlX18obW9kdWxlSWQpIHtcblxuIFx0XHQvLyBDaGVjayBpZiBtb2R1bGUgaXMgaW4gY2FjaGVcbiBcdFx0aWYoaW5zdGFsbGVkTW9kdWxlc1ttb2R1bGVJZF0pIHtcbiBcdFx0XHRyZXR1cm4gaW5zdGFsbGVkTW9kdWxlc1ttb2R1bGVJZF0uZXhwb3J0cztcbiBcdFx0fVxuIFx0XHQvLyBDcmVhdGUgYSBuZXcgbW9kdWxlIChhbmQgcHV0IGl0IGludG8gdGhlIGNhY2hlKVxuIFx0XHR2YXIgbW9kdWxlID0gaW5zdGFsbGVkTW9kdWxlc1ttb2R1bGVJZF0gPSB7XG4gXHRcdFx0aTogbW9kdWxlSWQsXG4gXHRcdFx0bDogZmFsc2UsXG4gXHRcdFx0ZXhwb3J0czoge31cbiBcdFx0fTtcblxuIFx0XHQvLyBFeGVjdXRlIHRoZSBtb2R1bGUgZnVuY3Rpb25cbiBcdFx0bW9kdWxlc1ttb2R1bGVJZF0uY2FsbChtb2R1bGUuZXhwb3J0cywgbW9kdWxlLCBtb2R1bGUuZXhwb3J0cywgX193ZWJwYWNrX3JlcXVpcmVfXyk7XG5cbiBcdFx0Ly8gRmxhZyB0aGUgbW9kdWxlIGFzIGxvYWRlZFxuIFx0XHRtb2R1bGUubCA9IHRydWU7XG5cbiBcdFx0Ly8gUmV0dXJuIHRoZSBleHBvcnRzIG9mIHRoZSBtb2R1bGVcbiBcdFx0cmV0dXJuIG1vZHVsZS5leHBvcnRzO1xuIFx0fVxuXG5cbiBcdC8vIGV4cG9zZSB0aGUgbW9kdWxlcyBvYmplY3QgKF9fd2VicGFja19tb2R1bGVzX18pXG4gXHRfX3dlYnBhY2tfcmVxdWlyZV9fLm0gPSBtb2R1bGVzO1xuXG4gXHQvLyBleHBvc2UgdGhlIG1vZHVsZSBjYWNoZVxuIFx0X193ZWJwYWNrX3JlcXVpcmVfXy5jID0gaW5zdGFsbGVkTW9kdWxlcztcblxuIFx0Ly8gZGVmaW5lIGdldHRlciBmdW5jdGlvbiBmb3IgaGFybW9ueSBleHBvcnRzXG4gXHRfX3dlYnBhY2tfcmVxdWlyZV9fLmQgPSBmdW5jdGlvbihleHBvcnRzLCBuYW1lLCBnZXR0ZXIpIHtcbiBcdFx0aWYoIV9fd2VicGFja19yZXF1aXJlX18ubyhleHBvcnRzLCBuYW1lKSkge1xuIFx0XHRcdE9iamVjdC5kZWZpbmVQcm9wZXJ0eShleHBvcnRzLCBuYW1lLCB7XG4gXHRcdFx0XHRjb25maWd1cmFibGU6IGZhbHNlLFxuIFx0XHRcdFx0ZW51bWVyYWJsZTogdHJ1ZSxcbiBcdFx0XHRcdGdldDogZ2V0dGVyXG4gXHRcdFx0fSk7XG4gXHRcdH1cbiBcdH07XG5cbiBcdC8vIGdldERlZmF1bHRFeHBvcnQgZnVuY3Rpb24gZm9yIGNvbXBhdGliaWxpdHkgd2l0aCBub24taGFybW9ueSBtb2R1bGVzXG4gXHRfX3dlYnBhY2tfcmVxdWlyZV9fLm4gPSBmdW5jdGlvbihtb2R1bGUpIHtcbiBcdFx0dmFyIGdldHRlciA9IG1vZHVsZSAmJiBtb2R1bGUuX19lc01vZHVsZSA/XG4gXHRcdFx0ZnVuY3Rpb24gZ2V0RGVmYXVsdCgpIHsgcmV0dXJuIG1vZHVsZVsnZGVmYXVsdCddOyB9IDpcbiBcdFx0XHRmdW5jdGlvbiBnZXRNb2R1bGVFeHBvcnRzKCkgeyByZXR1cm4gbW9kdWxlOyB9O1xuIFx0XHRfX3dlYnBhY2tfcmVxdWlyZV9fLmQoZ2V0dGVyLCAnYScsIGdldHRlcik7XG4gXHRcdHJldHVybiBnZXR0ZXI7XG4gXHR9O1xuXG4gXHQvLyBPYmplY3QucHJvdG90eXBlLmhhc093blByb3BlcnR5LmNhbGxcbiBcdF9fd2VicGFja19yZXF1aXJlX18ubyA9IGZ1bmN0aW9uKG9iamVjdCwgcHJvcGVydHkpIHsgcmV0dXJuIE9iamVjdC5wcm90b3R5cGUuaGFzT3duUHJvcGVydHkuY2FsbChvYmplY3QsIHByb3BlcnR5KTsgfTtcblxuIFx0Ly8gX193ZWJwYWNrX3B1YmxpY19wYXRoX19cbiBcdF9fd2VicGFja19yZXF1aXJlX18ucCA9IFwiL2Rpc3RcIjtcblxuIFx0Ly8gTG9hZCBlbnRyeSBtb2R1bGUgYW5kIHJldHVybiBleHBvcnRzXG4gXHRyZXR1cm4gX193ZWJwYWNrX3JlcXVpcmVfXyhfX3dlYnBhY2tfcmVxdWlyZV9fLnMgPSAwKTtcblxuXG5cbi8vIFdFQlBBQ0sgRk9PVEVSIC8vXG4vLyB3ZWJwYWNrL2Jvb3RzdHJhcCBiOTcwMTFlYmI2ZjEzZGVhMDQyZSIsImltcG9ydCBBbWJlciBmcm9tICdhbWJlcidcblxuaW1wb3J0IFwiLi9nYW1lLmpzXCJcblxuaWYgKCFEYXRlLnByb3RvdHlwZS50b0dyYW5pdGUpIHtcbiAgKGZ1bmN0aW9uKCkge1xuXG4gICAgZnVuY3Rpb24gcGFkKG51bWJlcikge1xuICAgICAgaWYgKG51bWJlciA8IDEwKSB7XG4gICAgICAgIHJldHVybiAnMCcgKyBudW1iZXI7XG4gICAgICB9XG4gICAgICByZXR1cm4gbnVtYmVyO1xuICAgIH1cblxuICAgIERhdGUucHJvdG90eXBlLnRvR3Jhbml0ZSA9IGZ1bmN0aW9uKCkge1xuICAgICAgcmV0dXJuIHRoaXMuZ2V0VVRDRnVsbFllYXIoKSArXG4gICAgICAgICctJyArIHBhZCh0aGlzLmdldFVUQ01vbnRoKCkgKyAxKSArXG4gICAgICAgICctJyArIHBhZCh0aGlzLmdldFVUQ0RhdGUoKSkgK1xuICAgICAgICAnICcgKyBwYWQodGhpcy5nZXRVVENIb3VycygpKSArXG4gICAgICAgICc6JyArIHBhZCh0aGlzLmdldFVUQ01pbnV0ZXMoKSkgK1xuICAgICAgICAnOicgKyBwYWQodGhpcy5nZXRVVENTZWNvbmRzKCkpICA7XG4gICAgfTtcblxuICB9KCkpO1xufVxuXG5cblxuLy8gV0VCUEFDSyBGT09URVIgLy9cbi8vIC4vc3JjL2Fzc2V0cy9qYXZhc2NyaXB0cy9tYWluLmpzIiwiY29uc3QgRVZFTlRTID0ge1xuICBqb2luOiAnam9pbicsXG4gIGxlYXZlOiAnbGVhdmUnLFxuICBtZXNzYWdlOiAnbWVzc2FnZSdcbn1cbmNvbnN0IFNUQUxFX0NPTk5FQ1RJT05fVEhSRVNIT0xEX1NFQ09ORFMgPSAxMDBcbmNvbnN0IFNPQ0tFVF9QT0xMSU5HX1JBVEUgPSAxMDAwMFxuXG4vKipcbiAqIFJldHVybnMgYSBudW1lcmljIHZhbHVlIGZvciB0aGUgY3VycmVudCB0aW1lXG4gKi9cbmxldCBub3cgPSAoKSA9PiB7XG4gIHJldHVybiBuZXcgRGF0ZSgpLmdldFRpbWUoKVxufVxuXG4vKipcbiAqIFJldHVybnMgdGhlIGRpZmZlcmVuY2UgYmV0d2VlbiB0aGUgY3VycmVudCB0aW1lIGFuZCBwYXNzZWQgYHRpbWVgIGluIHNlY29uZHNcbiAqIEBwYXJhbSB7TnVtYmVyfERhdGV9IHRpbWUgLSBBIG51bWVyaWMgdGltZSBvciBkYXRlIG9iamVjdFxuICovXG5sZXQgc2Vjb25kc1NpbmNlID0gKHRpbWUpID0+IHtcbiAgcmV0dXJuIChub3coKSAtIHRpbWUpIC8gMTAwMFxufVxuXG4vKipcbiAqIENsYXNzIGZvciBjaGFubmVsIHJlbGF0ZWQgZnVuY3Rpb25zIChqb2luaW5nLCBsZWF2aW5nLCBzdWJzY3JpYmluZyBhbmQgc2VuZGluZyBtZXNzYWdlcylcbiAqL1xuZXhwb3J0IGNsYXNzIENoYW5uZWwge1xuICAvKipcbiAgICogQHBhcmFtIHtTdHJpbmd9IHRvcGljIC0gdG9waWMgdG8gc3Vic2NyaWJlIHRvXG4gICAqIEBwYXJhbSB7U29ja2V0fSBzb2NrZXQgLSBBIFNvY2tldCBpbnN0YW5jZVxuICAgKi9cbiAgY29uc3RydWN0b3IodG9waWMsIHNvY2tldCkge1xuICAgIHRoaXMudG9waWMgPSB0b3BpY1xuICAgIHRoaXMuc29ja2V0ID0gc29ja2V0XG4gICAgdGhpcy5vbk1lc3NhZ2VIYW5kbGVycyA9IFtdXG4gIH1cblxuICAvKipcbiAgICogSm9pbiBhIGNoYW5uZWwsIHN1YnNjcmliZSB0byBhbGwgY2hhbm5lbHMgbWVzc2FnZXNcbiAgICovXG4gIGpvaW4oKSB7XG4gICAgdGhpcy5zb2NrZXQud3Muc2VuZChKU09OLnN0cmluZ2lmeSh7IGV2ZW50OiBFVkVOVFMuam9pbiwgdG9waWM6IHRoaXMudG9waWMgfSkpXG4gIH1cblxuICAvKipcbiAgICogTGVhdmUgYSBjaGFubmVsLCBzdG9wIHN1YnNjcmliaW5nIHRvIGNoYW5uZWwgbWVzc2FnZXNcbiAgICovXG4gIGxlYXZlKCkge1xuICAgIHRoaXMuc29ja2V0LndzLnNlbmQoSlNPTi5zdHJpbmdpZnkoeyBldmVudDogRVZFTlRTLmxlYXZlLCB0b3BpYzogdGhpcy50b3BpYyB9KSlcbiAgfVxuXG4gIC8qKlxuICAgKiBDYWxscyBhbGwgbWVzc2FnZSBoYW5kbGVycyB3aXRoIGEgbWF0Y2hpbmcgc3ViamVjdFxuICAgKi9cbiAgaGFuZGxlTWVzc2FnZShtc2cpIHtcbiAgICB0aGlzLm9uTWVzc2FnZUhhbmRsZXJzLmZvckVhY2goKGhhbmRsZXIpID0+IHtcbiAgICAgIGlmIChoYW5kbGVyLnN1YmplY3QgPT09IG1zZy5zdWJqZWN0KSBoYW5kbGVyLmNhbGxiYWNrKG1zZy5wYXlsb2FkKVxuICAgIH0pXG4gIH1cblxuICAvKipcbiAgICogU3Vic2NyaWJlIHRvIGEgY2hhbm5lbCBzdWJqZWN0XG4gICAqIEBwYXJhbSB7U3RyaW5nfSBzdWJqZWN0IC0gc3ViamVjdCB0byBsaXN0ZW4gZm9yOiBgbXNnOm5ld2BcbiAgICogQHBhcmFtIHtmdW5jdGlvbn0gY2FsbGJhY2sgLSBjYWxsYmFjayBmdW5jdGlvbiB3aGVuIGEgbmV3IG1lc3NhZ2UgYXJyaXZlc1xuICAgKi9cbiAgb24oc3ViamVjdCwgY2FsbGJhY2spIHtcbiAgICB0aGlzLm9uTWVzc2FnZUhhbmRsZXJzLnB1c2goeyBzdWJqZWN0OiBzdWJqZWN0LCBjYWxsYmFjazogY2FsbGJhY2sgfSlcbiAgfVxuXG4gIC8qKlxuICAgKiBTZW5kIGEgbmV3IG1lc3NhZ2UgdG8gdGhlIGNoYW5uZWxcbiAgICogQHBhcmFtIHtTdHJpbmd9IHN1YmplY3QgLSBzdWJqZWN0IHRvIHNlbmQgbWVzc2FnZSB0bzogYG1zZzpuZXdgXG4gICAqIEBwYXJhbSB7T2JqZWN0fSBwYXlsb2FkIC0gcGF5bG9hZCBvYmplY3Q6IGB7bWVzc2FnZTogJ2hlbGxvJ31gXG4gICAqL1xuICBwdXNoKHN1YmplY3QsIHBheWxvYWQpIHtcbiAgICB0aGlzLnNvY2tldC53cy5zZW5kKEpTT04uc3RyaW5naWZ5KHsgZXZlbnQ6IEVWRU5UUy5tZXNzYWdlLCB0b3BpYzogdGhpcy50b3BpYywgc3ViamVjdDogc3ViamVjdCwgcGF5bG9hZDogcGF5bG9hZCB9KSlcbiAgfVxufVxuXG4vKipcbiAqIENsYXNzIGZvciBtYWludGFpbmluZyBjb25uZWN0aW9uIHdpdGggc2VydmVyIGFuZCBtYWludGFpbmluZyBjaGFubmVscyBsaXN0XG4gKi9cbmV4cG9ydCBjbGFzcyBTb2NrZXQge1xuICAvKipcbiAgICogQHBhcmFtIHtTdHJpbmd9IGVuZHBvaW50IC0gV2Vic29ja2V0IGVuZHBvbnQgdXNlZCBpbiByb3V0ZXMuY3IgZmlsZVxuICAgKi9cbiAgY29uc3RydWN0b3IoZW5kcG9pbnQpIHtcbiAgICB0aGlzLmVuZHBvaW50ID0gZW5kcG9pbnRcbiAgICB0aGlzLndzID0gbnVsbFxuICAgIHRoaXMuY2hhbm5lbHMgPSBbXVxuICAgIHRoaXMubGFzdFBpbmcgPSBub3coKVxuICAgIHRoaXMucmVjb25uZWN0VHJpZXMgPSAwXG4gICAgdGhpcy5hdHRlbXB0UmVjb25uZWN0ID0gdHJ1ZVxuICB9XG5cbiAgLyoqXG4gICAqIFJldHVybnMgd2hldGhlciBvciBub3QgdGhlIGxhc3QgcmVjZWl2ZWQgcGluZyBoYXMgYmVlbiBwYXN0IHRoZSB0aHJlc2hvbGRcbiAgICovXG4gIF9jb25uZWN0aW9uSXNTdGFsZSgpIHtcbiAgICByZXR1cm4gc2Vjb25kc1NpbmNlKHRoaXMubGFzdFBpbmcpID4gU1RBTEVfQ09OTkVDVElPTl9USFJFU0hPTERfU0VDT05EU1xuICB9XG5cbiAgLyoqXG4gICAqIFRyaWVzIHRvIHJlY29ubmVjdCB0byB0aGUgd2Vic29ja2V0IHNlcnZlciB1c2luZyBhIHJlY3Vyc2l2ZSB0aW1lb3V0XG4gICAqL1xuICBfcmVjb25uZWN0KCkge1xuICAgIGNsZWFyVGltZW91dCh0aGlzLnJlY29ubmVjdFRpbWVvdXQpXG4gICAgdGhpcy5yZWNvbm5lY3RUaW1lb3V0ID0gc2V0VGltZW91dCgoKSA9PiB7XG4gICAgICB0aGlzLnJlY29ubmVjdFRyaWVzKytcbiAgICAgIHRoaXMuY29ubmVjdCh0aGlzLnBhcmFtcylcbiAgICAgIHRoaXMuX3JlY29ubmVjdCgpXG4gICAgfSwgdGhpcy5fcmVjb25uZWN0SW50ZXJ2YWwoKSlcbiAgfVxuXG4gIC8qKlxuICAgKiBSZXR1cm5zIGFuIGluY3JlbWVudGluZyB0aW1lb3V0IGludGVydmFsIGJhc2VkIGFyb3VuZCB0aGUgbnVtYmVyIG9mIHJlY29ubmVjdGlvbiByZXRyaWVzXG4gICAqL1xuICBfcmVjb25uZWN0SW50ZXJ2YWwoKSB7XG4gICAgcmV0dXJuIFsxMDAwLCAyMDAwLCA1MDAwLCAxMDAwMF1bdGhpcy5yZWNvbm5lY3RUcmllc10gfHwgMTAwMDBcbiAgfVxuXG4gIC8qKlxuICAgKiBTZXRzIGEgcmVjdXJzaXZlIHRpbWVvdXQgdG8gY2hlY2sgaWYgdGhlIGNvbm5lY3Rpb24gaXMgc3RhbGVcbiAgICovXG4gIF9wb2xsKCkge1xuICAgIHRoaXMucG9sbGluZ1RpbWVvdXQgPSBzZXRUaW1lb3V0KCgpID0+IHtcbiAgICAgIGlmICh0aGlzLl9jb25uZWN0aW9uSXNTdGFsZSgpKSB7XG4gICAgICAgIHRoaXMuX3JlY29ubmVjdCgpXG4gICAgICB9IGVsc2Uge1xuICAgICAgICB0aGlzLl9wb2xsKClcbiAgICAgIH1cbiAgICB9LCBTT0NLRVRfUE9MTElOR19SQVRFKVxuICB9XG5cbiAgLyoqXG4gICAqIENsZWFyIHBvbGxpbmcgdGltZW91dCBhbmQgc3RhcnQgcG9sbGluZ1xuICAgKi9cbiAgX3N0YXJ0UG9sbGluZygpIHtcbiAgICBjbGVhclRpbWVvdXQodGhpcy5wb2xsaW5nVGltZW91dClcbiAgICB0aGlzLl9wb2xsKClcbiAgfVxuXG4gIC8qKlxuICAgKiBTZXRzIGBsYXN0UGluZ2AgdG8gdGhlIGN1cmVudCB0aW1lXG4gICAqL1xuICBfaGFuZGxlUGluZygpIHtcbiAgICB0aGlzLmxhc3RQaW5nID0gbm93KClcbiAgfVxuXG4gIC8qKlxuICAgKiBDbGVhcnMgcmVjb25uZWN0IHRpbWVvdXQsIHJlc2V0cyB2YXJpYWJsZXMgYW4gc3RhcnRzIHBvbGxpbmdcbiAgICovXG4gIF9yZXNldCgpIHtcbiAgICBjbGVhclRpbWVvdXQodGhpcy5yZWNvbm5lY3RUaW1lb3V0KVxuICAgIHRoaXMucmVjb25uZWN0VHJpZXMgPSAwXG4gICAgdGhpcy5hdHRlbXB0UmVjb25uZWN0ID0gdHJ1ZVxuICAgIHRoaXMuX3N0YXJ0UG9sbGluZygpXG4gIH1cblxuICAvKipcbiAgICogQ29ubmVjdCB0aGUgc29ja2V0IHRvIHRoZSBzZXJ2ZXIsIGFuZCBiaW5kcyB0byBuYXRpdmUgd3MgZnVuY3Rpb25zXG4gICAqIEBwYXJhbSB7T2JqZWN0fSBwYXJhbXMgLSBPcHRpb25hbCBwYXJhbWV0ZXJzXG4gICAqIEBwYXJhbSB7U3RyaW5nfSBwYXJhbXMubG9jYXRpb24gLSBIb3N0bmFtZSB0byBjb25uZWN0IHRvLCBkZWZhdWx0cyB0byBgd2luZG93LmxvY2F0aW9uLmhvc3RuYW1lYFxuICAgKiBAcGFyYW0ge1N0cmluZ30gcGFybWFzLnBvcnQgLSBQb3J0IHRvIGNvbm5lY3QgdG8sIGRlZmF1bHRzIHRvIGB3aW5kb3cubG9jYXRpb24ucG9ydGBcbiAgICogQHBhcmFtIHtTdHJpbmd9IHBhcmFtcy5wcm90b2NvbCAtIFByb3RvY29sIHRvIHVzZSwgZWl0aGVyICd3c3MnIG9yICd3cydcbiAgICovXG4gIGNvbm5lY3QocGFyYW1zKSB7XG4gICAgdGhpcy5wYXJhbXMgPSBwYXJhbXNcblxuICAgIGxldCBvcHRzID0ge1xuICAgICAgbG9jYXRpb246IHdpbmRvdy5sb2NhdGlvbi5ob3N0bmFtZSxcbiAgICAgIHBvcnQ6IHdpbmRvdy5sb2NhdGlvbi5wb3J0LFxuICAgICAgcHJvdG9jb2w6IHdpbmRvdy5sb2NhdGlvbi5wcm90b2NvbCA9PT0gJ2h0dHBzOicgPyAnd3NzOicgOiAnd3M6JyxcbiAgICB9XG5cbiAgICBpZiAocGFyYW1zKSBPYmplY3QuYXNzaWduKG9wdHMsIHBhcmFtcylcbiAgICBpZiAob3B0cy5wb3J0KSBvcHRzLmxvY2F0aW9uICs9IGA6JHtvcHRzLnBvcnR9YFxuXG4gICAgcmV0dXJuIG5ldyBQcm9taXNlKChyZXNvbHZlLCByZWplY3QpID0+IHtcbiAgICAgIHRoaXMud3MgPSBuZXcgV2ViU29ja2V0KGAke29wdHMucHJvdG9jb2x9Ly8ke29wdHMubG9jYXRpb259JHt0aGlzLmVuZHBvaW50fWApXG4gICAgICB0aGlzLndzLm9ubWVzc2FnZSA9IChtc2cpID0+IHsgdGhpcy5oYW5kbGVNZXNzYWdlKG1zZykgfVxuICAgICAgdGhpcy53cy5vbmNsb3NlID0gKCkgPT4ge1xuICAgICAgICBpZiAodGhpcy5hdHRlbXB0UmVjb25uZWN0KSB0aGlzLl9yZWNvbm5lY3QoKVxuICAgICAgfVxuICAgICAgdGhpcy53cy5vbm9wZW4gPSAoKSA9PiB7XG4gICAgICAgIHRoaXMuX3Jlc2V0KClcbiAgICAgICAgcmVzb2x2ZSgpXG4gICAgICB9XG4gICAgfSlcbiAgfVxuXG4gIC8qKlxuICAgKiBDbG9zZXMgdGhlIHNvY2tldCBjb25uZWN0aW9uIHBlcm1hbmVudGx5XG4gICAqL1xuICBkaXNjb25uZWN0KCkge1xuICAgIHRoaXMuYXR0ZW1wdFJlY29ubmVjdCA9IGZhbHNlXG4gICAgY2xlYXJUaW1lb3V0KHRoaXMucG9sbGluZ1RpbWVvdXQpXG4gICAgY2xlYXJUaW1lb3V0KHRoaXMucmVjb25uZWN0VGltZW91dClcbiAgICB0aGlzLndzLmNsb3NlKClcbiAgfVxuXG4gIC8qKlxuICAgKiBBZGRzIGEgbmV3IGNoYW5uZWwgdG8gdGhlIHNvY2tldCBjaGFubmVscyBsaXN0XG4gICAqIEBwYXJhbSB7U3RyaW5nfSB0b3BpYyAtIFRvcGljIGZvciB0aGUgY2hhbm5lbDogYGNoYXRfcm9vbToxMjNgXG4gICAqL1xuICBjaGFubmVsKHRvcGljKSB7XG4gICAgbGV0IGNoYW5uZWwgPSBuZXcgQ2hhbm5lbCh0b3BpYywgdGhpcylcbiAgICB0aGlzLmNoYW5uZWxzLnB1c2goY2hhbm5lbClcbiAgICByZXR1cm4gY2hhbm5lbFxuICB9XG5cbiAgLyoqXG4gICAqIE1lc3NhZ2UgaGFuZGxlciBmb3IgbWVzc2FnZXMgcmVjZWl2ZWRcbiAgICogQHBhcmFtIHtNZXNzYWdlRXZlbnR9IG1zZyAtIE1lc3NhZ2UgcmVjZWl2ZWQgZnJvbSB3c1xuICAgKi9cbiAgaGFuZGxlTWVzc2FnZShtc2cpIHtcbiAgICBpZiAobXNnLmRhdGEgPT09IFwicGluZ1wiKSByZXR1cm4gdGhpcy5faGFuZGxlUGluZygpXG5cbiAgICBsZXQgcGFyc2VkX21zZyA9IEpTT04ucGFyc2UobXNnLmRhdGEpXG4gICAgdGhpcy5jaGFubmVscy5mb3JFYWNoKChjaGFubmVsKSA9PiB7XG4gICAgICBpZiAoY2hhbm5lbC50b3BpYyA9PT0gcGFyc2VkX21zZy50b3BpYykgY2hhbm5lbC5oYW5kbGVNZXNzYWdlKHBhcnNlZF9tc2cpXG4gICAgfSlcbiAgfVxufVxuXG5tb2R1bGUuZXhwb3J0cyA9IHtcbiAgU29ja2V0OiBTb2NrZXRcbn1cblxuXG4vKipcbiAqIEFsbG93cyBkZWxldGUgbGlua3MgdG8gcG9zdCBmb3Igc2VjdXJpdHkgYW5kIGVhc2Ugb2YgdXNlIHNpbWlsYXIgdG8gUmFpbHMganF1ZXJ5X3Vqc1xuICovXG5kb2N1bWVudC5hZGRFdmVudExpc3RlbmVyKFwiRE9NQ29udGVudExvYWRlZFwiLCBmdW5jdGlvbiAoKSB7XG4gICAgZG9jdW1lbnQucXVlcnlTZWxlY3RvckFsbChcImFbZGF0YS1tZXRob2Q9J2RlbGV0ZSddXCIpLmZvckVhY2goZnVuY3Rpb24gKGVsZW1lbnQpIHtcbiAgICAgICAgZWxlbWVudC5hZGRFdmVudExpc3RlbmVyKFwiY2xpY2tcIiwgZnVuY3Rpb24gKGUpIHtcbiAgICAgICAgICAgIGUucHJldmVudERlZmF1bHQoKTtcbiAgICAgICAgICAgIHZhciBtZXNzYWdlID0gZWxlbWVudC5nZXRBdHRyaWJ1dGUoXCJkYXRhLWNvbmZpcm1cIikgfHwgXCJBcmUgeW91IHN1cmU/XCI7XG4gICAgICAgICAgICBpZiAoY29uZmlybShtZXNzYWdlKSkge1xuICAgICAgICAgICAgICAgIHZhciBmb3JtID0gZG9jdW1lbnQuY3JlYXRlRWxlbWVudChcImZvcm1cIik7XG4gICAgICAgICAgICAgICAgdmFyIGlucHV0ID0gZG9jdW1lbnQuY3JlYXRlRWxlbWVudChcImlucHV0XCIpO1xuICAgICAgICAgICAgICAgIGZvcm0uc2V0QXR0cmlidXRlKFwiYWN0aW9uXCIsIGVsZW1lbnQuZ2V0QXR0cmlidXRlKFwiaHJlZlwiKSk7XG4gICAgICAgICAgICAgICAgZm9ybS5zZXRBdHRyaWJ1dGUoXCJtZXRob2RcIiwgXCJQT1NUXCIpO1xuICAgICAgICAgICAgICAgIGlucHV0LnNldEF0dHJpYnV0ZShcInR5cGVcIiwgXCJoaWRkZW5cIik7XG4gICAgICAgICAgICAgICAgaW5wdXQuc2V0QXR0cmlidXRlKFwibmFtZVwiLCBcIl9tZXRob2RcIik7XG4gICAgICAgICAgICAgICAgaW5wdXQuc2V0QXR0cmlidXRlKFwidmFsdWVcIiwgXCJERUxFVEVcIik7XG4gICAgICAgICAgICAgICAgZm9ybS5hcHBlbmRDaGlsZChpbnB1dCk7XG4gICAgICAgICAgICAgICAgZG9jdW1lbnQuYm9keS5hcHBlbmRDaGlsZChmb3JtKTtcbiAgICAgICAgICAgICAgICBmb3JtLnN1Ym1pdCgpO1xuICAgICAgICAgICAgfVxuICAgICAgICAgICAgcmV0dXJuIGZhbHNlO1xuICAgICAgICB9KVxuICAgIH0pXG59KTtcblxuXG5cbi8vIFdFQlBBQ0sgRk9PVEVSIC8vXG4vLyAuL2xpYi9hbWJlci9hc3NldHMvanMvYW1iZXIuanMiLCJpZiAoZG9jdW1lbnQuZ2V0RWxlbWVudEJ5SWQoJ3NpbXBsZS1sb2dnZXInKSkge1xuICBsZXQgc3RhdHVzRmllbGQgPSBkb2N1bWVudC5nZXRFbGVtZW50QnlJZCgnc3RhdHVzJylcbiAgbGV0IHN0YXR1c0Ryb3Bkb3duID0gZG9jdW1lbnQuZ2V0RWxlbWVudEJ5SWQoJ3N0YXR1cy1kcm9wZG93bicpXG4gIGxldCBzdGF0dXNEcm9wZG93bk9wdGlvbnMgPSBkb2N1bWVudC5nZXRFbGVtZW50QnlJZCgnc3RhdHVzLWRyb3Bkb3duLW9wdGlvbnMnKVxuXG4gIEFycmF5LmZyb20oc3RhdHVzRHJvcGRvd25PcHRpb25zLmNoaWxkcmVuKS5mb3JFYWNoKGRyb3Bkb3duSXRlbSA9PiB7XG4gICAgZHJvcGRvd25JdGVtLmFkZEV2ZW50TGlzdGVuZXIoJ2NsaWNrJywgKGUpID0+IHtcbiAgICAgIGxldCBpdGVtID0gZS50YXJnZXRcbiAgICAgIGxldCBuZXdTdGF0dXMgPSBpdGVtLmdldEF0dHJpYnV0ZSgnZGF0YS1zdGF0dXMnKS50cmltKClcbiAgICAgIGxldCBuZXdTdGF0dXNUaXRsZSA9IGl0ZW0uaW5uZXJUZXh0LnRyaW0oKVxuXG4gICAgICBpdGVtLmlubmVyVGV4dCA9IHN0YXR1c0Ryb3Bkb3duLmlubmVyVGV4dC50cmltKClcbiAgICAgIGl0ZW0uc2V0QXR0cmlidXRlKCdkYXRhLXN0YXR1cycsIHN0YXR1c0ZpZWxkLmdldEF0dHJpYnV0ZSgnY29udGVudCcpLnRyaW0oKSlcblxuICAgICAgc3RhdHVzRHJvcGRvd24uaW5uZXJUZXh0ID0gbmV3U3RhdHVzVGl0bGVcbiAgICAgIHN0YXR1c0ZpZWxkLnNldEF0dHJpYnV0ZSgnY29udGVudCcsIG5ld1N0YXR1cylcbiAgICB9KVxuICB9KVxuXG4gIGxldCBwbGF5ZXJGaWVsZCA9IGRvY3VtZW50LmdldEVsZW1lbnRCeUlkKCdvdGhlci1wbGF5ZXItaWQnKVxuICBsZXQgcGxheWVyRHJvcGRvd24gPSBkb2N1bWVudC5nZXRFbGVtZW50QnlJZCgncGxheWVyLWRyb3Bkb3duJylcbiAgbGV0IHBsYXllckRyb3Bkb3duT3B0aW9ucyA9IGRvY3VtZW50LmdldEVsZW1lbnRCeUlkKCdwbGF5ZXItZHJvcGRvd24tb3B0aW9ucycpXG5cbiAgQXJyYXkuZnJvbShwbGF5ZXJEcm9wZG93bk9wdGlvbnMuY2hpbGRyZW4pLmZvckVhY2goZHJvcGRvd25JdGVtID0+IHtcbiAgICBkcm9wZG93bkl0ZW0uYWRkRXZlbnRMaXN0ZW5lcignY2xpY2snLCAoZSkgPT4ge1xuICAgICAgbGV0IGl0ZW0gPSBlLnRhcmdldFxuICAgICAgbGV0IG5ld1BsYXllcklkID0gaXRlbS5nZXRBdHRyaWJ1dGUoJ2RhdGEtcGxheWVyLWlkJykudHJpbSgpXG4gICAgICBsZXQgbmV3UGxheWVyTmFtZSA9IGl0ZW0uaW5uZXJUZXh0LnRyaW0oKVxuXG4gICAgICBpdGVtLmlubmVyVGV4dCA9IHBsYXllckRyb3Bkb3duLmlubmVyVGV4dC50cmltKClcbiAgICAgIGl0ZW0uc2V0QXR0cmlidXRlKCdkYXRhLXBsYXllci1pZCcsIHBsYXllckZpZWxkLmdldEF0dHJpYnV0ZSgnY29udGVudCcpLnRyaW0oKSlcblxuICAgICAgcGxheWVyRHJvcGRvd24uaW5uZXJUZXh0ID0gbmV3UGxheWVyTmFtZVxuICAgICAgcGxheWVyRmllbGQuc2V0QXR0cmlidXRlKCdjb250ZW50JywgbmV3UGxheWVySWQpXG4gICAgfSlcbiAgfSlcbn1cblxuXG4vLyBXRUJQQUNLIEZPT1RFUiAvL1xuLy8gLi9zcmMvYXNzZXRzL2phdmFzY3JpcHRzL2dhbWUuanMiXSwic291cmNlUm9vdCI6IiJ9