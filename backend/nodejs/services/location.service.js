const fetch = (...args) => import('node-fetch').then(({ default: nodeFetch }) => nodeFetch(...args));

const GOOGLE_API_KEY = process.env.GOOGLE_MAPS_API_KEY;

/**
 * Resolve user location using Google Maps Geocoding API.
 * Falls back to mock data when API key is not configured or request fails.
 * @param {string|object} rawInput
 * @returns {Promise<{city: string, region: string, lat: number, lng: number}>}
 */
async function resolveUserLocation(rawInput) {
  if (!rawInput) {
    return null;
  }

  if (!GOOGLE_API_KEY) {
    return mockLocation(rawInput);
  }

  try {
    const query = typeof rawInput === 'string'
      ? `address=${encodeURIComponent(rawInput)}`
      : rawInput.lat && rawInput.lng
        ? `latlng=${rawInput.lat},${rawInput.lng}`
        : `address=${encodeURIComponent(JSON.stringify(rawInput))}`;

    const url = `https://maps.googleapis.com/maps/api/geocode/json?${query}&key=${GOOGLE_API_KEY}`;
    const response = await fetch(url);
    const data = await response.json();

    if (data.status === 'OK' && data.results.length > 0) {
      const result = data.results[0];
      const location = result.geometry.location;
      const components = parseAddressComponents(result.address_components);

      return {
        city: components.locality || components.subLocality || 'Unknown City',
        region: components.administrativeArea || 'Unknown Region',
        lat: location.lat,
        lng: location.lng,
      };
    }

    return mockLocation(rawInput);
  } catch (error) {
    console.error('Google Maps API error:', error.message);
    return mockLocation(rawInput);
  }
}

function parseAddressComponents(components = []) {
  const map = {};
  components.forEach(component => {
    if (component.types.includes('locality')) {
      map.locality = component.long_name;
    }
    if (component.types.includes('sublocality') || component.types.includes('sublocality_level_1')) {
      map.subLocality = component.long_name;
    }
    if (component.types.includes('administrative_area_level_1')) {
      map.administrativeArea = component.long_name;
    }
  });
  return map;
}

function mockLocation(rawInput) {
  return {
    city: typeof rawInput === 'string' ? rawInput : 'Demo City',
    region: 'Demo Region',
    lat: 12.9716,
    lng: 77.5946,
  };
}

module.exports = {
  resolveUserLocation,
};

