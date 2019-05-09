module Codifligne::V2
  class Line < Codifligne::Line
    attr_accessor :name, :short_name, :operator_codes, :stif_id, :status, :accessibility, :transport_submode, :xml, :operator_ref, :secondary_operator_ref, :seasonal, :private_code, :color, :text_color, :line_notices, :valid_from, :valid_until
  end
end
