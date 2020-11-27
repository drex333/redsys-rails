module Redsys
  class NotificationsController < ApplicationController
    skip_before_action :verify_authenticity_token

    #
    # Tratamiento para la notificación online
    # - Ds_Response == "0000" => Transacción correcta
    #
    def notification
      json_params = JSON.parse(Base64.urlsafe_decode64(params[:Ds_MerchantParameters]))
#     TODO: Can't make this call work nor in ruby 1.8.7 neither in ruby 2.3.0, so I create an instance of the TPV class just for checking the signature
#      if Redsys::Tpv.response_signature(params[:Ds_MerchantParameters]) == params[:Ds_Signature]
      @tpv = Redsys::Tpv.new(json_params["Ds_Amount"], json_params["Ds_Order"], json_params["Ds_ConsumerLanguage"],'','','')

      if @tpv.response_signature(params[:Ds_MerchantParameters]) == params[:Ds_Signature]
        # Enter only if the signature from the gateway is correct
        if json_params["Ds_Response"].present?
          if (tpv_tx.response_code >= 0 && tpv_tx.response_code <= 99)
            # The transaction result is ok. Register the payment here
          end
          status = :ok
        else
          # The transaction failed although the signature was right because there was no Ds_Response, handle the exception however you want
          status = :bad_request
        end
      else
        # The transaction failed due to an error in the signature, handle the exception however you want
        status = :bad_request
      end
      render :nothing => true, :layout => false, :status => status
    end
  end
end