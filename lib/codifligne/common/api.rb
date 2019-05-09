module Codifligne
  class CommonAPI
    DEFAULT_TIMEOUT  = 30
    DEFAULT_FORMAT   = 'xml'

    attr_accessor :timeout, :format, :base_url

    def initialize(timeout: nil, format: nil)
      @timeout  = timeout || self.class.timeout || DEFAULT_TIMEOUT
      @format   = format || self.class.format || DEFAULT_FORMAT
      @base_url = self.class.base_url
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

    def operators(params = {})
      get_doc(params).css('Operator').map do |operator|
        Operator.new({ name: operator.content.strip, stif_id: operator.attribute('id').to_s.strip, xml: operator.to_xml })
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

        Network.new(params)
      end.to_a
    end

    class << self
      attr_accessor :timeout, :format, :base_url
    end
  end
end
