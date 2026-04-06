exports.handler = async (event) => {
  const responseHeaders = {
    'Content-Type': 'application/json',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'Content-Type',
    'Access-Control-Allow-Methods': 'POST,OPTIONS',
  };

  const jsonResponse = (statusCode, payload) => ({
    statusCode,
    headers: responseHeaders,
    body: JSON.stringify(payload),
  });

  if (event.httpMethod === 'OPTIONS') {
    return jsonResponse(200, {});
  }

  if (event.httpMethod !== 'POST') {
    return jsonResponse(405, { error: 'Method not allowed' });
  }

  const tollGuruApiKey = process.env.TOLLGURU_API_KEY;
  if (!tollGuruApiKey) {
    return jsonResponse(500, {
      has_tolls: false,
      toll_cost: 0.0,
      toll_unavailable: true,
      error: 'TOLLGURU_API_KEY is missing on server',
    });
  }

  try {
    const body = JSON.parse(event.body || '{}');
    const origin = String(body.origin || '').trim();
    const destination = String(body.destination || '').trim();

    const from = body?.from && typeof body.from === 'object'
      ? body.from
      : (origin ? { address: origin } : null);
    const to = body?.to && typeof body.to === 'object'
      ? body.to
      : (destination ? { address: destination } : null);

    if (!from || !to) {
      return jsonResponse(400, {
        has_tolls: false,
        toll_cost: 0.0,
        toll_unavailable: true,
        error: 'origin and destination are required',
      });
    }

    const allowedProviders = new Set(['here', 'gmaps', 'tollguru']);
    const requestedProvider = String(body.serviceProvider || 'here').trim().toLowerCase();
    const serviceProvider = allowedProviders.has(requestedProvider) ? requestedProvider : 'here';

    const vehicleTypeRaw =
      body?.vehicle?.type ??
      body?.vehicleType ??
      '2AxlesAuto';
    const vehicleType = String(vehicleTypeRaw).trim() || '2AxlesAuto';

    const waypointCandidates = Array.isArray(body.waypoints) ? body.waypoints : [];
    const waypoints = waypointCandidates
      .map((waypoint) => {
        if (typeof waypoint === 'string' && waypoint.trim()) {
          return { address: waypoint.trim() };
        }
        if (!waypoint || typeof waypoint !== 'object') {
          return null;
        }

        const address = typeof waypoint.address === 'string' ? waypoint.address.trim() : '';
        const placeId = typeof waypoint.placeId === 'string' ? waypoint.placeId.trim() : '';
        const lat = Number.parseFloat(waypoint.lat);
        const lng = Number.parseFloat(waypoint.lng);

        if (address) return { address };
        if (placeId) return { placeId };
        if (Number.isFinite(lat) && Number.isFinite(lng)) {
          return { lat, lng };
        }
        return null;
      })
      .filter(Boolean);

    const departureInput = body.departureTime || body.departure_time;
    const departureDate = departureInput ? new Date(departureInput) : new Date();
    const departureTime = Number.isNaN(departureDate.getTime())
      ? new Date().toISOString()
      : departureDate.toISOString();

    const requestPayload = {
      from,
      to,
      serviceProvider,
      vehicle: { type: vehicleType },
      departureTime,
    };

    if (waypoints.length > 0) {
      requestPayload.waypoints = waypoints;
    }

    const response = await fetch('https://apis.tollguru.com/toll/v2/origin-destination-waypoints', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': tollGuruApiKey,
      },
      body: JSON.stringify(requestPayload),
    });

    const rawText = await response.text();
    let data = {};
    try {
      data = rawText ? JSON.parse(rawText) : {};
    } catch (_) {
      data = {};
    }
    if (!response.ok) {
      const statusCode = response.status;
      const errorCode = String(data?.code || '').trim();
      const errorValue = String(data?.value || data?.error || '').trim();

      let detailedError = errorValue || `TollGuru request failed (HTTP ${statusCode})`;
      if (statusCode === 403) {
        detailedError =
          errorValue ||
          'Request denied by TollGuru (403). Verify active subscription/trial and API key permissions.';
      }

      return jsonResponse(statusCode, {
        has_tolls: false,
        toll_cost: 0.0,
        toll_unavailable: true,
        error: detailedError,
        status_code: statusCode,
        error_code: errorCode || null,
      });
    }

    const apiStatus = String(data?.status || '').trim().toUpperCase();
    if (apiStatus && apiStatus !== 'OK') {
      return jsonResponse(502, {
        has_tolls: false,
        toll_cost: 0.0,
        toll_unavailable: true,
        error: String(data?.value || data?.error || 'Unexpected TollGuru status'),
        error_code: String(data?.code || '').trim() || null,
      });
    }

    const routes = Array.isArray(data?.routes) ? data.routes : [];
    const route = routes[0] || {};
    const summary = route.summary || {};
    const costs = route.costs || {};
    const tolls = Array.isArray(route.tolls) ? route.tolls : [];

    const parseCost = (value) => {
      const number = Number.parseFloat(value ?? 0);
      return Number.isFinite(number) ? number : 0;
    };

    const orderedCostCandidates = [
      costs.licensePlate,
      costs.tag,
      costs.cash,
      costs.prepaidCard,
      costs.tagAndCash,
      costs.minimumTollCost,
      costs.maximumTollCost,
    ];

    let tollCost = 0;
    for (const candidate of orderedCostCandidates) {
      const value = parseCost(candidate);
      if (value > 0) {
        tollCost = value;
        break;
      }
    }

    const hasTolls =
      Boolean(summary.hasTolls) || tollCost > 0 || tolls.length > 0;

    return jsonResponse(200, {
      has_tolls: hasTolls,
      toll_cost: tollCost,
      toll_unavailable: false,
      toll_count: tolls.length,
      currency: String(data?.summary?.currency || '').trim() || null,
      service_provider: String(data?.summary?.source || serviceProvider).trim() || serviceProvider,
    });
  } catch (error) {
    return jsonResponse(500, {
      has_tolls: false,
      toll_cost: 0.0,
      toll_unavailable: true,
      error: error?.message || 'Unexpected server error',
    });
  }
};
