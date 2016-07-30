!function(e){if("object"==typeof exports&&"undefined"!=typeof module)module.exports=e();else if("function"==typeof define&&define.amd)define([],e);else{var f;"undefined"!=typeof window?f=window:"undefined"!=typeof global?f=global:"undefined"!=typeof self&&(f=self),(f.Leaflet||(f.Leaflet={})).Bookmarks=e()}}(function(){var define,module,exports;return (function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
(function (global){
/**
 * Leaflet bookmarks plugin
 * @license MIT
 * @author Alexander Milevski <info@w8r.name>
 * @preserve
 */
var L = global.L || require('leaflet');

L.Control.Bookmarks = module.exports = require('./src/bookmarks');

}).call(this,typeof global !== "undefined" ? global : typeof self !== "undefined" ? self : typeof window !== "undefined" ? window : {})
},{"./src/bookmarks":2,"leaflet":undefined}],2:[function(require,module,exports){
(function (global){
var L = global.L || require('leaflet');
var Storage = require('./storage');
var FormPopup = require('./formpopup');
var substitute = require('./string').substitute;
require('./leaflet.delegate');

// expose
L.Util._template = L.Util._template || substitute;

/**
 * Bookmarks control
 * @class  L.Control.Bookmarks
 * @extends {L.Control}
 */
var Bookmarks = L.Control.extend( /**  @lends Bookmarks.prototype */ {

  statics: {
    Storage: Storage,
    FormPopup: FormPopup
  },

  /**
   * @type {Object}
   */
  options: {
    localStorage: true,

    /* you can provide access to your own storage,
     * xhr for example, but make sure it has all
     * required endpoints:
     *
     * .getItem(id, callback)
     * .setItem(id, callback)
     * .getAllItems(callback)
     * .removeItem(id, callback)
     */
    storage: null,
    name: 'leaflet-bookmarks',
    position: 'topright', // chose your own if you want


    containerClass: 'leaflet-bar leaflet-bookmarks-control',
    expandedClass: 'expanded',
    headerClass: 'bookmarks-header',
    listClass: 'bookmarks-list',
    iconClass: 'bookmarks-icon',
    iconWrapperClass: 'bookmarks-icon-wrapper',
    listWrapperClass: 'bookmarks-list-wrapper',
    wrapperClass: 'bookmarks-container',

    animateClass: 'bookmark-added-anim',
    animateDuration: 150,

    formPopup: {
      popupClass: 'bookmarks-popup'
    },

    bookmarkTemplate: '<li class="{{ itemClass }}" data-id="{{ data.id }}">' +
      // '<span class="{{ removeClass }}">&times;</span>' +
      '<span class="{{ nameClass }}">{{ data.name }}</span>' +
      // '<span class="{{ coordsClass }}">{{ data.coords }}</span>' +
      '</li>',

    emptyTemplate: '<li class="{{ itemClass }} {{ emptyClass }}">' +
      '{{ data.emptyMessage }}</li>',

    dividerTemplate: '<li class="divider"></li>',

    bookmarkTemplateOptions: {
      itemClass: 'bookmark-item',
      nameClass: 'bookmark-name',
      coordsClass: 'bookmark-coords',
      removeClass: 'bookmark-remove',
      emptyClass: 'bookmarks-empty'
    },

    title: 'Bookmarks',
    emptyMessage: 'No bookmarks yet',
    collapseOnClick: true,
    scrollOnAdd: true,
    scrollDuration: 1000,
    popupOnShow: true,

    /**
     * This you can change easily to output
     * whatever you have stored in bookmark
     *
     * @type {String}
     */
    popupTemplate: '<div><h3>{{ name }}</h3><p>{{ latlng }}, {{ zoom }}</p></div>',

    /**
     * Prepare your bookmark data for template.
     * If you don't change it, the context of this
     * function will be bookmarks control, so you can
     * access the map or other things from here
     *
     * @param  {Object} bookmark
     * @return {Object}
     */
    getPopupContent: function(bookmark) {
      return substitute(this.options.popupTemplate, {
        latlng: this.formatCoords(bookmark.latlng),
        name: bookmark.name,
        zoom: this._map.getZoom()
      });
    }
  },

  /**
   * @param  {Object} options
   * @constructor
   */
  initialize: function(options) {

    options = options || {};

    /**
     * Bookmarks array
     * @type {Array}
     */
    this._data = [];

    /**
     * @type {Element}
     */
    this._list = null;

    /**
     * @type {L.Marker}
     */
    this._marker = null;

    /**
     * @type {Element}
     */
    this._icon = null;

    /**
     * @type {Boolean}
     */
    this._isCollapsed = true;

    /**
     * @type {Storage}
     */
    this._storage = options.storage ||
      (this.options.localStorage ?
        new Storage(this.options.name, Storage.engineType.LOCALSTORAGE) :
        new Storage(this.options.name, Storage.engineType.GLOBALSTORAGE));

    L.Util.setOptions(this, options);
    L.Control.prototype.initialize.call(this, this.options);
  },

  /**
   * @param {L.Map} map
   */
  onAdd: function(map) {
    var container = this._container = L.DomUtil.create('div',
      this.options.containerClass
    );

    L.DomEvent
      .disableClickPropagation(container)
      .disableScrollPropagation(container);
    container.innerHTML = '<div class="' + this.options.headerClass +
      '"><span class="' + this.options.iconWrapperClass + '">' +
      '<span class="' + this.options.iconClass + '"></span></span>';

    this._icon = container.querySelector('.' + this.options.iconClass);
    this._icon.title = this.options.title;

    this._createList(this.options.bookmarks);

    var wrapper = L.DomUtil.create('div',
      this.options.wrapperClass, this._container);
    wrapper.appendChild(this._listwrapper);

    this._initLayout();

    L.DomEvent
      .on(container, 'click', this._onClick, this)
      .on(container, 'contextmenu', L.DomEvent.stopPropagation);

    map.on('bookmark:new', this._onBookmarkAddStart, this)
      .on('bookmark:add', this._onBookmarkAdd, this)
      .on('bookmark:show', this._onBookmarkShow, this)
      .on('resize', this._initLayout, this);

    return container;
  },

  /**
   * @param  {L.Map} map
   */
  onRemove: function(map) {
    map.off('bookmark:new', this._onBookmark, this)
      .off('bookmark:add', this._onBookmarkAdd, this)
      .off('bookmark:show', this._onBookmarkShow, this)
      .off('resize', this._initLayout, this);

    this._marker = null;
    this._popup = null;
    this._container = null;
  },

  /**
   * @return {Array.<Object>}
   */
  getData: function() {
    return this._filterBookmarksOutput(this._data);
  },

  /**
   * @param  {Array.<Number>|Function|null} bookmarks
   */
  _createList: function(bookmarks) {
    this._listwrapper = L.DomUtil.create(
      'div', this.options.listWrapperClass, this._container);
    this._list = L.DomUtil.create(
      'ul', this.options.listClass, this._listwrapper);

    // select bookmark
    L.DomEvent.delegate(
      this._list,
      '.' + this.options.bookmarkTemplateOptions.itemClass,
      'click',
      this._onBookmarkClick,
      this
    );

    this._setEmptyListContent();

    if (L.Util.isArray(bookmarks)) {
      this._appendItems(bookmarks);
    } else if (typeof bookmarks === 'function') {
      this._appendItems(bookmarks());
    } else {
      var self = this;
      this._storage.getAllItems(function(bookmarks) {
        self._appendItems(bookmarks);
      });
    }
  },

  /**
   * Empty list
   */
  _setEmptyListContent: function() {
    this._list.innerHTML = substitute(this.options.emptyTemplate,
      L.Util.extend(this.options.bookmarkTemplateOptions, {
        data: {
          emptyMessage: this.options.emptyMessage
        }
      }));
  },

  /**
   * Sees that the list size is not too big
   */
  _initLayout: function() {
    var size = this._map.getSize();
    this._listwrapper.style.maxHeight =
      Math.min(size.y * 0.6, size.y - 100) + 'px';

    if (this.options.position === 'topleft') {
      L.DomUtil.addClass(this._container, 'leaflet-bookmarks-to-right');
    }
  },

  /**
   * I don't care if they're unique or not,
   * if you do - handle this
   *
   * @param {Array.<Object>} bookmarks
   * @return {Array.<Object>}
   */
  _filterBookmarks: function(bookmarks) {
    if (this.options.filterBookmarks) {
      return this.options.filterBookmarks.call(this, bookmarks);
    } else {
      return bookmarks;
    }
  },

  /**
   * Filter bookmarks for output. This one allows you to save dividers as well
   *
   * @param {Array.<Object>} bookmarks
   * @return {Array.<Object>}
   */
  _filterBookmarksOutput: function(bookmarks) {
    if (this.options.filterBookmarksOutput) {
      return this.options.filterBookmarksOutput.call(this, bookmarks);
    } else {
      return bookmarks;
    }
  },

  /**
   * Append list items(render)
   * @param  {Array.<Object>} bookmarks
   */
  _appendItems: function(bookmarks) {
    var html = '',
      wasEmpty = this._data.length === 0,
      bookmark;

    // maybe you have something in mind?
    bookmarks = this._filterBookmarks(bookmarks);

    // store
    this._data = this._data.concat(bookmarks);

    for (var i = 0, len = bookmarks.length; i < len; i++) {
      html += this._renderBookmarkItem(bookmarks[i]);
    }

    if (html !== '') {
      // replace `empty` message if needed
      if (wasEmpty) {
        this._list.innerHTML = html;
      } else {
        this._list.innerHTML += html;
      }
    }

    if (this._isCollapsed) {
      var container = this._container,
        className = this.options.animateClass;
      container.classList.add(className);
      window.setTimeout(function() {
        container.classList.remove(className);
      }, this.options.animateDuration);
    } else {
      this._scrollToLast();
    }
  },

  /**
   * Scrolls to last element of the list
   */
  _scrollToLast: function() {
    var listwrapper = this._listwrapper;
    var pos = this._listwrapper.scrollTop;
    var targetVal = this._list.lastChild.offsetTop;
    var start = 0;

    var step = (targetVal - pos) / (this.options.scrollDuration / (1000 / 16));

    function scroll(timestamp) {
      if (!start) {
        start = timestamp
      }
      //var progress = timestamp - start;

      pos = Math.min(pos + step, targetVal);
      listwrapper.scrollTop = pos;
      if (pos !== targetVal) {
        L.Util.requestAnimFrame(scroll);
      }
    }
    L.Util.requestAnimFrame(scroll);
  },

  /**
   * Render single bookmark item
   * @param  {Object} bookmark
   * @return {String}
   */
  _renderBookmarkItem: function(bookmark) {
    if (bookmark.divider) {
      return substitute(this.options.dividerTemplate, bookmark);
    }

    this.options.bookmarkTemplateOptions.data =
      this._getBookmarkDataForTemplate(bookmark);

    return substitute(
      this.options.bookmarkTemplate,
      this.options.bookmarkTemplateOptions
    );
  },

  /**
   * Extracts data and style expressions for item template
   * @param  {Object} bookmark
   * @return {Object}
   */
  _getBookmarkDataForTemplate: function(bookmark) {
    return {
      coords: this.formatCoords(bookmark.latlng),
      name: this.formatName(bookmark.name),
      zoom: bookmark.zoom,
      id: bookmark.id
    };
  },

  /**
   * @param  {L.LatLng} latlng
   * @return {String}
   */
  formatCoords: function(latlng) {
    if (this.options.formatCoords) {
      return this.options.formatCoords.call(this, latlng);
    } else {
      return latlng[0].toFixed(4) + ',&nbsp;' + latlng[1].toFixed(4);
    }
  },

  /**
   * @param  {String} name
   * @return {String}
   */
  formatName: function(name) {
    if (this.options.formatName) {
      return this.options.formatName.call(this, name);
    } else {
      return name;
    }
  },

  /**
   * Shows bookmarks list
   */
  expand: function() {
    L.DomUtil.addClass(this._container, this.options.expandedClass);
    this._isCollapsed = false;
  },

  /**
   * Hides bookmarks list and the form
   */
  collapse: function() {
    L.DomUtil.removeClass(this._container, this.options.expandedClass);
    this._isCollapsed = true;
  },

  /**
   * @param  {Event} evt
   */
  _onClick: function(evt) {
    var expanded = L.DomUtil.hasClass(
        this._container, this.options.expandedClass),
      target = evt.target || evt.srcElement;

    if (expanded) {
      // check if it's inside the header
      while (target !== this._container) {
        if (L.DomUtil.hasClass(target, this.options.headerClass) ||
          L.DomUtil.hasClass(target, this.options.listWrapperClass)) {
          this.collapse();
          break;
        }
        target = target.parentNode;
      }
    } else {
      this.expand();
    }
  },

  /**
   * @param  {Object} evt
   */
  _onBookmarkAddStart: function(evt) {
    if (this._marker) {
      this._popup._close();
    }

    this._marker = new L.Marker(evt.latlng, {
      icon: this.options.icon || new L.Icon.Default(),
      draggable: true,
      riseOnHover: true
    }).addTo(this._map);
    this._marker.on('popupclose', this._onPopupClosed, this);

    // open form
    this._popup = new L.Control.Bookmarks.FormPopup(
      this.options.formPopup,
      this._marker
    ).addTo(this._map);
  },

  /**
   * Bookmark added
   * @param  {Object} bookmark
   */
  _onBookmarkAdd: function(bookmark) {
    var self = this;
    bookmark = this._cleanBookmark(bookmark.data);
    this._storage.setItem(bookmark.id, bookmark, function(item) {
      self._appendItems([item]);
    });
    this._showBookmark(bookmark);
  },

  /**
   * Cleans circular reference for JSON
   * @param  {Object} bookmark
   * @return {Object}
   */
  _cleanBookmark: function(bookmark) {
    if (!L.Util.isArray(bookmark.latlng)) {
      bookmark.latlng = [bookmark.latlng.lat, bookmark.latlng.lng];
    }

    return bookmark;
  },

  /**
   * Form closed
   * @param  {Object} evt
   */
  _onPopupClosed: function(evt) {
    this._map.removeLayer(this._marker);
    this._marker = null;
    this._popup = null;
  },

  /**
   * @param  {String} id
   * @return {Object|Null}
   */
  _getBookmark: function(id) {
    for (var i = 0, len = this._data.length; i < len; i++) {
      if (this._data[i].id === id) {
        return this._data[i];
      }
    }
    return null;
  },

  /**
   * @param  {Object} evt
   */
  _onBookmarkShow: function(evt) {
    this._gotoBookmark(evt.data);
  },

  /**
   * Shows bookmark, nothing else
   * @param  {Object} bookmark
   */
  _showBookmark: function(bookmark) {
    var coords = L.latLng(bookmark.latlng),
      marker = new L.Marker(coords, {
        icon: this.options.icon || new L.Icon.Default(),
        riseOnHover: true
      }).addTo(this._map);

    function removeIfRemoved(evt) {
      if (evt.data.id === bookmark.id) {
        marker.clearAllEventListeners();
        marker.closePopup();
        this.removeLayer(marker);
      }
    }

    marker.bindPopup(this._getPopupContent(bookmark));
    this._map.on('bookmark:removed', removeIfRemoved);

    marker
      .on('popupclose', function() {
        this._map.removeLayer(this);
      })
      .on('remove', function() {
        this._map.off('bookmark:removed', removeIfRemoved);
      });

    if (this.options.popupOnShow) {
      marker.openPopup();
    }
  },

  /**
   * @param  {Object} bookmark
   */
  _gotoBookmark: function(bookmark) {
    this._map.setView(bookmark.latlng, bookmark.zoom);
    //this._showBookmark(bookmark); //disablce by HS 20140427
  },

  /**
   * @param  {Object} bookmark
   */
  _removeBookmark: function(bookmark) {
    var self = this;
    this._data.splice(this._data.indexOf(bookmark), 1);
    this._storage.removeItem(bookmark.id, function(bookmark) {
      self._onBookmarkRemoved(bookmark);
    });
  },

  /**
   * @param  {Object} bookmark
   */
  _onBookmarkRemoved: function(bookmark) {
    var li = this._list.querySelector('.' +
        this.options.bookmarkTemplateOptions.itemClass +
        "[data-id='" + bookmark.id + "']"),
      self = this;

    this._map.fire('bookmark:removed', {
      data: bookmark
    });

    if (li) {
      L.DomUtil.setOpacity(li, 0);
      global.setTimeout(function() {
        li.parentNode.removeChild(li);
        if (self._data.length === 0) {
          self._setEmptyListContent();
        }
      }, 250);
    }
  },

  /**
   * Gets popup content
   * @param  {Object} bookmark
   * @return {String}
   */
  _getPopupContent: function(bookmark) {
    if (this.options.getPopupContent) {
      return this.options.getPopupContent.call(this, bookmark);
    } else {
      return JSON.stringify(bookmark);
    }
  },

  /**
   * @param  {Event} e
   */
  _onBookmarkClick: function(evt) {
    var bookmark = this._getBookmarkFromListItem(evt.delegateTarget);
    if (!bookmark) {
      return;
    }
    L.DomEvent.stopPropagation(evt);

    // remove button hit
    if (L.DomUtil.hasClass(evt.target || evt.srcElement,
        this.options.bookmarkTemplateOptions.removeClass)) {
      this._removeBookmark(bookmark);
    } else {

//        // HS - required if there's a selected boundary or point
//        if (currTarget) {
//            resetHighlight(currTarget);
//        }

      this._map.fire('bookmark:show', {
        data: bookmark
      });
      if (this.options.collapseOnClick) {
        this.collapse();
      }
    }
  },

  /**
   * In case you've decided to play with ids - we've got you covered
   * @param  {Element} li
   * @return {Object|Null}
   */
  _getBookmarkFromListItem: function(li) {
    if (this.options.getBookmarkFromListItem) {
      return this.options.getBookmarkFromListItem.call(this, li);
    } else {
      return this._getBookmark(li.getAttribute('data-id'));
    }
  },

  /**
   * GeoJSON feature out of a bookmark
   * @param  {Object} bookmark
   * @return {Object}
   */
  bookmarkToFeature: function(bookmark) {
    var coords = this._getBookmarkCoords(bookmark);
    bookmark = JSON.parse(JSON.stringify(bookmark)); // quick copy
    delete bookmark.latlng;

    return L.GeoJSON.getFeature({
      feature: {
        type: 'Feature',
        id: bookmark.id,
        properties: bookmark
      }
    }, {
      type: 'Point',
      coordinates: coords
    });
  },

  /**
   * @param  {Object} bookmark
   * @return {Array.<Number>}
   */
  _getBookmarkCoords: function(bookmark) {
    if (bookmark.latlng instanceof L.LatLng) {
      return [bookmark.latlng.lat, bookmark.latlng.lng];
    } else {
      return bookmark.latlng.reverse();
    }
  },

  /**
   * Read bookmarks from GeoJSON FeatureCollectio
   * @param  {Object} geojson
   * @return {Object}
   */
  fromGeoJSON: function(geojson) {
    var bookmarks = [];
    for (var i = 0, len = geojson.features.length; i < len; i++) {
      var bookmark = geojson.features[i];
      if (!bookmark.properties.divider) {
        bookmark.properties.latlng = bookmark.geometry.coordinates.concat().reverse();
      }
      bookmarks.push(bookmark.properties);
    }
    return bookmarks;
  },

  /**
   * @return {Object}
   */
  toGeoJSON: function() {
    var control = this;
    return {
      type: 'FeatureCollection',
      features: (function(data) {
        var result = [];
        for (var i = 0, len = data.length; i < len; i++) {
          if (!data[i].divider) {
            result.push(control.bookmarkToFeature(data[i]));
          }
        }
        return result;
      })(this._data)
    };
  }
});

module.exports = Bookmarks;

}).call(this,typeof global !== "undefined" ? global : typeof self !== "undefined" ? self : typeof window !== "undefined" ? window : {})
},{"./formpopup":3,"./leaflet.delegate":4,"./storage":6,"./string":8,"leaflet":undefined}],3:[function(require,module,exports){
(function (global){
var L = global.L || require('leaflet');
var substitute = require('./string').substitute;
var unique = require('./string').unique;

/**
 * New bookmark form popup
 *
 * @class  FormPopup
 * @extends {L.Popup}
 */
var FormPopup = L.Popup.extend( /** @lends FormPopup.prototype */ {

  /**
   * @type {Object}
   */
  options: {
    className: 'leaflet-bookmarks-form-popup',
    templateOptions: {
      formClass: 'leaflet-bookmarks-form',
      inputClass: 'leaflet-bookmarks-form-input',
      coordsClass: 'leaflet-bookmarks-form-coords',
      submitClass: 'leaflet-bookmarks-form-submit',
      inputPlaceholder: 'Bookmark name',
      submitText: '+'
    },
    generateNames: true,
    minWidth: 160,
    generateNamesPrefix: 'Bookmark ',
    template: '<form class="{{ formClass }}">' +
      '<div class="input-group"><input type="text" name="bookmark-name" ' +
      'placeholder="{{ inputPlaceholder }}" class="form-control {{ inputClass }}">' +
      '<button type="submit" class="input-group-addon {{ submitClass }}">' +
      '{{ submitText }}</button></div>' +
      '<div class="{{ coordsClass }}">{{ coords }}</div>' +
      '</form>'
  },

  /**
   * @param  {Object} options
   * @param  {L.Layer} source
   *
   * @constructor
   */
  initialize: function(options, source) {
    options.offset = this._calculateOffset(source, {});

    this._latlng = source.getLatLng();
    L.Popup.prototype.initialize.call(this, options, source);
  },

  /**
   * Correct offset from marker
   * @param  {L.Marker} source
   * @param  {Object}   options
   * @return {L.Point}
   */
  _calculateOffset: function(source, options) {
    var anchor = L.point(source.options.icon.options.popupAnchor || [0, 0]);
    anchor = anchor.add(this.options.offset);

    if (options && options.offset) {
      anchor = anchor.add(options.offset);
    }

    return anchor;
  },

  /**
   * Renders template only
   * @override
   */
  _updateContent: function() {
    this._content = substitute(this.options.template,
      L.Util.extend({}, this.options.templateOptions, {
        coords: this.formatCoords(
          this._source.getLatLng(),
          this._map.getZoom()
        )
      }));
    L.Popup.prototype._updateContent.call(this);

    var form = this._contentNode.querySelector('.' +
        this.options.templateOptions.formClass),
      input = form.querySelector('.' +
        this.options.templateOptions.inputClass);

    L.DomEvent.on(form, 'submit', this._onSubmit, this);

    setTimeout(function() {
      input.focus();
    }, 250);
  },

  /**
   * Creates bookmark object from form data
   * @return {Object}
   */
  _getBookmarkData: function() {
    if (this.options.getBookmarkData) {
      return this.options.getBookmarkData.call(this);
    } else {
      var input = this._contentNode.querySelector('.' +
        this.options.templateOptions.inputClass);

      return {
        latlng: this._source.getLatLng(),
        zoom: this._map.getZoom(),
        name: input.value,
        id: unique()
      };
    }
  },

  /**
   * Form submit, dispatch eventm close popup
   * @param {Event} evt
   */
  _onSubmit: function(evt) {
    L.DomEvent.stop(evt);

    var input = this._contentNode.querySelector('.' +
      this.options.templateOptions.inputClass);

    if (input.value === '' && this.options.generateNames) {
      input.value = unique(this.options.generateNamesPrefix);
    }

    if (input.value !== '') {
      var bookmark = this._getBookmarkData(),
        map = this._map;

      this._close();
      map.fire('bookmark:add', {
        data: bookmark
      });
    }
  },

  /**
   * @param  {L.LatLng} coords
   * @param  {Number=}  zoom
   * @return {String}
   */
  formatCoords: function(coords, zoom) {
    if (this.options.formatCoords) {
      return this.options.formatCoords.call(this, coords, zoom);
    } else {
      return [coords.lat.toFixed(4), coords.lng.toFixed(4), zoom]
        .join(',&nbsp;');
    }
  },

  /**
   * Hook to source movements
   * @param  {L.Map} map
   * @return {Element}
   */
  onAdd: function(map) {
    this._source.on('dragend', this._onSourceMoved, this);
    this._source.on('dragstart', this._onSourceMoveStart, this);
    return L.Popup.prototype.onAdd.call(this, map);
  },

  /**
   * @param  {L.Map} map
   */
  onRemove: function(map) {
    this._source.off('dragend', this._onSourceMoved, this);
    L.Popup.prototype.onRemove.call(this, map);
  },

  /**
   * Marker drag
   */
  _onSourceMoveStart: function() {
    this._container.style.display = 'none';
  },

  /**
   * Marker moved
   * @param  {Event} e
   */
  _onSourceMoved: function(e) {
    this._latlng = this._source.getLatLng();
    this._container.style.display = '';
    this.update();
  }
});

module.exports = FormPopup;

}).call(this,typeof global !== "undefined" ? global : typeof self !== "undefined" ? self : typeof window !== "undefined" ? window : {})
},{"./string":8,"leaflet":undefined}],4:[function(require,module,exports){
(function (global){
var L = global.L || require('leaflet');

/**
 * Courtesy of https://github.com/component/matches-selector
 */
var matchesSelector = (function(ElementPrototype) {
  var matches = ElementPrototype.matches ||
    ElementPrototype.webkitMatchesSelector ||
    ElementPrototype.mozMatchesSelector ||
    ElementPrototype.msMatchesSelector ||
    ElementPrototype.oMatchesSelector ||
    // hello IE
    function(selector) {
      var node = this,
        parent = (node.parentNode || node.document),
        nodes = parent.querySelectorAll(selector);

      for (var i = 0, len = nodes.length; i < len; ++i) {
        if (nodes[i] == node) return true;
      }
      return false;
    };

  /**
   * @param  {Element} element
   * @param  {String} selector
   * @return {Boolean}
   */
  return function(element, selector) {
    return matches.call(element, selector);
  };
})(Element.prototype);

/**
 * Courtesy of https://github.com/component/closest
 *
 * @param  {Element} element
 * @param  {String}  selector
 * @param  {Boolean} checkSelf
 * @param  {Element} root
 *
 * @return {Element|Null}
 */
function closest(element, selector, checkSelf, root) {
  element = checkSelf ? {
    parentNode: element
  } : element

  root = root || document;

  // Make sure `element !== document` and `element != null`
  // otherwise we get an illegal invocation
  while ((element = element.parentNode) && element !== document) {
    if (matchesSelector(element, selector)) {
      return element
    }
    // After `matches` on the edge case that
    // the selector matches the root
    // (when the root is not the document)
    if (element === root) {
      return null;
    }
  }
}

/**
 * Based on https://github.com/component/delegate
 *
 * @param  {Element}  el
 * @param  {String}   selector
 * @param  {String}   type
 * @param  {Function} fn
 *
 * @return {Function}
 */
L.DomEvent.delegate = function(el, selector, type, fn, bind) {
  return L.DomEvent.on(el, type, function(evt) {
    var target = evt.target || evt.srcElement;
    evt.delegateTarget = closest(target, selector, true, el);
    if (evt.delegateTarget && !evt.propagationStopped) {
      fn.call(bind || el, evt);
    }
  });
};

}).call(this,typeof global !== "undefined" ? global : typeof self !== "undefined" ? self : typeof window !== "undefined" ? window : {})
},{"leaflet":undefined}],5:[function(require,module,exports){
/**
 * @type {Object}
 */
var data = {};

/**
 * Object based storage
 * @class Storage.Engine.Global
 * @constructor
 */
var GlobalStorage = function(prefix) {

  /**
   * @type {String}
   */
  this._prefix = prefix;
};

/**
 * @param  {String}   key
 * @param  {Function} callback
 */
GlobalStorage.prototype.getItem = function(key, callback) {
  callback(data[this._prefix + key]);
};

/**
 * @param {String}   key
 * @param {*}        item
 * @param {Function} callback
 */
GlobalStorage.prototype.setItem = function(key, item, callback) {
  data[this._prefix + key] = item;
  callback(item);
};

/**
 * @param  {Function} callback
 */
GlobalStorage.prototype.getAllItems = function(callback) {
  var items = [];
  for (var key in data) {
    if (data.hasOwnProperty(key) && key.indexOf(this_prefix) === 0) {
      items.push(data[key]);
    }
  }
  callback(items);
};

/**
 * @param  {String}   key
 * @param  {Function} callback
 */
GlobalStorage.prototype.removeItem = function(key, callback) {
  var self = this;
  this.getItem(key, function(item) {
    if (item) {
      delete data[this._prefix + key];
    } else {
      item = null;
    }
    if (callback) {
      callback(item);
    }
  });
};

module.exports = GlobalStorage;

},{}],6:[function(require,module,exports){
(function (global){
var unique = require('./string').unique;

/**
 * Persistent storage, depends on engine choice: localStorage/ajax
 * @param {String} name
 */
var Storage = function(name, engineType) {

  if (typeof name !== 'string') {
    engineType = name;
    name = unique();
  }

  /**
   * @type {String}
   */
  this._name = name;

  /**
   * @type {Storage.Engine}
   */
  this._engine = Storage.createEngine(engineType,
    this._name, Array.prototype.slice.call(arguments, 2));
};

/**
 * @const
 * @enum {Number}
 */
Storage.engineType = {
  // XHR: 1, // we don't have it included
  GLOBAL: 2,
  LOCALSTORAGE: 3
};

/**
 * @constructor
 * @typedef {Storage.Engine}
 */
Storage.Engine = {
  //XHR: require('./storage.xhr'),
  Global: require('./storage.global'),
  LocalStorage: require('./storage.localstorage')
};

/**
 * Engine factory
 * @param  {Number} type
 * @param  {String} prefix
 * @return {Storage.Engine}
 */
Storage.createEngine = function(type, prefix, args) {
  if (type === Storage.engineType.GLOBAL) {
    return new Storage.Engine.Global(prefix);
  } else if (type === Storage.engineType.LOCALSTORAGE) {
    return new Storage.Engine.LocalStorage(prefix);
  }
};

/**
 * @param {String}   key
 * @param {*}        item
 * @param {Function} callback
 */
Storage.prototype.setItem = function(key, item, callback) {
  this._engine.setItem(key, item, callback);
  return this;
};

/**
 * @param  {String}   key
 * @param  {Function} callback
 */
Storage.prototype.getItem = function(key, callback) {
  this._engine.getItem(key, callback);
  return this;
};

/**
 * @param  {Function} callback
 */
Storage.prototype.getAllItems = function(callback) {
  this._engine.getAllItems(callback);
};

/**
 * @param  {String}   key
 * @param  {Function} callback
 */
Storage.prototype.removeItem = function(key, callback) {
  this._engine.removeItem(key, callback);
};

module.exports = global.Storage = Storage;

}).call(this,typeof global !== "undefined" ? global : typeof self !== "undefined" ? self : typeof window !== "undefined" ? window : {})
},{"./storage.global":5,"./storage.localstorage":7,"./string":8}],7:[function(require,module,exports){
/**
 * LocalStoarge based storage
 * @constructor
 */
var LocalStorage = function(prefix) {
  /**
   * @type {String}
   */
  this._prefix = prefix;

  /**
   * @type {LocalStorage}
   */
  this._storage = window.localStorage;
};

/**
 * @const
 * @type {RegExp}
 */
LocalStorage.JSON_RE = /^[\{\[](.)*[\]\}]$/;

/**
 * @param  {String}   key
 * @param  {Function} callback
 */
LocalStorage.prototype.getItem = function(key, callback) {
  var item = this._storage.getItem(this._prefix + key);
  if (item && LocalStorage.JSON_RE.test(item)) {
    item = JSON.parse(item);
  }
  callback(item);
};

/**
 * @param  {Function} callback
 */
LocalStorage.prototype.getAllItems = function(callback) {
  var items = [],
    prefixLength = this._prefix.length;
  for (var key in this._storage) {
    if (this._storage.getItem(key) !== null &&
      key.indexOf(this._prefix) === 0) {
      this.getItem(key.substring(prefixLength), function(item) {
        items.push(item);
      });
    }
  }
  callback(items);
};

/**
 * @param  {String}   key
 * @param  {Function} callback
 */
LocalStorage.prototype.removeItem = function(key, callback) {
  var self = this;
  this.getItem(key, function(item) {
    self._storage.removeItem(self._prefix + key);
    if (callback) {
      callback(item);
    }
  });
};

/**
 * @param  {String}   key
 * @param  {*}        item
 * @param  {Function} callback
 */
LocalStorage.prototype.setItem = function(key, item, callback) {
  var itemStr = item.toString();
  if (itemStr === '[object Object]') {
    itemStr = JSON.stringify(item)
  }
  this._storage.setItem(this._prefix + key, itemStr);
  callback(item);
};

module.exports = LocalStorage;

},{}],8:[function(require,module,exports){
/**
 * Substitutes {{ obj.field }} in strings
 *
 * @param  {String}  str
 * @param  {Object}  object
 * @param  {RegExp=} regexp
 * @return {String}
 */
function substitute(str, object, regexp) {
  return str.replace(regexp || (/{{([\s\S]+?)}}/g), function(match, name) {
    name = trim(name);

    if (name.indexOf('.') === -1) {
      if (match.charAt(0) == '\\') {
        return match.slice(1);
      }
      return (object[name] != null) ? object[name] : '';

    } else { // nested
      var result = object;
      name = name.split('.');
      for (var i = 0, len = name.length; i < len; i++) {
        if (name[i] in result) {
          result = result[name[i]];
        } else {
          return '';
        }
      }
      return result;
    }
  });
}

/**
 * Unique string from date. Puts character at the beginning,
 * for the sake of good manners
 *
 * @return {String}
 */
function unique(prefix) {
  var alpha = 'abcdefghijklmnopqrstuvwxyz';
  return (prefix || alpha[Math.floor(Math.random() * alpha.length)]) +
    (new Date()).getTime().toString(16);
}

/**
 * Trim whitespace
 * @param  {String} str
 * @return {String}
 */
function trim(str) {
  return str.replace(/^\s+|\s+$/g, '');
}

/**
 * Clean and trim
 * @param  {String} str
 * @return {String}
 */
function clean(str) {
  return trim(str.replace(/\s+/g, ' '));
}

module.exports = {
  substitute: substitute,
  trim: trim,
  clean: clean,
  unique: unique
};

},{}]},{},[1])(1)
});