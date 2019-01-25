require "voltron"
require "carrierwave"
require "voltron/upload/version"
require "voltron/config/upload"
require "voltron/upload/tasks"
require "voltron/upload/error"
require "voltron/uploader"
require "voltron/upload/carrierwave/uploader/base"
require "voltron/upload/active_record/base"
require "voltron/upload/action_dispatch/routes"
require "voltron/upload/action_controller/parameters"

module Voltron
  module Upload

    def uploadable(resource = nil)
      include ControllerMethods

      resource ||= controller_name
      @uploader ||= Voltron::Uploader.new(resource)

      prepend_before_action :process_uploads

    end

    module ControllerMethods

      def upload
        begin
          render json: uploader.process!(upload_params), status: :created
        rescue Voltron::Upload::Error => e
          render json: e.response, status: e.status
        end
      end

      def process_uploads
        params.commit!(uploader) if params[uploader.resource_name.to_sym]
      end

      def uploader
        self.class.instance_variable_get("@uploader")
      end

      def upload_params
        params.require(uploader.resource_name.to_sym).permit(uploader.permitted_params)
      end

    end

  end
end

require "voltron/upload/engine" if defined?(Rails)
