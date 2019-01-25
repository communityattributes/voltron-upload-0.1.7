module Voltron
  module Upload
    module Generators
      module Install
        class AssetsGenerator < Rails::Generators::Base

          source_root File.expand_path("../../../../templates", __FILE__)

          desc "Install Voltron Upload assets"

          def copy_javascripts_assets
            copy_file "app/assets/javascripts/voltron-upload.js", Rails.root.join("app", "assets", "javascripts", "voltron-upload.js")
            copy_file "app/assets/javascripts/dropzone.js", Rails.root.join("app", "assets", "javascripts", "dropzone.js")
          end

          def copy_stylesheets_assets
            copy_file "app/assets/stylesheets/dropzone.scss", Rails.root.join("app", "assets", "stylesheets", "dropzone.scss")
          end

        end
      end
    end
  end
end