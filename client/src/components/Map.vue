<script setup>
import { ref, onMounted, watchEffect} from 'vue'
import {Map, View} from 'ol';
import TileLayer from 'ol/layer/Tile';
import VectorLayer from 'ol/layer/Vector';
import VectorSource from 'ol/source/Vector';
import { LineString, Polygon } from 'ol/geom';
import {Feature} from 'ol';
import OSM from 'ol/source/OSM';
import {fromLonLat} from 'ol/proj';
import {Style, Fill, Stroke } from 'ol/style'

const props = defineProps(['position', 'track', 'highlight']);

const mapContainer = ref(null)

let trackLine = null;
const trackLineStyle = new Style({
    stroke: new Stroke({ color: '#FF0000', width: 2 })
});

let highlight = null;
const highlightStyle = new Style({
    stroke: new Stroke({ color: '#000000', width: 2 })
});


let boatSymbol = null;const boatSymbolStyle = new Style({
    fill: new Fill({ color: '#0000FF', weight: 4 }),
    stroke: new Stroke({ color: '#0000FF', width: 2 })
});

const source = new VectorSource({wrapX: false});

const view = new View({ 
    zoom: 17
});

function drawLine (points) {
    points = points.map(p => fromLonLat([p.longitude, p.latitude]));
    return new LineString(points);
}

function drawBoatSymbole () {
    if (boatSymbol != null) source.removeFeature(boatSymbol);
    let [x, y] = fromLonLat([props.position.longitude, props.position.latitude]);
    let p1 = [x - 5, y];
    let p2 = [x + 5, y];
    let p3 = [x, y + 20];
    boatSymbol = new Feature(new Polygon([[p1, p2, p3, p1]]));
    boatSymbol.setStyle()
    source.addFeature(boatSymbol);

}

function drawTrackLine () {
    if (trackLine !== null) source.removeFeature(trackLine)
    if (props.track.length > 0) {
        trackLine = new Feature(drawLine(props.track));
        trackLine.setStyle(trackLineStyle);
        source.addFeature(trackLine);
    } else {
        trackLine = null;
    }
}

function drawHighlight () {
    if (highlight !== null) source.removeFeature(highlight)
    if (props.highlight.length > 0) {
        highlight = new Feature(drawLine(props.highlight));
        highlight.setStyle(highlightStyle);
        source.addFeature(highlight);
    } else {
        highlight = null;
    }
}


watchEffect( () => {
    view.setCenter(fromLonLat([props.position.longitude, props.position.latitude]))
    drawBoatSymbole();
    drawTrackLine();
    drawHighlight();
});



const map = new Map({
        layers: [
            new TileLayer({
                source: new OSM()
            }),
            new VectorLayer({
                source: source,
            })
        ],
        view
    });

onMounted(() => {
   map.setTarget(mapContainer.value);
})
</script>

<template>
    <div>
        <div id="map" ref="mapContainer"></div>
        position: {{ props.position.latitude }}, {{ props.position.longitude }}; track length: {{ props.track.length }}
    </div>    
</template>

<style>
    #map {
        width: 600px;
        height: 400px;
    } 
</style>