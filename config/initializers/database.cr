require "colorize"
require "jennifer"
require "jennifer/adapter/postgres"

Jennifer::Config.from_uri(ENV["DATABASE_URL"]? || Amber.settings.database_url)

# Jennifer::Config.logger.formatter = Log::Formatter.new do |_, datetime, _, message, io|
#   io << datetime.colorize(:cyan) << ": \n" << message.colorize(:light_magenta)
# end
