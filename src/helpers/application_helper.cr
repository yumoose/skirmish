module ApplicationHelper
  def bundle_request_version
    Time.now.to_s(I18n.translate("formats.time.iso_date_hour"))
  end
end
