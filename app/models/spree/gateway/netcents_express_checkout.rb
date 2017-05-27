module Spree
  class Gateway::NetcentsExpressCheckout < Gateway

    preference :api_key, :string
    preference :secret, :string
    preference :merchant_id, :string
    preference :callback_url, :string

    def method_type
      'netcents'
    end

    def source_required?
      false
    end

    def auto_capture?
      false
    end

    def provider_class
      nil
    end

    def payment_source_class
      nil
    end


    # def provider_class
    #   Spree::Gateway::NetcentsExpressCheckout
    # end

    # def provider
    #   Spree::Gateway::NetcentsExpressCheckout(
    #     :api_key      => preferred_api_key,
    #     :secret       => preferred_secret,
    #     :merchant_id  => preferred_merchant_id,
    #     :callback_url => preferred_callback_url)
    #   provider_class
    # end

  end
end
