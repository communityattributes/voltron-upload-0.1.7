module Voltron
  module Upload
    module Base

      def mount_uploader(*args)
        super *args

        column = args.first.to_sym

        class_eval do
          attr_accessor "commit_#{column}".to_sym
        end

      end

      def mount_uploaders(*args)
        super *args

        column = args.first.to_sym

        class_eval do

          attr_accessor "commit_#{column}".to_sym

          attr_accessor "remove_#{column}".to_sym

          before_validation do
            # Merge any new uploads with the pre-existing uploads
            uploads = Array.wrap(self.send("#{column}_was")) | Array.wrap(self.send(column))

            assign_attributes(column => uploads.compact)
          end

          before_validation do
            # Get the filenames of uploads we want to remove
            remove = Array.wrap(self.send("remove_#{column}"))

            # Get the current uploads
            uploads = Array.wrap(self.send(column))

            # Go through each file to remove, attempt to find it, and remove it.
            # Only remove a unique file name as many times as it exists in the remove array
            remove.each { |r| uploads.find { |u| u.file.try(:filename) == r }.try(:remove!) }

            assign_attributes(column => uploads.compact)
          end
        end
      end

    end
  end
end
