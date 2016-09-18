require "./spec_helper"

private def handle(request, fallthrough = true)
  io = MemoryIO.new
  response = HTTP::Server::Response.new(io)
  context = HTTP::Server::Context.new(request, response)
  handler = Kemal::StaticFileHandler.new "#{__DIR__}/static", fallthrough
  handler.call context
  response.close
  io.rewind
  HTTP::Client::Response.from_io(io)
end

describe Kemal::StaticFileHandler do
  file_text = File.read "#{__DIR__}/static/dir/test.txt"

  it "should serve a file with content type and etag" do
    response = handle HTTP::Request.new("GET", "/dir/test.txt")
    response.status_code.should eq(200)
    response.headers["Content-Type"].should eq "text/plain"
    response.headers["Etag"].should contain "W/\""
    response.body.should eq(File.read("#{__DIR__}/static/dir/test.txt"))
  end

  it "should respond with 304 if file has not changed" do
    response = handle HTTP::Request.new("GET", "/dir/test.txt")
    response.status_code.should eq(200)
    etag = response.headers["Etag"]

    headers = HTTP::Headers{"If-None-Match" => etag}
    response = handle HTTP::Request.new("GET", "/dir/test.txt", headers)
    response.status_code.should eq(304)
    response.body.should eq ""
  end

  it "should not list directory's entries" do
    serve_static({"gzip" => true, "dir_listing" => false})
    response = handle HTTP::Request.new("GET", "/dir/")
    response.status_code.should eq(404)
  end

  it "should list directory's entries when config is set" do
    serve_static({"gzip" => true, "dir_listing" => true})
    response = handle HTTP::Request.new("GET", "/dir/")
    response.status_code.should eq(200)
    response.body.should match(/test.txt/)
  end

  it "should gzip a file if config is true, headers accept gzip and file is > 880 bytes" do
    serve_static({"gzip" => true, "dir_listing" => true})
    headers = HTTP::Headers{"Accept-Encoding" => "gzip, deflate, sdch, br"}
    response = handle HTTP::Request.new("GET", "/dir/bigger.txt", headers)
    response.status_code.should eq(200)
    response.headers["Content-Encoding"].should eq "gzip"
  end

  it "should not gzip a file if config is true, headers accept gzip and file is < 880 bytes" do
    serve_static({"gzip" => true, "dir_listing" => true})
    headers = HTTP::Headers{"Accept-Encoding" => "gzip, deflate, sdch, br"}
    response = handle HTTP::Request.new("GET", "/dir/test.txt", headers)
    response.status_code.should eq(200)
    response.headers["Content-Encoding"]?.should eq nil
  end

  it "should not gzip a file if config is false, headers accept gzip and file is > 880 bytes" do
    serve_static({"gzip" => false, "dir_listing" => true})
    headers = HTTP::Headers{"Accept-Encoding" => "gzip, deflate, sdch, br"}
    response = handle HTTP::Request.new("GET", "/dir/bigger.txt", headers)
    response.status_code.should eq(200)
    response.headers["Content-Encoding"]?.should eq nil
  end

  it "should not serve a not found file" do
    response = handle HTTP::Request.new("GET", "/not_found_file.txt")
    response.status_code.should eq(404)
  end

  it "should not serve a not found directory" do
    response = handle HTTP::Request.new("GET", "/not_found_dir/")
    response.status_code.should eq(404)
  end

  it "should not serve a file as directory" do
    response = handle HTTP::Request.new("GET", "/dir/test.txt/")
    response.status_code.should eq(404)
  end

  it "should handle only GET and HEAD method" do
    %w(GET HEAD).each do |method|
      response = handle HTTP::Request.new(method, "/dir/test.txt")
      response.status_code.should eq(200)
    end

    %w(POST PUT DELETE).each do |method|
      response = handle HTTP::Request.new(method, "/dir/test.txt")
      response.status_code.should eq(404)
      response = handle HTTP::Request.new(method, "/dir/test.txt"), false
      response.status_code.should eq(405)
      response.headers["Allow"].should eq("GET, HEAD")
    end
  end
end
