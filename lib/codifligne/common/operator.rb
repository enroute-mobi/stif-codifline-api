module Codifligne
  class Operator < Base
    attr_accessor :name, :stif_id, :xml

    def lines
      client = Codifligne::API.new
      client.lines(operator_name: self.name)
    end
  end
end
