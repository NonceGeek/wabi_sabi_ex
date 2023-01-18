defmodule WabiSabiExWeb.PageController do
  use WabiSabiExWeb, :controller

  def home(conn, _params) do
    render(conn, :home, active_tab: :home)
  end
end
