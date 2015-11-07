defmodule WeatherPhoenix1.PageView do
  use WeatherPhoenix1.Web, :view
  def format_date(epoc_date) do
  {date, time} =  :calendar.gregorian_seconds_to_datetime epoc_date
  :qdate.to_string("n/j/Y", date)
  end
end
