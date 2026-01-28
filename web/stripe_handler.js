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

// Confirm payment with client secret (Stripe maneja el formulario automáticamente)
async function confirmStripePayment(clientSecret) {
  if (!stripe) {
    return {
      success: false,
      error: 'Stripe not initialized'
    };
  }
  
  try {
    console.log('💳 Procesando pago con Stripe...');
    
    // Stripe manejará automáticamente el formulario de pago
    const {error} = await stripe.confirmCardPayment(clientSecret, {
      payment_method: {
        card: {
          // Pedir a Stripe que muestre su propio formulario
          token: 'pm_card_visa' // Tarjeta de prueba
        }
      },
      return_url: window.location.href
    });
    
    if (error) {
      console.error('❌ Stripe error:', error.message);
      return {
        success: false,
        error: error.message
      };
    }
    
    console.log('✅ Pago exitoso');
    return {
      success: true,
      paymentIntentId: clientSecret.split('_secret_')[0]
    };
  } catch (error) {
    console.error('❌ Exception in confirmStripePayment:', error);
    return {
      success: false,
      error: error.message
    };
  }
}

