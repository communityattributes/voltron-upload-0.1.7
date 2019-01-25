module Voltron
  module Upload
    module Routes

      def upload_for(resource, options={})
        controller = resource.to_s.underscore
        options = options.with_indifferent_access

        options[:path] ||= "/#{controller}/upload"
        options[:controller] ||= controller

        post options[:path].gsub(/(^\/+|\/+$)/, ''), to: "#{options[:controller]}#upload", as: "upload_#{controller}"
      end

    end
  end
end
