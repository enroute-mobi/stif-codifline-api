require 'spec_helper'

describe Codifligne do
  let(:client) { Codifligne::API.new }
  let(:api_index_url) { client.build_url() }
  let(:operator) { Codifligne::Operator.new({name: 'RATP'}) }

  it 'should have a version number' do
    expect(Codifligne::VERSION).not_to be nil
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
    xml = File.new(fixture_path + '/index.xml')
    stub_request(:get, api_index_url).to_return(body: xml)
    operators = client.operators()

    expect(operators.count).to equal(82)
    expect(operators.first).to be_a(Codifligne::Operator)
  end

  it 'should return networks on valid network request' do
    xml = File.new(fixture_path + '/index.xml')
    stub_request(:get, api_index_url).to_return(body: xml)
    networks = client.networks()

    expect(networks.count).to equal(125)
    expect(networks.first).to be_a(Codifligne::Network)
  end

  it 'should return groups of lines on valid group_of_lines request' do
    xml = File.new(fixture_path + '/index.xml')
    stub_request(:get, api_index_url).to_return(body: xml)
    group_of_lines = client.groups_of_lines()

    expect(group_of_lines.count).to equal(1578)
    expect(group_of_lines.first).to be_a(Codifligne::GroupOfLines)
  end

  it 'should raise exception on unparseable response' do
    xml = File.new(fixture_path + '/invalid_index.xml')
    stub_request(:get, api_index_url).to_return(body: xml)
    expect { client.operators }.to raise_error(Codifligne::CodifligneError)
  end

  it 'should return operators by transport_mode' do
    url = client.build_url(transport_mode: 'fer')
    xml = File.new(fixture_path + '/index_transport_mode.xml')
    stub_request(:get, url).to_return(body: xml)
    operators = client.operators(transport_mode: 'fer')

    expect(operators.count).to equal(3)
    expect(operators.first).to be_a(Codifligne::Operator)
  end

  it 'should return operators on valid line request' do
    url = client.build_url(operator_name: 'RATP')
    xml = File.new(fixture_path + '/line.xml')
    stub_request(:get, url).to_return(body: xml)

    lines = client.lines(operator_name: 'RATP')

    expect(lines.count).to equal(382)
    expect(lines.first).to be_a(Codifligne::Line)
  end

  it 'should retrieve lines with Operator lines method' do
    url = client.build_url(operator_name: 'RATP')
    xml = File.new(fixture_path + '/line.xml')
    stub_request(:get, url).to_return(body: xml)

    expect(operator.lines.count).to equal(382)
  end

end
