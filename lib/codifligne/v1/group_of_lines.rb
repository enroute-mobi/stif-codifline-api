module Codifligne::V1
  class GroupOfLines
    attr_accessor :name, :status, :short_name, :private_code, :stif_id, :line_codes, :transport_mode, :transport_submode, :xml

    def initialize params
      params.each do |k,v|
        instance_variable_set("@#{k}", v) unless v.nil?
      end
    end

  end
end
