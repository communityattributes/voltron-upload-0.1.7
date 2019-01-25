module Voltron
  module Upload
    class Tasks

      def self.cleanup
        Voltron::Temp.where("created_at <= ?", Voltron.config.upload.keep_for.ago).destroy_all
      end

    end
  end
end
