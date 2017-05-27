module Spree
  class NetcentsExpressCheckoutController < StoreController

    def get_headers
      api_key = preferences[:api_key]
      signature = create_signature.chomp
      parameters = create_parameters.chomp
      render json: { api_key: api_key, signature: signature, parameters: parameters }
    end

    def get_cart_items
      data = create_netcents_order_details
      encoded_data = Base64.urlsafe_encode64(data.to_json)
      render json: { cart_items: encoded_data.chomp }
    end

    def confirm
      order = current_order || raise(ActiveRecord::RecordNotFound)
      payment = order.payments.create!({
        source: Spree::NetcentsExpressCheckout.create({
          invoice_number: params[:invoice_number],
          payer_id: params[:payer_id]
        }),
        amount: order.total,
        payment_method: payment_method,
        response_code: params[:invoice_number]
      })
      order.next
      if order.complete?
        flash.notice = Spree.t(:order_processed_successfully)
        flash[:order_completed] = true
        session[:order_id] = nil
        payment.started_processing!
        payment.pend!
        payment.complete!
        order.update!
        redirect_to completion_route(order)
      else
        redirect_to checkout_state_path(order.state)
      end
    end

    private

      def payment_method
        Spree::PaymentMethod.find(params[:payment_method_id])
      end

      def preferences
        payment_method.preferences
      end

      def create_signature
        signature = Base64.encode64(OpenSSL::HMAC.digest('sha256', preferences[:secret], create_parameters))
      end

      def create_parameters
        parameters = Hash.new
        parameters['nonce'] = DateTime.now.to_i
        parameters['merchant_id'] = preferences[:merchant_id]
        parameters['callback_url'] = preferences[:callback_url]
        encoded_parameters = Base64.urlsafe_encode64(parameters.to_json)
      end

      def create_netcents_order_details
        data = Hash.new
        data['total_price'] = current_order.total.to_f
        # data['total_price'] = 1
        data['currency'] = current_order.currency
        # data['currency'] = 'CAD'
        if current_order.created_by_id
          data['payer_id'] = current_order.created_by_id
        else
          data['payer_id'] = current_order.guest_token
        end
        data
      end

      def completion_route(order)
        order_path(order)
      end
  end
end
