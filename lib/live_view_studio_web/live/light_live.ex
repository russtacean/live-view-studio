defmodule LiveViewStudioWeb.LightLive do
  use LiveViewStudioWeb, :live_view

  def mount(_params, _session, socket) do
    socket =
      assign(socket, brightness: 10, temp: "3000")

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>Front Porch Light</h1>
    <div id="light">
      <div class="meter">
        <span style={"width: #{@brightness}%; background: #{temp_color(@temp)}"}>
          <%= @brightness %>
        </span>
      </div>
      <form phx-change="set-brightness">
        <input
          type="range"
          min="0"
          max="100"
          name="brightness"
          value={@brightness}
        />
      </form>
      <form phx-change="set-temp">
        <div class="temps">
          <%= for temp <- ["3000", "4000", "5000"] do %>
            <div>
              <input
                type="radio"
                id={temp}
                name="temp"
                value={temp}
                checked={temp == @temp}
              />
              <label for={temp}><%= temp %></label>
            </div>
          <% end %>
        </div>
      </form>
    </div>
    """
  end

  def handle_event("set-brightness", params, socket) do
    %{"brightness" => b} = params
    socket = assign(socket, brightness: String.to_integer(b))
    {:noreply, socket}
  end

  def handle_event("set-temp", params, socket) do
    %{"temp" => temp} = params
    socket = assign(socket, temp: temp)
    {:noreply, socket}
  end

  defp temp_color("3000"), do: "#F1C40D"
  defp temp_color("4000"), do: "#FEFF66"
  defp temp_color("5000"), do: "#99CCFF"
end
