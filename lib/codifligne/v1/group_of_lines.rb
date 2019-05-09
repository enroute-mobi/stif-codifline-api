module Codifligne::V1
  class GroupOfLines < Codifligne::GroupOfLines
    attr_accessor :name, :status, :short_name, :private_code, :stif_id, :line_codes, :transport_mode, :transport_submode, :xml
  end
end
