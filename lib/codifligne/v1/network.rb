module Codifligne::V1
  class Network
    attr_accessor :name, :stif_id, :line_codes, :xml

    def initialize params
      params.each do |k,v|
        instance_variable_set("@#{k}", v) unless v.nil?
      end
    end
  end
end
