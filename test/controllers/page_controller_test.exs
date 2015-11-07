defmodule WeatherPhoenix1.PageControllerTest do
  use WeatherPhoenix1.ConnCase

  test "GET /" do
    conn = get conn(), "/"
    assert html_response(conn, 200) 
  end

  test "POST /weather" do
    conn = get conn(), "/weather"
    assert html_response(conn, 404) 
  end

end
