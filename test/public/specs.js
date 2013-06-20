

(function(/*! Stitch !*/) {
  if (!this.specs) {
    var modules = {}, cache = {}, require = function(name, root) {
      var path = expand(root, name), indexPath = expand(path, './index'), module, fn;
      module   = cache[path] || cache[indexPath]
      if (module) {
        return module.exports;
      } else if (fn = modules[path] || modules[path = indexPath]) {
        module = {id: path, exports: {}};
        try {
          cache[path] = module;
          fn(module.exports, function(name) {
            return require(name, dirname(path));
          }, module);
          return module.exports;
        } catch (err) {
          delete cache[path];
          throw err;
        }
      } else {
        throw 'module \'' + name + '\' not found';
      }
    }, expand = function(root, name) {
      var results = [], parts, part;
      if (/^\.\.?(\/|$)/.test(name)) {
        parts = [root, name].join('/').split('/');
      } else {
        parts = name.split('/');
      }
      for (var i = 0, length = parts.length; i < length; i++) {
        part = parts[i];
        if (part == '..') {
          results.pop();
        } else if (part != '.' && part != '') {
          results.push(part);
        }
      }
      return results.join('/');
    }, dirname = function(path) {
      return path.split('/').slice(0, -1).join('/');
    };
    this.specs = function(name) {
      return require(name, '');
    }
    this.specs.define = function(bundle) {
      for (var key in bundle)
        modules[key] = bundle[key];
    };
    this.specs.modules = modules;
    this.specs.cache   = cache;
  }
  return this.specs.define;
}).call(this)({
  "controllers/Mark": function(exports, require, module) {(function() {
  var require;

  require = window.require;

  describe('Mark', function() {
    var Mark;
    Mark = require('controllers/mark');
    return it('can noop', function() {});
  });

}).call(this);
}, "controllers/about_page": function(exports, require, module) {(function() {
  var require;

  require = window.require;

  describe('AboutPage', function() {
    var AboutPage;
    AboutPage = require('controllers/aboutpage');
    return it('can noop', function() {});
  });

}).call(this);
}, "controllers/classifier": function(exports, require, module) {(function() {
  var require;

  require = window.require;

  describe('Classifier', function() {
    var Classifier;
    Classifier = require('controllers/classifier');
    return it('can noop', function() {});
  });

}).call(this);
}, "controllers/dashboard": function(exports, require, module) {(function() {
  var require;

  require = window.require;

  describe('Dashboard', function() {
    var Dashboard;
    Dashboard = require('controllers/dashboard');
    return it('can noop', function() {});
  });

}).call(this);
}, "controllers/home_page": function(exports, require, module) {(function() {
  var require;

  require = window.require;

  describe('HomePage', function() {
    var HomePage;
    HomePage = require('controllers/homepage');
    return it('can noop', function() {});
  });

}).call(this);
}, "controllers/profile": function(exports, require, module) {(function() {
  var require;

  require = window.require;

  describe('Profile', function() {
    var Profile;
    Profile = require('controllers/profile');
    return it('can noop', function() {});
  });

}).call(this);
}
});

require('lib/setup'); for (var key in specs.modules) specs(key);