// Netlify Serverless Function — OpenAI Chat Proxy
// This runs server-side so there's no CORS issue and
// the API key stays secure (never exposed to the browser).

exports.handler = async (event) => {
  // Only allow POST
  if (event.httpMethod !== 'POST') {
    return {
      statusCode: 405,
      body: JSON.stringify({ error: 'Method not allowed' }),
    };
  }

  const OPENAI_API_KEY = process.env.OPENAI_API_KEY;

  if (!OPENAI_API_KEY) {
    console.error('OPENAI_API_KEY is not set in environment variables');
    return {
      statusCode: 500,
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ error: 'OpenAI API key not configured on server' }),
    };
  }

  try {
    const body = JSON.parse(event.body);
    const { messages, model, temperature, max_tokens } = body;

    if (!messages || !Array.isArray(messages)) {
      return {
        statusCode: 400,
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ error: 'messages array is required' }),
      };
    }

    console.log(`[AI Concierge] Sending ${messages.length} messages to OpenAI`);

    const response = await fetch('https://api.openai.com/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${OPENAI_API_KEY}`,
      },
      body: JSON.stringify({
        model: model || 'gpt-4o-mini',
        messages: messages,
        temperature: temperature || 0.8,
        max_tokens: max_tokens || 1000,
      }),
    });

    const data = await response.json();

    if (!response.ok) {
      console.error(`[AI Concierge] OpenAI error: ${response.status}`, JSON.stringify(data));
      return {
        statusCode: response.status,
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data),
      };
    }

    console.log(`[AI Concierge] Success — tokens used: ${data.usage?.total_tokens || 'unknown'}`);

    return {
      statusCode: 200,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'Content-Type',
      },
      body: JSON.stringify(data),
    };
  } catch (error) {
    console.error('[AI Concierge] Server error:', error.message);
    return {
      statusCode: 500,
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ error: 'Internal server error', details: error.message }),
    };
  }
};
