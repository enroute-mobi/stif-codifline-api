module Codifligne
  class API
    DEFAULT_TIMEOUT  = 30
    DEFAULT_FORMAT   = 'xml'
    DEFAULT_BASE_URL = "https://pprod.codifligne.stif.info/rest/v1/lc/getlist"

    attr_accessor :timeout, :format, :base_url

    def initialize(timeout: nil, format: nil)
      @timeout  = timeout || self.class.timeout || DEFAULT_TIMEOUT
      @format   = format || self.class.format || DEFAULT_FORMAT
      @base_url = self.class.base_url || DEFAULT_BASE_URL
      @doc      = nil
    end

    def build_url(params = {})
      default = {
        :code              => 0,
        :name              => 0,
        :operator_code     => 0,
        :operator_name     => 0,
        :transport_mode    => 0,
        :transport_submode => 0,
        :date              => 0,
        :format            => self.format
      }
      query = default.merge(params).map{|k, v| v}.to_a.join('/')
      url   = URI.escape "#{self.base_url}/#{query}"
    end

    def api_request(params = {})
      url = build_url(params)
      begin
        open(url, :ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE, :read_timeout => @timeout)
      rescue Exception => e
        raise Codifligne::CodifligneError, "#{e.message} for request : #{url}."
      end
    end

    def parse_response(body)
      if body
        begin
          # Sometimes you need to be a Markup Nazi !
          doc = Nokogiri::XML(body) { |config| config.strict }
        rescue Exception => e
          raise Codifligne::CodifligneError, e.message
        end
      end
    end

    def get_doc(params = {})
      if params.empty? && @doc
        return @doc
      end

      parse_response(api_request(params)).tap do |doc|
        @doc ||= doc if params.empty?
      end
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

        Codifligne::Line.new(params)
      end.to_a
    end

    def operators(params = {})
      get_doc(params).css('Operator').map do |operator|
        Codifligne::Operator.new({ name: operator.content.strip, stif_id: operator.attribute('id').to_s.strip, xml: operator.to_xml })
      end.to_a
    end

    def networks(params = {})
      get_doc(params).css('Network').map do |network|
        params = {
          name: network.at_css('Name').content,
          updated_at: network.attribute('changed').to_s,
          stif_id: network.attribute('id').to_s,
          xml: network.to_xml
        }
        params[:line_codes]    = []
        network.css('LineRef').each do |line|
          params[:line_codes] << line.attribute('ref').to_s.split(':').last
        end

        Codifligne::Network.new(params)
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

        Codifligne::GroupOfLines.new(params)
      end.to_a
    end

    class << self
      attr_accessor :timeout, :format, :base_url
    end
  end
end
