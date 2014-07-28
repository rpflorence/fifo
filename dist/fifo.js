// Generated by CoffeeScript 1.7.1
(function() {
  (function(root, factory) {
    var fifo, _fifo;
    if (typeof define !== "undefined" && define !== null ? define.amd : void 0) {
      return define(factory);
    } else {
      _fifo = root.fifo;
      fifo = root.fifo = factory();
      return fifo.noConflict = function() {
        root.fifo = _fifo;
        return fifo;
      };
    }
  })(this, function() {
    return function(namespace) {
      var data, removeFirstIn, save, trySave;
      data = JSON.parse(localStorage.getItem(namespace) || '{"keys":[],"items":{}}');
      trySave = function(key, value) {
        var error;
        try {
          if (!key) {
            localStorage.setItem(namespace, JSON.stringify(data));
          } else {
            localStorage.setItem(key, value);
          }
          return true;
        } catch (_error) {
          error = _error;
          if (error.code === 22 || error.code === 1014) {
            return false;
          }
          throw new Error(error);
        }
      };
      removeFirstIn = function() {
        var firstIn, removedItem;
        firstIn = data.keys.pop();
        removedItem = {
          key: firstIn,
          value: data.items[firstIn]
        };
        delete data.items[firstIn];
        return removedItem;
      };
      save = function(key, value) {
        var removed;
        removed = [];
        while (!trySave(key, value)) {
          if (data.keys.length) {
            removed.push(removeFirstIn());
            if (key) {
              localStorage.setItem(namespace, JSON.stringify(data));
            }
          } else {
            throw new Error("All items removed from " + namespace + ", still can't save");
            break;
          }
        }
        return removed;
      };
      return {
        set: function(key, value, onRemoved) {
          var index, removed;
          data.items[key] = value;
          index = data.keys.indexOf(key);
          if (index > -1) {
            data.keys.splice(index, 1);
          }
          data.keys.unshift(key);
          removed = save();
          if (onRemoved && removed.length) {
            onRemoved.call(this, removed);
          }
          return this;
        },
        get: function(key) {
          var items;
          if (key) {
            return localStorage.getItem(key) || data.items[key];
          } else {
            items = data.items;
            Object.keys(localStorage).forEach(function(key) {
              if (key !== namespace) {
                return items[key] = localStorage.getItem(key);
              }
            });
            return items;
          }
        },
        setFixed: function(key, value, onRemoved) {
          var removed;
          removed = save(key, value);
          if (onRemoved && removed.length) {
            onRemoved.call(this, removed);
          }
          return this;
        },
        keys: function() {
          var keys;
          keys = [];
          data.keys.forEach(function(key) {
            return keys.push(key);
          });
          Object.keys(localStorage).forEach(function(value) {
            if (value !== namespace) {
              return keys.push(value);
            }
          });
          return keys;
        },
        has: function(key) {
          if (-1 !== data.keys.indexOf(key)) {
            return true;
          }
          if (localStorage.getItem(key) !== null) {
            return true;
          }
          return false;
        },
        remove: function(victim) {
          if (typeof victim === 'string') {
            return this._removeByString(victim);
          }
          if (victim instanceof RegExp) {
            return this._removeByRegExp(victim);
          }
          return this._removeByFunction(victim);
        },
        _removeByRegExp: function(victim) {
          Object.keys(localStorage).forEach(function(value) {
            if (value.match(victim)) {
              return localStorage.removeItem(value);
            }
          });
          data.keys.forEach(function(suspect, index) {
            if (suspect.match(victim)) {
              data.keys.splice(index, 1);
              return delete data.items[suspect];
            }
          });
          save();
          return this;
        },
        _removeByFunction: function(victim) {
          Object.keys(localStorage).forEach(function(value) {
            if (victim(value)) {
              return localStorage.removeItem(value);
            }
          });
          data.keys.forEach(function(suspect, index) {
            if (victim(suspect)) {
              data.keys.splice(index, 1);
              return delete data.items[suspect];
            }
          });
          save();
          return this;
        },
        _removeByString: function(victim) {
          var index, suspect, _i, _len, _ref;
          if (localStorage.getItem(victim)) {
            localStorage.removeItem(victim);
            return this;
          }
          _ref = data.keys;
          for (index = _i = 0, _len = _ref.length; _i < _len; index = ++_i) {
            suspect = _ref[index];
            if (!(suspect === victim)) {
              continue;
            }
            data.keys.splice(index, 1);
            break;
          }
          delete data.items[victim];
          save();
          return this;
        },
        empty: function() {
          data = {
            keys: [],
            items: {}
          };
          save();
          return this;
        }
      };
    };
  });

}).call(this);
