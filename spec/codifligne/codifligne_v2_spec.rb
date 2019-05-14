require 'spec_helper'

describe Codifligne do
  before(:each) do
    Codifligne::API.api_version = 2
  end

  let(:client) { Codifligne::API.new }
  let(:api_index_url) { client.build_url() }
  let(:operator) { Codifligne::Operator.new({name: 'RATP'}) }

  it 'should have a version number' do
    expect(Codifligne::VERSION).not_to be nil
  end

  it 'should use v2' do
    expect(client.is_a?(Codifligne::V2::API)).to be_truthy
  end

  it 'should have a default timeout value' do
    expect(client.timeout).to equal(30)
  end

  it 'should set timeout from initializer' do
    expect(Codifligne::API.new(timeout: 60).timeout).to equal(60)
  end

  it 'should raise exception on Api call timeout' do
    stub_request(:get, api_index_url).to_timeout
    expect { client.operators }.to raise_error(Codifligne::CodifligneError)
  end

  it 'should raise exception on Codifligne API response 404' do
    stub_request(:get, api_index_url).to_return(status: 404)
    expect { client.operators }.to raise_error(Codifligne::CodifligneError)
  end

  it 'should return operators on valid operator request' do
    xml = File.new(fixture_path + '/v2/index.xml')
    stub_request(:get, api_index_url).to_return(body: xml)
    operators = client.operators()

    expect(operators.count).to equal(83)
    expect(operators.first).to be_a(Codifligne::Operator)

    expect(operators.first.address).to_not be_nil

    expect(operators.first.default_contact).to_not be_nil
    expect(operators.first.default_contact[:name]).to eq 'John Doe'
    expect(operators.first.default_contact[:email]).to eq 'john@doe.com'
    expect(operators.first.default_contact[:phone]).to eq '123456'
    expect(operators.first.default_contact[:url]).to eq 'www.john.doe'
    expect(operators.first.default_contact[:more]).to eq 'Lorem ipsum'

    expect(operators.first.private_contact).to_not be_nil
    expect(operators.first.private_contact[:name]).to eq 'John Doe'
    expect(operators.first.private_contact[:email]).to eq 'john@doe.com'
    expect(operators.first.private_contact[:phone]).to eq '123456'
    expect(operators.first.private_contact[:url]).to eq 'www.john.doe'
    expect(operators.first.private_contact[:more]).to eq 'Lorem ipsum'

    expect(operators.first.customer_service_contact).to_not be_nil
    expect(operators.first.customer_service_contact[:name]).to be_nil
    expect(operators.first.customer_service_contact[:email]).to be_nil
    expect(operators.first.customer_service_contact[:phone]).to be_nil
    expect(operators.first.customer_service_contact[:url]).to be_nil
    expect(operators.first.customer_service_contact[:more]).to be_nil
  end

  it 'should return networks on valid network request' do
    xml = File.new(fixture_path + '/v2/index.xml')
    stub_request(:get, api_index_url).to_return(body: xml)
    networks = client.networks()

    expect(networks.count).to equal(133)
    expect(networks.first).to be_a(Codifligne::Network)
  end

  it 'should return groups of lines on valid group_of_lines request' do
    xml = File.new(fixture_path + '/v2/index.xml')
    stub_request(:get, api_index_url).to_return(body: xml)
    group_of_lines = client.groups_of_lines()

    expect(group_of_lines.count).to equal(1673)
    expect(group_of_lines.first).to be_a(Codifligne::V2::GroupOfLines)
  end

  it 'should return line_notices on valid line_notices request' do
    xml = File.new(fixture_path + '/v2/index.xml')
    stub_request(:get, api_index_url).to_return(body: xml)
    line_notices = client.line_notices()

    expect(line_notices.count).to equal(2253)
    expect(line_notices.first).to be_a(Codifligne::V2::LineNotice)
    expect(line_notices.first.name).to eq ''
    expect(line_notices.first.text).to eq ''
  end

  it 'should raise exception on unparseable response' do
    xml = File.new(fixture_path + '/v2/invalid_index.xml')
    stub_request(:get, api_index_url).to_return(body: xml)
    expect { client.operators }.to raise_error(Codifligne::CodifligneError)
  end

  it 'should return operators by transport_mode' do
    url = client.build_url(transport_mode: 'fer')
    xml = File.new(fixture_path + '/v2/index_transport_mode.xml')
    stub_request(:get, url).to_return(body: xml)
    operators = client.operators(transport_mode: 'fer')

    expect(operators.count).to equal(1)
    expect(operators.first).to be_a(Codifligne::Operator)
  end

  it 'should return operators on valid line request' do
    url = client.build_url(operator_name: 'RATP')
    xml = File.new(fixture_path + '/v2/line.xml')
    stub_request(:get, url).to_return(body: xml)

    lines = client.lines(operator_name: 'RATP')

    expect(lines.count).to equal(403)
    expect(lines.first).to be_a(Codifligne::V2::Line)
    expect(lines.first.transport_mode).to eq 'metro'
    expect(lines.first.name).to eq '1'
    expect(lines.first.short_name).to eq '1'
    expect(lines.first.private_code).to eq '100110001'
    expect(lines.first.color).to eq 'ffbe00'
    expect(lines.first.text_color).to eq '000000'
    expect(lines.first.seasonal).to be_falsy
    expect(lines.first.line_notices.size).to eq 1
    expect(lines.first.valid_until).to be_nil
    expect(lines.first.valid_from).to eq Date.parse('2014-07-16T00:00:00')
  end

  it 'should retrieve lines with Operator lines method' do
    url = client.build_url(operator_name: 'RATP')
    xml = File.new(fixture_path + '/v2/line.xml')
    stub_request(:get, url).to_return(body: xml)

    expect(operator.lines.count).to equal(403)
  end

end
