import { Controller } from "stimulus";
import sanitize from "sanitize-html";

export default class extends Controller {
  async connect() {
    this.map = L.map(this.element.getAttribute("id"), {
      zoomSnap: 0.05,
      zoomControl: false,
      scrollZoomControl: false,
      minZoom: 7.5,
    });

    await this._addGeoJSON();
    this._addMarkers();
  }

  async _addGeoJSON() {
    const data = await (await fetch("/data/slovakia.geojson")).json();

    const group = L.geoJSON(data, {
      invert: true,
      style: {
        fillColor: "#fff",
        color: "#ac3e53",
        opacity: 1,
        fillOpacity: 1,
      },
      definesBounds: true,
    }).addTo(this.map);

    this.map.addLayer(
      new L.tileLayer("https://tiles.stadiamaps.com/tiles/osm_bright/{z}/{x}/{y}{r}.png", {
        attribution: '&copy; <a href="https://stadiamaps.com/" target="_blank">Stadia Maps</a>',
      })
    );

    (window.onresize = () => {
      group.eachLayer((layer) => {
        if (layer.options.definesBounds) {
          this.map.fitBounds(layer.getBounds());
        }
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
      spiderfyOnMaxZoom: this.element.getAttribute("data-search-on-cluster-opening") ? false : true,
      showCoverageOnHover: false,
      spiderLegPolylineOptions: { weight: 1.5, color: "#fff", opacity: 0 },
    });

    data.map((attributes) => {
      const { name, url, address, coordinates, office } = attributes;
      const marker = new L.Marker(new L.LatLng(...coordinates), { icon });

      marker.bindPopup(sanitize(`<a href="${url}"><b>${name}</b></a><br>${address}`));
      marker.attributes = attributes;

      marker.on("mouseover", () => marker.openPopup());

      markers.addLayer(marker);
    });

    this.map.addLayer(markers);

    markers.on("clusterclick", (cluster) => {
      const bounds = cluster.layer.getBounds().pad(0.25);

      this.map.fitBounds(bounds);

      const locations = cluster.layer
        .getAllChildMarkers()
        .reduce((acc, e) => ({ ...acc, [e.getLatLng().lat]: 1, [e.getLatLng().lng]: 1 }), {});
      const url = this.element.getAttribute("data-search-on-cluster-opening");

      if (Object.keys(locations).length === 2 && url) {
        L.popup()
          .setLatLng({ lat: Object.keys(locations)[0], lng: Object.keys(locations)[1] })
          .setContent(sanitize(`<p>${this.element.getAttribute("data-search-on-cluster-opening-message")}</p>`))
          .openOn(this.map);

        const offices = [...new Set(cluster.layer.getAllChildMarkers().map((marker) => marker.attributes.office))];
        const params = offices.map((office) => encodeURI(`office[]=${office}`));

        setTimeout(() => Turbolinks.visit(`${url.split("#")[0]}&${params.join("&")}#facets`), 2000);
      }
    });
  }
}
