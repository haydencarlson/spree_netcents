module Spree
  CheckoutController.class_eval do
    before_filter :redirect_to_netcents_express, :only => [:update]

    private
    def redirect_to_netcents_express
      return unless (params[:state] == "payment") && params[:order][:payments_attributes]

      payment_method = PaymentMethod.find(params[:order][:payments_attributes].first[:payment_method_id])
      if payment_method.kind_of?(Spree::Gateway::NetcentsExpressCheckout)
        url = URI.parse('http://localhost:3000/merchant/authorize?api_key=' + payment_method[:preferences][:api_key])
        req = Net::HTTP::Get.new(url.to_s)
        res = Net::HTTP.start(url.host, url.port) {|http|
          http.request(req)
        }
        redirect_to paypal_express_url(:payment_method_id => payment_method.id)
      end
    end
  end
end
