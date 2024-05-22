defmodule LiveViewStudioWeb.TopSecretLive do
  use LiveViewStudioWeb, :live_view

  # Causes LiveViewStudioWeb.UserAuth.on_mount matching the atom here to be called
  # Called before both the initial disconnected mount (initial render), and
  # the subsequent connected mount (websocket connection).
  # Seemingly this doubles up on authentication the router plug is also doing,
  # but we want this here as well in case a link navigates/patches to this liveview
  # over an existing websocket connection
  on_mount {LiveViewStudioWeb.UserAuth, :ensure_authenticated}

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  defp pad_user_id(user) do
    user.id
    |> Integer.to_string()
    |> String.pad_leading(3, "0")
  end

  def render(assigns) do
    ~H"""
    <div id="top-secret">
      <img src="/images/spy.svg" />
      <div class="mission">
        <h1>Top Secret</h1>
        <h2>Your Mission</h2>
        <h3><%= "#{pad_user_id(@current_user)}" %></h3>
        <p>
          Storm the castle and capture 3 bottles of Elixir.
        </p>
      </div>
    </div>
    """
  end
end
