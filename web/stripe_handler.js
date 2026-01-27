// Stripe Payment Handler for Flutter Web
let stripe = null;
let elements = null;
let cardElement = null;

// Initialize Stripe
function initStripe(publishableKey) {
  stripe = Stripe(publishableKey);
  return true;
}

// Create payment form with Stripe Elements
function createStripeCardElement(containerId) {
  if (!stripe) {
    console.error('Stripe not initialized');
    return false;
  }
  
  elements = stripe.elements();
  cardElement = elements.create('card', {
    style: {
      base: {
        fontSize: '16px',
        color: '#32325d',
        '::placeholder': {
          color: '#aab7c4'
        }
      },
      invalid: {
        color: '#fa755a',
        iconColor: '#fa755a'
      }
    }
  });
  
  const container = document.getElementById(containerId);
  if (container) {
    cardElement.mount(`#${containerId}`);
    return true;
  }
  return false;
}

// Confirm payment with client secret
async function confirmStripePayment(clientSecret) {
  if (!stripe || !cardElement) {
    return {
      success: false,
      error: 'Stripe not initialized'
    };
  }
  
  try {
    const result = await stripe.confirmCardPayment(clientSecret, {
      payment_method: {
        card: cardElement
      }
    });
    
    if (result.error) {
      return {
        success: false,
        error: result.error.message
      };
    }
    
    if (result.paymentIntent.status === 'succeeded') {
      return {
        success: true,
        paymentIntentId: result.paymentIntent.id
      };
    }
    
    return {
      success: false,
      error: 'Payment not completed'
    };
  } catch (error) {
    return {
      success: false,
      error: error.message
    };
  }
}
