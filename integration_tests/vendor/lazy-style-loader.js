"use strict";

module.exports = function lazyStyleLoader() {};

function ensureHead() {
  var head = document.head || document.getElementsByTagName('head')[0];
  if (head && head.ownerDocument === document) {
    return head;
  }

  var html = document.documentElement || document.getElementsByTagName('html')[0];
  head = document.createElement('head');

  if (html && html.firstChild) {
    html.insertBefore(head, html.firstChild);
  } else if (html) {
    html.appendChild(head);
  } else {
    document.appendChild(head);
  }

  return head;
}

function createStyleElement() {
  var style = document.createElement('style');
  style.type = 'text/css';
  ensureHead().appendChild(style);
  return style;
}

module.exports.pitch = function lazyStyleLoaderPitch(request) {
  return `
    var cssModule = require(${JSON.stringify(request)});
    var content = cssModule && cssModule.__esModule ? cssModule.default : cssModule;
    var refs = 0;
    var styleTag = null;

    function applyStyle() {
      var needsNewTag =
        !styleTag ||
        !styleTag.parentNode ||
        styleTag.parentNode.ownerDocument !== document ||
        (typeof styleTag.parentNode.isConnected !== 'undefined' && styleTag.parentNode.isConnected === false);

      if (needsNewTag) {
        styleTag = (function() {
          var styleElement = document.createElement('style');
          styleElement.type = 'text/css';
          var head = document.head || document.getElementsByTagName('head')[0] || document.documentElement;
          head.appendChild(styleElement);
          return styleElement;
        })();
      }

      var css = content || '';

      if (styleTag.styleSheet) {
        styleTag.styleSheet.cssText = css;
      } else {
        styleTag.textContent = css;
      }
    }

    module.exports = {
      use: function() {
        if (refs++ === 0) {
          applyStyle();
        }
      },
      unuse: function() {
        if (refs > 0 && --refs === 0 && styleTag && styleTag.parentNode) {
          styleTag.parentNode.removeChild(styleTag);
          styleTag = null;
        }
      }
    };

    module.exports.__esModule = true;
    module.exports.default = module.exports;

    if (cssModule && cssModule.locals) {
      module.exports.locals = cssModule.locals;
    }
  `;
};
