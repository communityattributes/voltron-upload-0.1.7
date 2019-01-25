module Voltron
  module Upload
    module Generators
      class InstallGenerator < Rails::Generators::Base

        source_root File.expand_path("../../../templates", __FILE__)

        desc "Add Voltron Upload initializer"

        def inject_initializer

          voltron_initialzer_path = Rails.root.join("config", "initializers", "voltron.rb")

          unless File.exist? voltron_initialzer_path
            unless system("cd #{Rails.root.to_s} && rails generate voltron:install")
              puts "Voltron initializer does not exist. Please ensure you have the 'voltron' gem installed and run `rails g voltron:install` to create it"
              return false
            end
          end

          current_initiailzer = File.read voltron_initialzer_path

          unless current_initiailzer.match(Regexp.new(/# === Voltron Upload Configuration ===/))
            inject_into_file(voltron_initialzer_path, after: "Voltron.setup do |config|\n") do
<<-CONTENT

  # === Voltron Upload Configuration ===

  # Whether or not calls to file_field should generate markup for dropzone uploads
  # If false, simply returns what file_field would return normally
  # config.upload.enabled = true

  # How long temporarily uploaded files should remain on the server and in the voltron_temp db table
  # This value should be long enough to give any user filling out a form a reasonable amount of time to come
  # back and submit it. In other words, don't make it 5 minutes, or the files the user uploads will not exist
  # when they get around to clicking the "submit" button
  # Keep in mind that all of the above applies only if you add the following to your schedule.rb file for whenever
  #
  # every 1.day do
  #   runner "Voltron::Upload::Tasks.cleanup"
  # end
  #
  # config.upload.keep_for = 30.days
CONTENT
            end
          end
        end

        def copy_migrations
          copy_migration "create_voltron_temp"
        end

        protected

          def copy_migration(filename)
            if migration_exists?(Rails.root.join("db", "migrate"), filename)
              say_status("skipped", "Migration #{filename}.rb already exists")
            else
              copy_file "db/migrate/#{filename}.rb", Rails.root.join("db", "migrate", "#{migration_number}_#{filename}.rb")
            end
          end

          def migration_exists?(dirname, filename)
            Dir.glob("#{dirname}/[0-9]*_*.rb").grep(/\d+_#{filename}.rb$/).first
          end

          def migration_id_exists?(dirname, id)
            Dir.glob("#{dirname}/#{id}*").length > 0
          end

          def migration_number
            @migration_number ||= Time.now.strftime("%Y%m%d%H%M%S").to_i

            while migration_id_exists?(Rails.root.join("db", "migrate"), @migration_number) do
              @migration_number += 1
            end

            @migration_number
          end
      end
    end
  end
end