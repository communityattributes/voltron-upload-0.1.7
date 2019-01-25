module Voltron
  module Upload
    class Error < StandardError

      attr_accessor :messages

      def initialize(*messages)
        @messages = messages.flatten
      end

      def response
        { success: false, error: @messages }
      end

      def status
        :not_acceptable
      end
    end
  end
end
