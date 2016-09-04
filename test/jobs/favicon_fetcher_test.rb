require 'test_helper'

class FaviconFetcherTest < ActiveSupport::TestCase
  setup do
    @page_url = URI::parse("http://example.com")
    @icon_url = @page_url.dup
    @icon_url.path = "/icons/favicon.ico"
    @default_url = @page_url.dup
    @default_url.path = "/favicon.ico"
  end

  test "should get favicon from icon link" do
    body = <<-eot
    <html>
        <head>
            <link rel="icon" href="#{@icon_url.path}">
        </head>
    </html>
    eot

    stub_request(:get, @page_url).
      to_return(body: body, status: 200)

    stub_request_file("favicon.ico", @icon_url)

    FaviconFetcher.new().perform(@page_url.host)

    assert_not_nil Favicon.where(host: @page_url.host).take!.favicon
  end

  test "should get favicon from shortcut icon link" do
    body = <<-eot
    <html>
        <head>
            <link rel="shortcut icon" href="#{@icon_url.to_s}">
        </head>
    </html>
    eot

    stub_request(:get, @page_url).
      to_return(body: body, status: 200)

    stub_request_file("favicon.ico", @icon_url)

    FaviconFetcher.new().perform(@page_url.host)

    assert_not_nil Favicon.where(host: @page_url.host).take!.favicon
  end

  test "should get favicon from default location" do
    body = <<-eot
    <html>
        <head>
        </head>
    </html>
    eot

    stub_request(:get, @page_url).
      to_return(body: body, status: 200)

    stub_request_file("favicon.ico", @default_url)

    FaviconFetcher.new().perform(@page_url.host)

    assert_not_nil Favicon.where(host: @page_url.host).take!.favicon
  end

end