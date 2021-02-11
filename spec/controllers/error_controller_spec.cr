require "./spec_helper"

include GarnetSpec::RequestHelper

# Controller Unit Test
describe ErrorController do
  request = HTTP::Request.new("get", "/")
  response = HTTP::Server::Response.new(IO::Memory.new)
  context = HTTP::Server::Context.new(request, response)
  exception = Amber::Exceptions::Base.new
  subject = ErrorController.new(context, exception)

  describe "#not_found" do
    it "renders a 404 error page" do
      subject.not_found.should contain HTML.escape(I18n.translate("error.title.not_found"))
      subject.not_found.should contain HTML.escape(I18n.translate("error.message.not_found"))
    end
  end

  describe "#forbidden" do
    it "renders a 403 error page" do
      subject.forbidden.should contain HTML.escape(I18n.translate("error.title.forbidden"))
      subject.forbidden.should contain HTML.escape(I18n.translate("error.message.forbidden"))
    end
  end

  describe "#internal_server_error" do
    it "renders a 500 error page" do
      subject.internal_server_error.should contain HTML.escape(I18n.translate("error.title.internal_server_error"))
      subject.internal_server_error.should contain HTML.escape(I18n.translate("error.title.internal_server_error"))
    end
  end
end

describe ErrorController do
  it "renders a 404 error page" do
    response = get "/non-existent-route" # If this route exists, the test must be changed

    response.status_code.should eq 404
    response.body.should contain "Page not found"
  end
end
