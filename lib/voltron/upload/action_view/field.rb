module Voltron
  module Upload
    module Field

      def file_field(method, options={})
        if Voltron.config.upload.enabled && !options[:default_input]
          field = UploadField.new(@object, method, options)
          super method, field.options
        else
          options.delete(:default_input)
          super method, options
        end
      end

      class UploadField

        include ::ActionDispatch::Routing::PolymorphicRoutes

        include ::Rails.application.routes.url_helpers

        def initialize(model, method, options)
          @model = model
          @method = method.to_sym
          @options = options.deep_symbolize_keys
          prepare
        end

        def options
          @options ||= {}
        end

        def prepare
          options[:data] ||= {}
          options[:data][:files] = files
          options[:data][:commit] = commits.keys
          options[:data][:upload] ||= polymorphic_path(@model.class, action: :upload)
        end

        def files
          return [] if @model.send(@method).blank? || options[:preserve] === false
          commit_files = commits.dup
          Array.wrap(@model.send(@method)).map do |f|
            if commit_files.values.include?(f.file.try(:filename))
              id = commit_files.key(f.file.try(:filename))
              commit_files.delete(id)
            else
              id = f.file.try(:filename)
            end
            f.to_upload_hash(id)
          end.compact
        end

        def commits
          @commits ||= Array.wrap(@model.send("commit_#{@method}")).map do |commit|
            if temp = ::Voltron::Temp.find_by(uuid: commit)
              temp.column == @method.to_s ? { temp.uuid => temp.file.file.try(:filename) } : nil
            end
          end.compact.reduce(Hash.new, :merge)
        end
      end
    end
  end
end