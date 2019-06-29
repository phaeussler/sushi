// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

function initMap2() {
  var lat = document.getElementById("purchase_order_latitude").value;
  var lng = document.getElementById("purchase_order_longitude").value;

  // if not defined create default position
  if (!lat || !lng) {
    lat = -33.4991118;
    lng = -70.6183225;
    document.getElementById("purchase_order_latitude").value = lat;
    document.getElementById("purchase_order_longitude").value = lng;
  }

  var myCoords = new google.maps.LatLng(lat, lng);
  var mapOptions = {
    center: myCoords,
    zoom: 14
  };
  var map = new google.maps.Map(document.getElementById("map2"), mapOptions);
  var marker = new google.maps.Marker({
    position: myCoords,
    animation: google.maps.Animation.DROP,
    map: map,
    draggable: true
  });

  // when marker is dragged update input values
  marker.addListener("drag", function() {
    latlng = marker.getPosition();
    newlat = Math.round(latlng.lat() * 1000000) / 1000000;
    newlng = Math.round(latlng.lng() * 1000000) / 1000000;
    document.getElementById("purchase_order_latitude").value = newlat;
    document.getElementById("purchase_order_longitude").value = newlng;
  });
  // When drag ends, center (pan) the map on the marker position
  marker.addListener("dragend", function() {
    map.panTo(marker.getPosition());
  });
}
