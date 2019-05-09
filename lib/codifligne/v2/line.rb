module Codifligne::V2
  class Line
    attr_accessor :name, :short_name, :transport_mode, :operator_codes, :stif_id, :status, :accessibility, :transport_submode, :xml, :operator_ref, :secondary_operator_ref, :seasonal, :private_code, :color, :text_color, :line_notices, :valid_from, :valid_until

    def initialize params
      params.each do |k,v|
        instance_variable_set("@#{k}", v) unless v.nil?
      end
    end

    def transport_mode
      @transport_mode&.to_s&.downcase
    end
  end
end
