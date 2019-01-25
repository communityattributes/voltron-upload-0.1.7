module Voltron
  class Config

    def upload
      @upload ||= Upload.new
    end

    class Upload

      attr_accessor :enabled, :keep_for

      def initialize
        @enabled ||= true
        @keep_for ||= 30.days
      end
    end
  end
end