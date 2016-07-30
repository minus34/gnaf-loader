var restUrl = "geoms.json";
var map1 = null;
var map2 = null;
var info = null;
var geojsonLayer1 = null;
var geojsonLayer2 = null;
var minZoom = 4;
var maxZoom = 10;

var colours = ['#edf8fb','#ccece6','#99d8c9','#66c2a4','#41ae76','#238b45','#005824'];
var themeGrades = [2, 4, 6, 8, 10, 12, 14]


function init() {
    //Initialize the map on the "map" div
    map1 = new L.Map('map1', { attributionControl: false });
    map2 = new L.Map('map2', { zoomControl:false });

    // load CartoDB basemap tiles
    var tiles1 = L.tileLayer('http://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png', {
        subdomains: 'abcd',
        minZoom: minZoom,
        maxZoom: maxZoom
    });

    var tiles2 = L.tileLayer('http://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png', {
        attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a> &copy; <a href="http://cartodb.com/attributions">CartoDB</a>',
        subdomains: 'abcd',
        minZoom: minZoom,
        maxZoom: maxZoom
    });

    map1.addLayer(tiles1);
    map2.addLayer(tiles2);

    //Set the view to a given center and zoom
    startPoint = new L.LatLng(-27.47, 153.10)
    map1.setView(startPoint, 9);
    map2.setView(startPoint, 9);

    // set move events to update the other map when we move this one
    map1.on('moveend', function(e) {
        map2.setView(map1.getCenter(), map1.getZoom());
    });
    map2.on('moveend', function(e) {
        map1.setView(map2.getCenter(), map2.getZoom());
    });

    //Add legend control
    var legend = L.control({ position: 'bottomright' });
    legend.onAdd = function (map2) {

        var div = L.DomUtil.create('div', ' info legend'),
            labels = [],
            from,
            to;

        for (var i = 0; i < themeGrades.length; i++) {
            from = themeGrades[i] - 1;
            to = themeGrades[i + 1];

            labels.push('<i style="background:' + getColor(from) + '"></i>' + parseInt(from) + (to ? '%': '%+'));
        }

        div.innerHTML = "<div id='mapLegend'>" + labels.join('<br/>') + '</div>';

        return div;
    };

    legend.addTo(map2);

    // Get bookmarks/
    var storage = {
        getAllItems: function(callback) {
             $.getJSON('bookmarks.json',
                function(json) {
                    callback(json);
                }
            );
        }
    };

    //Add bookmark control
    var bmControl = new L.Control.Bookmarks({
      position: 'topleft',
      localStorage: false,
      storage: storage
    }).addTo(map1);

    //Acknowledge the Data
    map2.attributionControl.addAttribution('&copy; <a href="http://data.gov.au/dataset/psma-administrative-boundaries">PSMA</a>');
    map2.attributionControl.addAttribution('&copy; <a href="http://www.abs.gov.au/websitedbs/censushome.nsf/4a256353001af3ed4b2562bb00121564/datapacksdetails?opendocument&navpos=250">ABS</a>');
    map2.attributionControl.addAttribution('&copy; <a href="http://vtr.aec.gov.au/SenateDownloadsMenu-20499-Csv.htm">AEC</a>');

    info2 = L.control();
    info2.onAdd = function (map2) {
        this._div = L.DomUtil.create('div', 'info');
        this.update();
        return this._div;
    };
    info2.update = function (props) {
        this._div.innerHTML = (props ? '<b>' + props.name + '</b><br/><b>Nationalist voters</b> : '
                                             + props.percent.toLocaleString(['en-AU'])
                                             + '%</b><br/><b>Islamic People</b> : '
                                             + props.pop_percent.toLocaleString(['en-AU']) + '%' : 'pick a boundary');
    };
    info2.addTo(map2);

    // //Get a new set of boundaries when map panned or zoomed
    // //TO DO: Handle map movement due to popup
    // map1.on('moveend', function (e) {
    //     getBoundaries();
    // });
    //
    // map1.on('zoomend', function (e) {
    //     map1.closePopup();
    //     //getBoundaries();
    // });

    //Get the first set of boundaries
    getBoundaries();
}

function style1(feature) {
    var renderVal = parseInt(feature.properties.percent);

    return {
        weight: 1,
        opacity: 0.4,
        color: '#666',
        fillOpacity: 0.7,
        fillColor: getColor(renderVal)
    };
}

function style2(feature) {
    var renderVal = parseInt(feature.properties.pop_percent);

    return {
        weight: 1,
        opacity: 0.4,
        color: '#666',
        fillOpacity: 0.7,
        fillColor: getColor(renderVal)
    };
}



 // get color depending on ratio of count versus max value
 function getColor(d) {
   return d > 12 ? colours[6]:
          d > 10 ? colours[5]:
          d > 8 ? colours[4]:
          d > 6 ? colours[3]:
          d > 4 ? colours[2]:
          d > 2 ? colours[1]:
                  colours[0];
 }

function highlightFeature1(e) {
    var layer1 = e.target;

    layer1.setStyle({
        color: '#444',
        weight: 2,
        opacity: 0.9,
        fillOpacity: 0.7
    });

    var match = geojsonLayer2.eachLayer(function(layer2) {
        if (layer2.feature.properties.name == layer1.feature.properties.name) {
            layer2.setStyle({
                color: '#444',
                weight: 2,
                opacity: 0.9,
                fillOpacity: 0.7
            });

            if (!L.Browser.ie && !L.Browser.opera) {
                layer2.bringToFront();
            }
        }
    });

    if (!L.Browser.ie && !L.Browser.opera) {
        layer1.bringToFront();
    }

    info2.update(layer1.feature.properties);
}

function highlightFeature2(e) {
    var layer2 = e.target;

    layer2.setStyle({
        color: '#444',
        weight: 2,
        opacity: 0.9,
        fillOpacity: 0.7
    });

    var match = geojsonLayer1.eachLayer(function(layer1) {
        if (layer1.feature.properties.name == layer2.feature.properties.name) {
        layer1.setStyle({
            color: '#444',
            weight: 2,
            opacity: 0.9,
            fillOpacity: 0.7
        });

        if (!L.Browser.ie && !L.Browser.opera) {
            layer1.bringToFront();
        }
    }
    });

if (!L.Browser.ie && !L.Browser.opera) {
        layer2.bringToFront();
    }

    info2.update(layer2.feature.properties);
}

function resetHighlight1(e) {
    var layer1 = e.target
    geojsonLayer1.resetStyle(layer1);

    var match = geojsonLayer2.eachLayer(function(layer2) {
        if (layer2.feature.properties.name == layer1.feature.properties.name) {
            geojsonLayer2.resetStyle(layer2);
        }
    });

    info2.update();
}

function resetHighlight2(e) {
    var layer2 = e.target
    geojsonLayer2.resetStyle(layer2);

    var match = geojsonLayer1.eachLayer(function(layer1) {
        if (layer1.feature.properties.name == layer2.feature.properties.name) {
            geojsonLayer1.resetStyle(layer1);
        }
    });

    info2.update();
}

function onEachFeature1(feature, layer) {
    layer.on({
        mouseover: highlightFeature1,
        mouseout: resetHighlight1
    });
}

function onEachFeature2(feature, layer) {
    layer.on({
        mouseover: highlightFeature2,
        mouseout: resetHighlight2
    });
}

function getBoundaries() {
    console.time("got boundaries");

    //Fire off AJAX request
    $.getJSON(restUrl, loadBdysNew);
}

function loadBdysNew(json) {

    console.timeEnd("got boundaries");
    console.time("parsed GeoJSON");

    geojsonLayer1 = L.geoJson(json, {
        style: style1,
        onEachFeature: onEachFeature1
    }).addTo(map1);

    geojsonLayer2 = L.geoJson(json, {
        style: style2,
        onEachFeature: onEachFeature2
    }).addTo(map2);

    console.timeEnd("parsed GeoJSON");
}

