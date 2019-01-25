module Voltron
  module Upload
    module CarrierWave
      module Uploader
        module Base

          def to_upload_hash(id)
            if present?
              {
                id: id,
                url: url,
                status: :added,
                accepted: true,
                name: file.filename,
                size: file.size,
                type: file.content_type
              }
            end
          end

        end
      end
    end
  end
end
