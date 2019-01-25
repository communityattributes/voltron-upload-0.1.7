module Voltron
  class Temp < ActiveRecord::Base

    mount_uploader :file, Voltron::TempUploader

    def self.to_param_hash(resource_name, *commit_ids)
      params = {}

      where(uuid: commit_ids.flatten).each do |f|
        if f.file.present?
          if f.multiple?
            params[f.column] ||= []
            params[f.column] << upload_file(resource_name, f)
          else
            params[f.column] = upload_file(resource_name, f)
          end
        end
      end
      params
    end

    def self.upload_file(resource_name, f)
      filename = File.basename(f.file.path)
      formname = "#{resource_name}[#{f.column}]" + (f.multiple? ? "[]" : "")

      # Create a new Tempfile from our previously uploaded file
      tmp = Tempfile.new(filename)
      tmp.write IO.read(f.file.path)
      tmp.close

      # Create an uploaded file object with the new tempfile
      ActionDispatch::Http::UploadedFile.new({
        type: f.file.content_type,
        filename: filename,
        head: "Content-Disposition: form-data; name=\"#{formname}\"; filename=\"#{filename}\"\r\nContent-Type: #{f.file.content_type}\r\n",
        tempfile: tmp
      })
    end


  end
end
