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

// Confirm payment with client secret
async function confirmStripePayment(clientSecret) {
  if (!stripe) {
    return {
      success: false,
      error: 'Stripe not initialized'
    };
  }
  
  try {
    console.log('💳 Procesando pago con Stripe...');
    
    // confirmCardPayment redirige automáticamente a la página de pago de Stripe
    const result = await stripe.confirmCardPayment(clientSecret);
    
    if (result.error) {
      console.error('❌ Stripe error:', result.error.message);
      return {
        success: false,
        error: result.error.message
      };
    }
    
    if (result.paymentIntent.status === 'succeeded') {
      console.log('✅ Pago exitoso:', result.paymentIntent.id);
      return {
        success: true,
        paymentIntentId: result.paymentIntent.id
      };
    }
    
    return {
      success: false,
      error: 'Payment not completed. Status: ' + result.paymentIntent.status
    };
  } catch (error) {
    console.error('❌ Exception in confirmStripePayment:', error);
    return {
      success: false,
      error: error.message
    };
  }
}

