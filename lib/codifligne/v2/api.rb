module Codifligne
  module V2
    class API < Codifligne::CommonAPI

      def self.base_url
        'https://pprod.codifligne.stif.info/rest/v2/lc/getlist'
      end

      def lines(params = {})
        attrs = {
          :name           => 'Name',
          :short_name     => 'ShortName',
          :transport_mode => 'TransportMode',
          :private_code   => 'PrivateCode',
          :color          => 'Colour',
          :text_color     => 'TextColour',
          :registration_number => 'PublicCode'
        }
        inline_attrs = {
          :stif_id    => 'id',
          :status     => 'status',
          :created_at => 'created',
          :updated_at => 'changed'
        }

        get_doc(params).css('Line').map do |line|
          params = { xml: line.to_xml }

          inline_attrs.map do |prop, xml_attr|
            params[prop] = line.attribute(xml_attr).to_s
          end
          attrs.map do |prop, xml_name|
            params[prop] = line.at_css(xml_name).content
          end

          if line.css('ValidBetween FromDate').size > 0
            params[:valid_from] = Date.parse line.css('ValidBetween FromDate').first.content
          end
          if line.css('ValidBetween ToDate').size > 0
            params[:valid_until] = Date.parse line.css('ValidBetween ToDate').first.content
          end

          params[:seasonal]          = line.css('TypeOfLineRef[ref="SEASONAL_LINE_TYPE"]').size > 0

          params[:accessibility]     = line.css('MobilityImpairedAccess').first.content == 'true'
          submode                    = line.css('TransportSubmode')
          params[:transport_submode] = submode.first.content.strip if submode.first

          params[:operator_codes]    = []
          line.css('OperatorRef').each do |operator|
            params[:operator_codes] << operator.attribute('ref').to_s.split(':').last
          end

          params[:line_notices]    = []
          line.css('NoticeAssignment NoticeRef').each do |notice|
            params[:line_notices] << notice.attribute('ref').to_s.split(':').last
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
          Codifligne::V2::Line.new(params)
        end.to_a
      end

      def parse_contact(node)
        return {} unless node

        {
          name: node.css('ContactPerson').first&.content,
          email: node.css('Email').first&.content,
          phone: node.css('Phone').first&.content,
          url: node.css('Url').first&.content,
          more: node.css('FurtherDetails').first&.content
        }
      end

      def parse_address(node)
        return {} unless node

        {
          house_number: node.css('HouseNumber').first&.content,
          address_line_1: node.css('AddressLine1').first&.content,
          address_line_2: node.css('AddressLine2').first&.content,
          street: node.css('Street').first&.content,
          town: node.css('Town').first&.content,
          postcode: node.css('PostCode').first&.content,
          postcode_extension: node.css('PostCodeExtension').first&.content
        }
      end

      def operators(params = {})
        get_doc(params).css('Operator').map do |operator|
          default_contact = parse_contact operator.css('ContactDetails').first
          private_contact = parse_contact operator.css('PrivateContactDetails').first
          customer_service_contact = parse_contact operator.css('CustomerServiceContactDetails').first

          address = parse_address operator.css('Address').first

          V2::Operator.new({
            name: operator.css('Name').first.content.strip,
            stif_id: operator.attribute('id').to_s.strip,
            default_contact: default_contact,
            private_contact: private_contact,
            customer_service_contact: customer_service_contact,
            address: address,
            xml: operator.to_xml })
        end.to_a
      end

      def groups_of_lines(params = {})
        attrs = {
          :name           => 'Name',
          :transport_mode => 'TransportMode',
          :private_code   => 'PrivateCode'
        }
        inline_attrs = {
          :stif_id    => 'id',
          :status     => 'status',
          :created_at => 'created',
          :updated_at => 'changed'
        }

        get_doc(params).css('GroupOfLines').map do |group|
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

          Codifligne::V2::GroupOfLines.new(params)
        end.to_a
      end
    end
  end
end
