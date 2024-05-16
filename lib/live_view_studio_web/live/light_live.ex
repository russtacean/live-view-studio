defmodule LiveViewStudioWeb.LightLive do
  use LiveViewStudioWeb, :live_view

  def mount(_params, _session, socket) do
    socket = assign(socket, brightness: 10)
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>Front Porch Light</h1>
    <div id="light">
      <div class="meter">
        <span style={"width: #{@brightness}%"}>
          <%= @brightness %>
        </span>
      </div>
      <form phx-change="set">
        <input
          type="range"
          min="0"
          max="100"
          name="brightness"
          value={@brightness}
        />
      </form>
    </div>
    """
  end

  def handle_event("set", params, socket) do
    %{"brightness" => b} = params
    socket = assign(socket, brightness: String.to_integer(b))
    {:noreply, socket}
  end
end
