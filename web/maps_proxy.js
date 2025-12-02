(function (global) {
  function ensureSdk(key) {
    if (!key) {
      return Promise.reject(new Error('Google Maps API key no proporcionada.'));
    }

    if (global._vaneluxMapsReadyPromise) {
      return global._vaneluxMapsReadyPromise;
    }

    global._vaneluxMapsReadyPromise = new Promise(function (resolve, reject) {
      function checkReady(attempts) {
        if (global.google && global.google.maps && global.google.maps.places) {
          resolve();
          return;
        }
        if (attempts > 120) {
          reject(new Error('El SDK de Google Maps no se cargó a tiempo.'));
          return;
        }
        setTimeout(function () {
          checkReady(attempts + 1);
        }, 100);
      }

      var scriptId = 'vanelux-google-maps-sdk';
      if (!document.getElementById(scriptId)) {
        var script = document.createElement('script');
        script.id = scriptId;
        script.src = 'https://maps.googleapis.com/maps/api/js?key=' + key + '&libraries=places';
        script.async = true;
        script.defer = true;
        script.onerror = function () {
          reject(new Error('No se pudo cargar Google Maps JavaScript API.'));
        };
        script.onload = function () {
          checkReady(0);
        };
        document.head.appendChild(script);
      } else {
        checkReady(0);
      }
    });

    return global._vaneluxMapsReadyPromise;
  }

  function withSdk(key, executor) {
    return ensureSdk(key).then(function () {
      return new Promise(function (resolve, reject) {
        try {
          executor(resolve, reject);
        } catch (err) {
          reject(err);
        }
      });
    });
  }

  function normalizePrediction(prediction) {
    return {
      description: prediction.description || '',
      place_id: prediction.place_id,
      structured_formatting: prediction.structured_formatting || null,
      types: prediction.types || [],
      terms: prediction.terms || [],
      matched_substrings: prediction.matched_substrings || [],
    };
  }

  function normalizeDistance(element) {
    var distance = element.distance || {};
    var duration = element.duration || {};
    return {
      distance: distance.text || '',
      distance_value: distance.value || 0,
      duration: duration.text || '',
      duration_value: duration.value || 0,
    };
  }

  function normalizePlaceDetails(result) {
    return {
      name: result.name || '',
      address: result.formatted_address || '',
      location: result.geometry && result.geometry.location
        ? { lat: result.geometry.location.lat(), lng: result.geometry.location.lng() }
        : null,
      phone: result.formatted_phone_number || null,
      rating: result.rating || 0,
      website: result.website || null,
    };
  }

  function normalizeGeocode(result) {
    return {
      address: result.formatted_address || '',
      location: result.geometry && result.geometry.location
        ? { lat: result.geometry.location.lat(), lng: result.geometry.location.lng() }
        : null,
      place_id: result.place_id || null,
    };
  }

  function createPlacesService() {
    if (!global._vaneluxPlacesDiv) {
      var div = document.createElement('div');
      div.style.display = 'none';
      document.body.appendChild(div);
      global._vaneluxPlacesDiv = div;
    }
    // eslint-disable-next-line new-cap
    return new global.google.maps.places.PlacesService(global._vaneluxPlacesDiv);
  }

  global.vaneluxMaps = {
    ensureSdk: ensureSdk,
    searchPlaces: function (key, query) {
      if (!query || !query.trim()) {
        return Promise.resolve([]);
      }
      return withSdk(key, function (resolve, reject) {
        var service = new global.google.maps.places.AutocompleteService();
        service.getPlacePredictions(
          {
            input: query,
            componentRestrictions: { country: 'us' },
            language: 'es',
          },
          function (predictions, status) {
            if (status === global.google.maps.places.PlacesServiceStatus.OK) {
              resolve((predictions || []).map(normalizePrediction));
            } else if (status === global.google.maps.places.PlacesServiceStatus.ZERO_RESULTS) {
              resolve([]);
            } else {
              reject(new Error('Google Autocomplete error: ' + status));
            }
          },
        );
      });
    },
    distanceMatrix: function (key, origin, destination) {
      return withSdk(key, function (resolve, reject) {
        var service = new global.google.maps.DistanceMatrixService();
        service.getDistanceMatrix(
          {
            origins: [origin],
            destinations: [destination],
            travelMode: global.google.maps.TravelMode.DRIVING,
            unitSystem: global.google.maps.UnitSystem.IMPERIAL,
          },
          function (response, status) {
            if (status === global.google.maps.DistanceMatrixStatus.OK) {
              var rows = (response.rows || []);
              if (rows.length && rows[0].elements && rows[0].elements.length) {
                resolve(normalizeDistance(rows[0].elements[0]));
              } else {
                reject(new Error('Respuesta de Distance Matrix incompleta.'));
              }
            } else {
              reject(new Error('Google Distance Matrix error: ' + status));
            }
          },
        );
      });
    },
    placeDetails: function (key, placeId) {
      return withSdk(key, function (resolve, reject) {
        var service = createPlacesService();
        service.getDetails(
          {
            placeId: placeId,
            fields: [
              'name',
              'formatted_address',
              'geometry.location',
              'formatted_phone_number',
              'rating',
              'website',
            ],
          },
          function (result, status) {
            if (status === global.google.maps.places.PlacesServiceStatus.OK) {
              resolve(normalizePlaceDetails(result));
            } else {
              reject(new Error('Google Place Details error: ' + status));
            }
          },
        );
      });
    },
    reverseGeocode: function (key, latitude, longitude) {
      return withSdk(key, function (resolve, reject) {
        var geocoder = new global.google.maps.Geocoder();
        geocoder.geocode(
          {
            location: { lat: latitude, lng: longitude },
          },
          function (results, status) {
            if (status === global.google.maps.GeocoderStatus.OK) {
              if (results && results.length) {
                resolve(normalizeGeocode(results[0]));
              } else {
                reject(new Error('Sin resultados de geocodificación.'));
              }
            } else {
              reject(new Error('Google Geocoding error: ' + status));
            }
          },
        );
      });
    },
    renderRouteMap: function (key, elementId, origin, destination, options) {
      return withSdk(key, function (resolve, reject) {
        if (!origin || !destination) {
          reject(new Error('Origen o destino no proporcionados para el mapa.'));
          return;
        }

        var element = document.getElementById(elementId);
        if (!element) {
          reject(new Error('No se encontró el contenedor del mapa.'));
          return;
        }

        element.innerHTML = '';

        var map = new global.google.maps.Map(element, {
          mapTypeControl: false,
          fullscreenControl: false,
          streetViewControl: false,
          zoomControl: true,
          gestureHandling: 'greedy',
          center: origin,
        });

        var bounds = new global.google.maps.LatLngBounds();
        bounds.extend(new global.google.maps.LatLng(origin.lat, origin.lng));
        bounds.extend(new global.google.maps.LatLng(destination.lat, destination.lng));
        var padding = options && options.fitPadding ? options.fitPadding : 60;
        map.fitBounds(bounds, padding);

        var directionsService = new global.google.maps.DirectionsService();
        var directionsRenderer = new global.google.maps.DirectionsRenderer({
          map: map,
          suppressMarkers: false,
          polylineOptions: {
            strokeColor: (options && options.strokeColor) || '#0B3254',
            strokeWeight: (options && options.strokeWeight) || 5,
          },
        });

        directionsService.route(
          {
            origin: origin,
            destination: destination,
            travelMode: global.google.maps.TravelMode.DRIVING,
          },
          function (result, status) {
            if (status === 'OK') {
              directionsRenderer.setDirections(result);
              resolve();
            } else {
              reject(new Error('Google Directions error: ' + status));
            }
          },
        );
      });
    },
  };
})(window);
