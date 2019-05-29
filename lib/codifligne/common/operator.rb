module Codifligne
  class Operator < Base
    attr_accessor :name, :stif_id, :xml

    def lines
      @lines ||= begin
        client = Codifligne::API.new
        client.lines(operator_name: self.name)
      end
    end
  end
end
