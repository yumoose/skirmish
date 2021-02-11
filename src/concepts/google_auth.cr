require "oauth2"
require "http/server"
require "uri"

class GoogleAuth
  @access_token : OAuth2::AccessToken?

  def initialize(@host : String, @client_id : String, @client_secret : String,
      @authorize_uri : String,
      @token_uri : String,
      @redirect_uri : String? = nil)

    @oauth_client = OAuth2::Client.new(
        @host,
        @client_id,
        @client_secret,
        authorize_uri: @authorize_uri,
        token_uri: @token_uri,
        redirect_uri: @redirect_uri
      )
  end

  def get_authorize_uri(scope = nil) : String
    @oauth_client.get_authorize_uri(scope)
  end

  def get(resource, @auth_code : String)
    access_token = @oauth_client.get_access_token_using_authorization_code(@auth_code.not_nil!)

    client = HTTP::Client.new("www.googleapis.com", tls: true)
    access_token.authenticate(client)
    client.get(resource)
  end
end
