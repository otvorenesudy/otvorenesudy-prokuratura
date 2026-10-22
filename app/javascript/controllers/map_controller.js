import { Controller } from '@hotwired/stimulus';
import { Turbo } from '@hotwired/turbo-rails';

const BORDER_STYLE = { fillColor: '#fff', color: '#ac3e53', opacity: 1, fillOpacity: 1 };
const TILES = 'https://tiles.stadiamaps.com/tiles/osm_bright/{z}/{x}/{y}{r}.png';
const ATTRIBUTION = '&copy; <a href="https://stadiamaps.com/">Stadia Maps</a>';

// A map of Slovakia, white beyond its border, with a marker per office (or per prosecutor, at their office), clustered
// where they're close. A marker's popup links to its record. On the prosecutors' map, a cluster of one office's
// prosecutors leads to that office's prosecutors in the listing. Leaflet and its plugins load here, on first use; the
// plugins extend the global L that Leaflet sets.
export default class extends Controller {
  static values = {
    markers: Array,
    border: String,
    icon: String,
    shadow: String,
    searchUrl: String,
    searchMessage: String,
  };

  async connect() {
    await import('leaflet');
    await import('leaflet.markercluster');
    await import('leaflet.snogylop');

    if (!this.element.isConnected) return;

    // A whole zoom level as the least: Leaflet.markercluster leaves out the markers that never cluster when it's
    // fractional.
    this.map = window.L.map(this.element, { zoomSnap: 0.05, zoomControl: false, minZoom: 7 });
    window.L.tileLayer(TILES, { attribution: ATTRIBUTION }).addTo(this.map);

    await this.addBorder();
    if (!this.element.isConnected) return;

    this.addMarkers();
  }

  disconnect() {
    clearTimeout(this.visit);
    window.removeEventListener('resize', this.fit);
    this.map?.remove();
  }

  async addBorder() {
    const response = await fetch(this.borderValue);
    if (!response.ok) throw new Error(`The map's border at ${this.borderValue} answered ${response.status}`);

    const geojson = await response.json();

    // A visit away while the border loaded removed the map.
    if (!this.element.isConnected) return;

    const border = window.L.geoJSON(geojson, { invert: true, style: BORDER_STYLE }).addTo(this.map);

    this.fit = () => this.map.fitBounds(border.getBounds());
    this.fit();
    window.addEventListener('resize', this.fit);
  }

  addMarkers() {
    const { L } = window;
    const icon = L.icon({
      iconUrl: this.iconValue,
      shadowUrl: this.shadowValue,
      iconSize: [20, 33],
      iconAnchor: [10, 33],
      popupAnchor: [1, -34],
      shadowSize: [33, 33],
    });

    const clusters = L.markerClusterGroup({
      spiderfyOnMaxZoom: !this.searchUrlValue,
      showCoverageOnHover: false,
      spiderLegPolylineOptions: { weight: 1.5, color: '#fff', opacity: 0 },
    });

    this.markersValue.forEach((attributes) => {
      const marker = L.marker(attributes.coordinates, { icon, title: attributes.name });

      marker.bindPopup(popup(attributes));
      marker.on('mouseover', () => marker.openPopup());
      marker.attributes = attributes;

      clusters.addLayer(marker);
    });

    clusters.on('clusterclick', (event) => this.openCluster(event.layer));
    this.map.addLayer(clusters);
  }

  // Zooms in on a cluster; when all its markers share one place (an office's prosecutors) and the page searches,
  // leads to them in the listing.
  openCluster(cluster) {
    this.map.fitBounds(cluster.getBounds().pad(0.25));

    const markers = cluster.getAllChildMarkers();
    const places = new Set(markers.map((marker) => marker.getLatLng().toString()));

    if (places.size !== 1 || !this.searchUrlValue) return;

    window.L.popup().setLatLng(markers[0].getLatLng()).setContent(message(this.searchMessageValue)).openOn(this.map);

    const url = new URL(this.searchUrlValue, window.location.origin);
    new Set(markers.map((marker) => marker.attributes.office)).forEach((office) => {
      url.searchParams.append('office[]', office);
    });
    url.hash = 'facets';

    this.visit = setTimeout(() => Turbo.visit(url.toString()), 2000);
  }
}

// The popup's content, built as elements: the names and addresses are imported data, never HTML.
function popup({ name, url, address }) {
  const content = document.createElement('div');
  const link = document.createElement('a');
  const title = document.createElement('b');

  title.textContent = name;
  link.href = url;
  link.append(title);
  content.append(link, document.createElement('br'), address);

  return content;
}

function message(text) {
  const paragraph = document.createElement('p');
  paragraph.textContent = text;

  return paragraph;
}
