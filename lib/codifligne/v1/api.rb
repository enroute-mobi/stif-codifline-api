module Codifligne
  module V1
    class API < Codifligne::CommonAPI

      def self.base_url
        'https://pprod.codifligne.stif.info/rest/v1/lc/getlist'
      end

      def lines(params = {})
        attrs = {
          :name           => 'Name',
          :short_name     => 'ShortName',
          :transport_mode => 'TransportMode',
          :private_code   => 'PrivateCode'
        }
        inline_attrs = {
          :stif_id    => 'id',
          :status     => 'status',
          :created_at => 'created',
          :updated_at => 'changed'
        }

        get_doc(params).css('lines Line').map do |line|
          params = { xml: line.to_xml }

          inline_attrs.map do |prop, xml_attr|
            params[prop] = line.attribute(xml_attr).to_s
          end
          attrs.map do |prop, xml_name|
            params[prop] = line.at_css(xml_name).content
          end

          params[:accessibility]     = line.css('Key:contains("Accessibility")').first.next_element.content
          submode                    = line.css('TransportSubmode')
          params[:transport_submode] = submode.first.content.strip if submode.first

          params[:operator_codes]    = []
          line.css('OperatorRef').each do |operator|
            params[:operator_codes] << operator.attribute('ref').to_s.split(':').last
          end

          params[:secondary_operator_ref] = []
          line.css('additionalOperators OperatorRef').each do |operator|
            params[:secondary_operator_ref] << operator.attribute('ref').to_s
          end
          type_of_line = line.css('TypeOfLineRef').attribute('ref').to_s
          params[:seasonal] = type_of_line && (type_of_line.split(':').last == 'seasonal') ? true : false

          unless line.css('OperatorRef').empty?
            params[:operator_ref] = line.css('OperatorRef').first.attribute('ref').to_s
          end
          Codifligne::V1::Line.new(params)
        end.to_a
      end

      def groups_of_lines(params = {})
        attrs = {
          :name           => 'Name',
          :short_name     => 'ShortName',
          :transport_mode => 'TransportMode',
          :private_code   => 'PrivateCode'
        }
        inline_attrs = {
          :stif_id    => 'id',
          :status     => 'status',
          :created_at => 'created',
          :updated_at => 'changed'
        }

        get_doc(params).css('groupsOfLines GroupOfLines').map do |group|
          params = { xml: group.to_xml }

          inline_attrs.map do |prop, xml_attr|
            params[prop] = group.attribute(xml_attr).to_s
          end
          attrs.map do |prop, xml_name|
            params[prop] = group.at_css(xml_name).content
          end

          submode = group.css('KeyValue').select{ |keyvalue| keyvalue.css('Key').text == 'TransportSubmode' }
          if submode.first
            submode = submode.first.css('Value').text.strip
            params[:transport_submode] = submode if submode.size > 0
          end

          params[:line_codes]    = []
          group.css('LineRef').each do |line|
            params[:line_codes] << line.attribute('ref').to_s.split(':').last
          end

          Codifligne::V1::GroupOfLines.new(params)
        end.to_a
      end
    end
  end
end
