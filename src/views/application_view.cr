require "../controllers/concerns/session_helper"
require "./shared_partials"

abstract class ApplicationView < ViewModel::Base
  include RouterHelper
  include SessionHelper
  include SharedPartials
  include ProfileHelper
  # include Pager::ViewHelper

  getter context : HTTP::Server::Context, page_title : String, flash : Amber::Router::Flash::FlashStore, current_user : User?

  def initialize(@context, @flash, @current_user, page_title = nil)
    @page_title = page_title || I18n.translate("application_view.title")
  end

  def_partial :footer
  def_partial :navigation
  def_partial :authenticated_nav
  def_partial :public_nav

  def csrf_tag
    Amber::Pipe::CSRF.tag(context)
  end

  def csrf_token
    Amber::Pipe::CSRF.token(context).to_s
  end

  def pluralize(count, word)
    if count > 1
      "#{count} #{Inflector.pluralize(word)}"
    else
      "#{count} #{word}"
    end
  end

  private def t(key, *args, **opts)
    I18n.translate(key, *args, **opts)
  end

  private def l(*args)
    I18n.localize(*args)
  end

  private def bundle_request_version
    Time.local.to_s(I18n.translate("formats.time.iso_date_hour"))
  end

  private def auth_page?
    auth_url_regexes = [/signup/, /signin/, /session/, /registration/, /multi_auth/]
    current_path = context.request.path

    auth_url_regexes.any? do |auth_url_regex|
      current_path.match(auth_url_regex)
    end
  end
end
