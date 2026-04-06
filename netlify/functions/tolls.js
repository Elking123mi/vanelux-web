exports.handler = async (event) => {
  if (event.httpMethod === 'OPTIONS') {
    return {
      statusCode: 200,
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'Content-Type',
        'Access-Control-Allow-Methods': 'POST,OPTIONS',
      },
      body: '',
    };
  }

  if (event.httpMethod !== 'POST') {
    return {
      statusCode: 405,
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ error: 'Method not allowed' }),
    };
  }

  const tollGuruApiKey = process.env.TOLLGURU_API_KEY;
  if (!tollGuruApiKey) {
    return {
      statusCode: 500,
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        has_tolls: false,
        toll_cost: 0.0,
        toll_unavailable: true,
        error: 'TOLLGURU_API_KEY is missing on server',
      }),
    };
  }

  try {
    const body = JSON.parse(event.body || '{}');
    const origin = String(body.origin || '').trim();
    const destination = String(body.destination || '').trim();

    if (!origin || !destination) {
      return {
        statusCode: 400,
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          has_tolls: false,
          toll_cost: 0.0,
          toll_unavailable: true,
          error: 'origin and destination are required',
        }),
      };
    }

    const response = await fetch('https://apis.tollguru.com/toll/v2/origin-destination-waypoints', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': tollGuruApiKey,
      },
      body: JSON.stringify({
        from: { address: origin },
        to: { address: destination },
        vehicleType: '2AxlesAuto',
        departure_time: new Date().toISOString(),
      }),
    });

    const data = await response.json();
    if (!response.ok) {
      return {
        statusCode: response.status,
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          has_tolls: false,
          toll_cost: 0.0,
          toll_unavailable: true,
          error: data?.value || data?.error || 'TollGuru request failed',
        }),
      };
    }

    const routes = Array.isArray(data?.routes) ? data.routes : [];
    const route = routes[0] || {};
    const costs = route.costs || {};

    const parseCost = (value) => {
      const number = Number.parseFloat(value ?? 0);
      return Number.isFinite(number) ? number : 0;
    };

    let tollCost = parseCost(costs.licensePlate);
    if (tollCost <= 0) tollCost = parseCost(costs.tag);
    if (tollCost <= 0) tollCost = parseCost(costs.cash);
    if (tollCost <= 0) tollCost = parseCost(costs.prepaidCard);

    const hasTolls =
      tollCost > 0 || (Array.isArray(route.tolls) && route.tolls.length > 0);

    return {
      statusCode: 200,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'Content-Type',
      },
      body: JSON.stringify({
        has_tolls: hasTolls,
        toll_cost: tollCost,
        toll_unavailable: false,
      }),
    };
  } catch (error) {
    return {
      statusCode: 500,
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        has_tolls: false,
        toll_cost: 0.0,
        toll_unavailable: true,
        error: error?.message || 'Unexpected server error',
      }),
    };
  }
};
