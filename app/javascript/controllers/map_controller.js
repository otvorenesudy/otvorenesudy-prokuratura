import { Controller } from "stimulus";
import sanitize from "sanitize-html";

export default class extends Controller {
  async initialize() {
    this.map = L.map(this.element.getAttribute("id"), {
      zoomSnap: 0.05,
      zoomControl: false,
      scrollZoomControl: false,
    });

    this.map.addLayer(
      new L.tileLayer("https://tiles.stadiamaps.com/tiles/osm_bright/{z}/{x}/{y}{r}.png", {
        attribution:
          '&copy; <a href="https://stadiamaps.com/">Stadia Maps</a>, &copy; <a href="https://openmaptiles.org/">OpenMapTiles</a> &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors',
      })
    );

    await this._addGeoJSON();
    this._addMarkers();
  }

  async _addGeoJSON() {
    const data = await (await fetch("/data/slovakia.geojson")).json();

    const group = L.geoJSON(data, {
      invert: true,
      style: {
        fillColor: "#ac3e53",
        color: "#ac3e53",
      },
    }).addTo(this.map);

    (window.onresize = () => {
      group.eachLayer((layer) => {
        this.map.fitBounds(layer.getBounds());
      });
    })();
  }

  _addMarkers() {
    const icon = new L.Icon({
      iconUrl: "/images/marker.png",
      shadowUrl: "https://cdnjs.cloudflare.com/ajax/libs/leaflet/0.7.7/images/marker-shadow.png",
      iconSize: [20, 33],
      iconAnchor: [10, 33],
      popupAnchor: [1, -34],
      shadowSize: [33, 33],
    });

    const data = JSON.parse(this.element.getAttribute("data-json"));
    const markers = new L.MarkerClusterGroup({
      spiderfyOnMaxZoom: true,
      showCoverageOnHover: false,
      spiderLegPolylineOptions: { weight: 1.5, color: "#fff", opacity: 0 },
    });

    data.map(({ name, address, coordinates }) => {
      const marker = new L.Marker(new L.LatLng(...coordinates), { icon });

      marker.bindPopup(sanitize(`<b>${name}</b><br>${address}`));

      marker.on("mouseover", () => marker.openPopup());
      marker.on("mouseout", () => marker.closePopup());

      markers.addLayer(marker);
    });

    this.map.addLayer(markers);
  }
}
