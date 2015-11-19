defmodule WeatherPhoenix1.PageController do
  use WeatherPhoenix1.Web, :controller

  @api_token "9dbfcd557bbda142ce4ae277b5d24e3b"
  @weather_url_api "api.openweathermap.org/data/2.5/forecast/daily"
#  api.openweathermap.org/data/2.5/forecast/daily?q=London&mode=json&cnt=3&units=metric&appid=2de143494c0b295cca9337e1e96b00e0
  @weather_url_api_today "api.openweathermap.org/data/2.5/weather"
  @api_no_data_error  "{\"cod\":\"404\",\"message\":\"Error: Not found city\"}\n"
  @api_data_list  "{\"cod\":\"200\",\"list\": forecast_list }\n"

  def fetch_today(city) do
    city
    |> weather_url_today
    |> HTTPoison.get
    |> parse_response
  end

  def fetch(city) do
    city
    |> weather_url
    |> HTTPoison.get
    |> parse_response
  end

  def weather_url_today(city, format \\ "html", units \\"metric") do
      # old way  "#{@weather_url_api_today}?q=#{city}&mode=#{format}&unit=#{unit}&&APPID=#{@api_token}"
    url_params_encoded = URI.encode_query %{
    		       "q" => city , 
		       "mode" => format, 
		       "unit" => units, 
		       "appid" => @api_token
		       }
    "#{@weather_url_api_today}?#{url_params_encoded}"
  end

  def weather_url(city, format \\ "json", units \\"metric", number_of_days \\ 3 ) do
    # old way "#{@weather_url_api}?q=#{city}&mode=#{format}&cnt=#{number_of_days}&unit=#{unit}&&APPID=#{@api_token}"
    url_params_encoded = URI.encode_query %{
    		    "q" => city , 
    		    "mode" => format, 
		    "units" => units, 
		    "cnt" => number_of_days , 
		    "appid" => @api_token
		    }
    IO.inspect "#{@weather_url_api}}?#{url_params_encoded}"
    "#{@weather_url_api}?#{url_params_encoded}"
  end

  def parse_response({:ok, %HTTPoison.Response{status_code: 200, body: body}}) do
    parse_body(body)
  end

  def parse_body(@api_no_data_error) do
     %{:error_message => "City Not Found"}
  end

  def parse_body(body) do
    %{:response_body  => body}
  end


  def parse_response({:ok, %HTTPoison.Response{status_code: 404, body: a_body }}) do
    %{:error_message => "No weather data is available for this city"}
  end

  def parse_response({:error, %HTTPoison.Error{reason: reason}}) do
    IO.inspect reason
    %{:error_message => "Have some problems communicating to weather server ...."}
  end

# parse City not found response 
  def format_render_response(conn, %{error_message: a_message},%{error_message: today_message})
 do
  conn
    |> assign(:today, "")
    |> assign(:w_data, [])
    |> put_flash(:info, a_message)
    |> render("index.html")
  end

 # Valid json goes here and need to parse valid string
  def format_render_response(conn, %{response_body: a_body},  %{response_body: today_body} ) do
    IO.puts a_body
    response = Poison.Parser.parse!(a_body)
    conn
    |> assign(:w_data, response["list"])
    |> assign(:today, today_body)
    |> render("index.html")
  end

  def index(conn, _params) do
  conn
    |> assign(:city, "Detroit")
    |> assign(:today, "")
    |> assign(:w_data, [])
    |> render("index.html")
  end

  def show_weather(conn, %{"city" => city}) do
  
  a_response = fetch(city)
  a_today = fetch_today(city)
  conn
    |> assign(:city, city)
    |> format_render_response(a_response, a_today)
  end

end
