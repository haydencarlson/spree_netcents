
 // Placeholder manifest file.
// the installer will append this file to the app vendored assets here: vendor/assets/javascripts/spree/frontend/all.js'
var signature, parameters, apiKey, token, cartItems, paymentMethodId;
$(function () {
  var helpers = {
    getToken: function () {
      var url = 'http://localhost:3000/merchant/authorize?api_key=' + apiKey;
      // var url = 'http://localhost:3000/client/authorize?api_key=' + apiKey + '&signature=' + signature + '&parameters=' + parameters;
      var xhr = new XMLHttpRequest();
      xhr.open('GET', url, false);
      xhr.onload = function() {
        var result = JSON.parse(xhr.responseText);
        if (result.error) {
          error = result.error;
          alert(error);
        } else {
          token = result.access_token;
          helpers.checkout();
        }
      };
      xhr.onerror = function() {
        alert('Invalid Request');
      };
      xhr.setRequestHeader('X-Signature', signature);
      xhr.setRequestHeader('X-Parameters', parameters);
      xhr.send();
    },
    checkout: function () {
      var win = window.open('about:blank', 'Netcents Express Checkout', 'top=50px, left=300px, width=900px, height=570px, location=1, status=1, toolbar=0, menubar=0, resizable=0, scrollbars=1');
      win.location = 'http://localhost:3000/merchant/checkout?token=' + token + '&data=' + cartItems + '&paymentMethodId=' + paymentMethodId + '&api_key=' + apiKey;
      win.focus();
    }
  };

  var ajaxRequests = {
    getHeaders: function () {
      return $.ajax({
        url: '/get_headers',
        method: 'GET',
        dataType: 'json',
        data: {
          payment_method_id: paymentMethodId
        },
        success: function (result) {
          signature = result.signature;
          parameters = result.parameters;
          apiKey = result.api_key;
        },
        error: function (err) {
          console.log(err);
          console.log("Headers can not be retrieved.")
        }
      });
    },
    getCartItems: function () {
      return $.ajax({
        url: '/get_cart_items',
        method: 'GET',
        dataType: 'json',
        success: function (result) {
          cartItems = result.cart_items;
        },
        error: function (err) {
          console.log(err);
          console.log("Cart items can not be retrieved.")
        }
      });
    }
  };

  var handlers = {
    paymentMethodFieldsOnClick: function () {
     paymentMethodId = $(this).find('input[type=radio]').val();
    },
    payWithNetcentsOnClick: function () {
      var serverRequests = [];
      serverRequests.push(ajaxRequests.getHeaders());
      serverRequests.push(ajaxRequests.getCartItems());
      $.when.apply(null, serverRequests).done(helpers.getToken);
    }
  }

  $('#payment-method-fields li').on('click', handlers.paymentMethodFieldsOnClick);
  $('#payWithNetcents').on('click', handlers.payWithNetcentsOnClick);
});
