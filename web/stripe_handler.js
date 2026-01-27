// Stripe Payment Handler for Flutter Web
let stripe = null;
let elements = null;
let cardElement = null;

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

// Create payment form with Stripe Elements
function createStripeCardElement(containerId) {
  if (!stripe) {
    console.error('❌ Stripe not initialized');
    return false;
  }
  
  try {
    // Crear un div para el card element si no existe
    let container = document.getElementById(containerId);
    if (!container) {
      // Crear el contenedor dinámicamente
      container = document.createElement('div');
      container.id = containerId;
      container.style.width = '100%';
      container.style.padding = '12px';
      document.body.appendChild(container);
    }

    elements = stripe.elements();
    cardElement = elements.create('card', {
      style: {
        base: {
          fontSize: '16px',
          color: '#32325d',
          fontFamily: '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif',
          '::placeholder': {
            color: '#aab7c4'
          }
        },
        invalid: {
          color: '#fa755a',
          iconColor: '#fa755a'
        }
      },
      hidePostalCode: true
    });
    
    cardElement.mount(`#${containerId}`);
    console.log('✅ Stripe Card Element montado en', containerId);
    return true;
  } catch (error) {
    console.error('❌ Error creating Stripe element:', error);
    return false;
  }
}

// Confirm payment with client secret
async function confirmStripePayment(clientSecret) {
  if (!stripe || !cardElement) {
    return {
      success: false,
      error: 'Stripe not initialized or card element not mounted'
    };
  }
  
  try {
    console.log('💳 Procesando pago con Stripe...');
    
    const result = await stripe.confirmCardPayment(clientSecret, {
      payment_method: {
        card: cardElement
      }
    });
    
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

