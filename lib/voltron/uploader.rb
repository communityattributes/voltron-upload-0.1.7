module Voltron
  class Uploader

    attr_accessor :resource

    def initialize(resource)
      @resource = resource.to_s.classify.safe_constantize
    end

    # A new instance of the model we'll be uploading files for
    # Used to test the validity of uploads
    def instance(refresh=false)
      @instance = nil if refresh
      @instance ||= resource.new
    end

    # Resource name as it would appear in the params hash
    def resource_name
      resource.name.singularize.underscore
    end

    # List of permitted parameters needed for upload action
    def permitted_params
      columns.map { |name,multiple| multiple ? { name => [] } : name }
    end

    def process!(params)
      instance(true)

      # Create a new instance of the resource we're uploading for
      # Pass in the needed upload params and file(s)
      params.each do |k, v|
        if v.is_a?(Array)
          v.each do |f|
            instance.send(k) << f
          end
        else
          instance.send("#{k}=", v)
        end
      end

      # Test the validity, get the errors if any
      instance.valid?

      # Remove all errors that were not related to an uploader, they're expected in this case
      (instance.errors.keys - resource.uploaders.keys).each { |k| instance.errors.delete k }

      if instance.errors.any?
        # If any errors, return the messages
        raise ::Voltron::Upload::Error.new(instance.errors.full_messages)
      else
        response = { uploads: {} }
        # The upload is valid, try to create the "temp" uploads and respond
        params.each do |name,file|
          Array.wrap(file).each do |f|
            upload = ::Voltron::Temp.new(uuid: unique_id, column: name, file: f, multiple: is_multiple?(name))
            if upload.save
              # Even though we only ever process one file at a time, make sure the response value is an array
              # In the future, we may open it up to process more than one at a time, at which point an array will be important
              # Less changes needed in JS later is all...
              response[:uploads][upload.uuid] = upload.file.url
            end
          end
        end
        response
      end
    end

    # Gathers a list of all files to be committed to the resource,
    # generating a new ActionDispatch::Http::UploadedFile objects for each upload
    # Output looks something like below, and will be merged into params hash on before_action:
    # {
    #   "avatar" => #<ActionDispatch::Http::UploadedFile>,
    #   "images" => [
    #     #<ActionDispatch::Http::UploadedFile>,
    #     #<ActionDispatch::Http::UploadedFile>,
    #     #<ActionDispatch::Http::UploadedFile>
    #   ]
    # }
    def committable_uploads(params={})
      columns.map do |name,multiple|
        if params["commit_#{name}"]
          Voltron::Temp.to_param_hash resource_name, params["commit_#{name}"]
        end
      end.compact.reduce(Hash.new, :merge)
    end

    # Get a hash of uploader columns and whether or not it accepts multiple uploads
    # i.e. - { column => multiple_uploads? }
    # i.e. - { avatar: true }
    def columns
      uploaders = resource.uploaders.keys.map(&:to_s)
      resource.uploaders.map { |k,v| { k.to_s => instance.respond_to?("#{k}_urls") } }.reduce(Hash.new, :merge)
    end

    # Is the uploader a multiple file uploader?
    def is_multiple?(name)
      columns[name.to_s]
    end

    # Probably overkill since we're dealing with UUID's, but better safe than sorry
    def unique_id
      id = ::SecureRandom.uuid

      while ::Voltron::Temp.exists?(uuid: id) do
        id = ::SecureRandom.uuid
      end

      id
    end

  end
end
