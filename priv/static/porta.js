(function(exports){
'use strict';

Object.defineProperty(exports, "__esModule", {
  value: true
});

var _get = function get(object, property, receiver) { if (object === null) object = Function.prototype; var desc = Object.getOwnPropertyDescriptor(object, property); if (desc === undefined) { var parent = Object.getPrototypeOf(object); if (parent === null) { return undefined; } else { return get(parent, property, receiver); } } else if ("value" in desc) { return desc.value; } else { var getter = desc.get; if (getter === undefined) { return undefined; } return getter.call(receiver); } };

var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();

exports.default = function (PhoenixSocket) {
  var Table = function () {
    function Table() {
      var data = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : [];
      var key = arguments.length > 1 && arguments[1] !== undefined ? arguments[1] : "id";

      _classCallCheck(this, Table);

      this.data = data;
      this.key = key;
    }

    _createClass(Table, [{
      key: 'upsert',
      value: function upsert(row) {
        var _iteratorNormalCompletion = true;
        var _didIteratorError = false;
        var _iteratorError = undefined;

        try {
          for (var _iterator = this.data[Symbol.iterator](), _step; !(_iteratorNormalCompletion = (_step = _iterator.next()).done); _iteratorNormalCompletion = true) {
            var d = _step.value;

            if (this.data[d][this.key] == row[this.key]) {
              for (var r in row) {
                this.data[d][r] = row[r];
              }
              return true;
            }
          }
        } catch (err) {
          _didIteratorError = true;
          _iteratorError = err;
        } finally {
          try {
            if (!_iteratorNormalCompletion && _iterator.return) {
              _iterator.return();
            }
          } finally {
            if (_didIteratorError) {
              throw _iteratorError;
            }
          }
        }

        this.data.push(row);
        return false;
      }
    }, {
      key: 'delete',
      value: function _delete(row) {
        var _this = this;

        // yes
        var current = this.data.filter(function (x) {
          return x[_this.key] == row[_this.key];
        })[0];
        if (current != null) {
          var index = this.data.indexOf(current);
          this.data.splice(index, 1);
        }
        return current != null;
      }
    }]);

    return Table;
  }();

  var Socket = function (_PhoenixSocket) {
    _inherits(Socket, _PhoenixSocket);

    function Socket() {
      var _ref;

      _classCallCheck(this, Socket);

      for (var _len = arguments.length, args = Array(_len), _key = 0; _key < _len; _key++) {
        args[_key] = arguments[_key];
      }

      var _this2 = _possibleConstructorReturn(this, (_ref = Socket.__proto__ || Object.getPrototypeOf(Socket)).call.apply(_ref, [this].concat(args)));

      _this2.tables = {};
      return _this2;
    }

    _createClass(Socket, [{
      key: 'channel',
      value: function channel() {
        var _get2,
            _this3 = this;

        for (var _len2 = arguments.length, args = Array(_len2), _key2 = 0; _key2 < _len2; _key2++) {
          args[_key2] = arguments[_key2];
        }

        var channel = (_get2 = _get(Socket.prototype.__proto__ || Object.getPrototypeOf(Socket.prototype), 'channel', this)).call.apply(_get2, [this].concat(args));
        var _arr = ['insert', 'update', 'delete'];
        for (var _i = 0; _i < _arr.length; _i++) {
          var s = _arr[_i];
          this.addDataShorthand(channel, s);
        }
        channel.on("notif", function (res) {
          if (res.table && res.data) {
            if (res.event == "delete") {
              _this3.table(res.table).delete(res.data);
            } else {
              _this3.table(res.table).upsert(res.data);
            }
          }
        });
        return channel;
      }
    }, {
      key: 'addDataShorthand',
      value: function addDataShorthand(channel, event) {
        channel[event] = function (data) {
          for (var _len3 = arguments.length, args = Array(_len3 > 2 ? _len3 - 2 : 0), _key3 = 2; _key3 < _len3; _key3++) {
            args[_key3 - 2] = arguments[_key3];
          }

          var opts = arguments.length > 1 && arguments[1] !== undefined ? arguments[1] : {};

          var payload = {};
          for (var o in opts) {
            payload[o] = opts[o];
          }
          payload.data = data;
          channel.push.apply(channel, [event, payload].concat(args));
        };
      }
    }, {
      key: 'table',
      value: function table(name) {
        if (!this.tables[name]) {
          this.tables[name] = new Table();
        }
        return this.tables[name];
      }
    }]);

    return Socket;
  }(PhoenixSocket);

  return Socket;
};

function _possibleConstructorReturn(self, call) { if (!self) { throw new ReferenceError("this hasn't been initialised - super() hasn't been called"); } return call && (typeof call === "object" || typeof call === "function") ? call : self; }

function _inherits(subClass, superClass) { if (typeof superClass !== "function" && superClass !== null) { throw new TypeError("Super expression must either be null or a function, not " + typeof superClass); } subClass.prototype = Object.create(superClass && superClass.prototype, { constructor: { value: subClass, enumerable: false, writable: true, configurable: true } }); if (superClass) Object.setPrototypeOf ? Object.setPrototypeOf(subClass, superClass) : subClass.__proto__ = superClass; }

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

})(typeof(exports) === "undefined" ? window.Porta = window.Porta || {} : exports);

;