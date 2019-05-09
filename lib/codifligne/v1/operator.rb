module Codifligne::V1
  class Operator
    attr_accessor :name, :stif_id, :xml

    def initialize params
      params.each do |k,v|
        instance_variable_set("@#{k}", v) unless v.nil?
      end
    end

    def lines
      client = Codifligne::API.new
      client.lines(operator_name: self.name)
    end
  end
end
