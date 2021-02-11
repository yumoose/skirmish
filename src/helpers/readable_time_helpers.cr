module ReadableTimeHelpers
  def time_units_since(time : Time | Nil)
    return "-" if time.nil?

    span = Time.local - time

    if span.total_weeks.to_i > 0
      if span.total_weeks.to_i == 1
        "last week"
      else
        "#{span.total_weeks.to_i} weeks ago"
      end
    elsif span.total_days.to_i > 0
      if span.total_days.to_i == 1
        "yesterday"
      else
        "#{span.total_days.to_i} days ago"
      end
    elsif span.total_hours.to_i > 0
      if span.total_hours.to_i == 1
        "an hour ago"
      else
        "#{span.total_hours.to_i} hours ago"
      end
    elsif span.total_minutes.to_i > 0
      if span.total_minutes.to_i == 1
        "a minute ago"
      else
        "#{span.total_minutes.to_i} minutes ago"
      end
    elsif span.total_seconds.to_i > 0
      if span.total_seconds.to_i == 1
        "a second ago"
      else
        "#{span.total_seconds.to_i} seconds ago"
      end
    else
      "now"
    end
  end
end
