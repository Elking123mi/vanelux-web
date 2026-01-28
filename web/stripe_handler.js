// Stripe Payment Handler for Flutter Web
let stripe = null;

// Initialize Stripe
function initStripe(publishableKey) {
  try {
    stripe = Stripe(publishableKey);
    console.log('✅ Stripe initialized');
    return true;
  } catch (error) {
    console.error('❌ Error initializing Stripe:', error);
    return false;
  }
}

// Redirect to Stripe Checkout
async function redirectToCheckout(sessionId) {
  if (!stripe) {
    return {
      success: false,
      error: 'Stripe not initialized'
    };
  }
  
  try {
    console.log('🔄 Redirecting to Stripe Checkout...');
    const result = await stripe.redirectToCheckout({ sessionId: sessionId });
    
    if (result.error) {
      console.error('❌ Checkout error:', result.error.message);
      return {
        success: false,
        error: result.error.message
      };
    }
    
    return {
      success: true
    };
  } catch (error) {
    console.error('❌ Exception in redirectToCheckout:', error);
    return {
      success: false,
      error: error.message
    };
  }
}

