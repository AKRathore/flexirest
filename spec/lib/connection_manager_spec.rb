require 'spec_helper'

describe Flexirest::ConnectionManager do
  before(:each) do
    Flexirest::ConnectionManager.reset!
  end

  it "should have a get_connection method" do
    expect(Flexirest::ConnectionManager).to respond_to("get_connection")
  end

  it "should return a connection for a given base url" do
    connection = Flexirest::ConnectionManager.get_connection("http://www.example.com")
    expect(connection).to be_kind_of(Flexirest::Connection)
  end

  it "should return the same connection for each base url when re-requested" do
    connection = Flexirest::ConnectionManager.get_connection("http://www.example.com")
    expect(Flexirest::ConnectionManager.get_connection("http://www.example.com")).to eq(connection)
  end

  it "should return different connections for each base url when requested" do
    base_url = "http://www.example.com"
    other_base_url = "http://other.example.com"
    expect(Flexirest::ConnectionManager.get_connection(base_url).base_url).to eq(base_url)
    expect(Flexirest::ConnectionManager.get_connection(other_base_url).base_url).to eq(other_base_url)
    expect(Thread.current[:_connections].size).to eq(2)
  end

  it "should find a connection if you pass in URLs containing an existing connection's base_url" do
    base_url         = "http://www.example.com"
    connection       = Flexirest::ConnectionManager.get_connection(base_url)
    found_connection = Flexirest::ConnectionManager.find_connection_for_url("#{base_url}:8080/people/test")
    expect(found_connection).to eq(connection)
  end

  it "should call 'in_parllel' for a session and yield procedure inside that block" do
    Flexirest::Base.adapter = :typhoeus
    session = Flexirest::ConnectionManager.get_connection("http://www.example.com").session
    expect { |b| Flexirest::ConnectionManager.in_parallel("http://www.example.com", &b)}.to yield_control
    Flexirest::Base._reset_configuration!
  end
end
