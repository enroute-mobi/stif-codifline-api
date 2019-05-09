module Codifligne
  class Line < Base
    attr_accessor :transport_mode

    def transport_mode
      @transport_mode&.to_s&.downcase
    end
  end
end
