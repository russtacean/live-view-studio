defmodule LiveViewStudioWeb.ServersLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Servers
  alias LiveViewStudio.Servers.Server

  def mount(_params, _session, socket) do
    servers = Servers.list_servers()

    changeset = Servers.change_server(%Server{})

    socket =
      assign(socket,
        servers: servers,
        coffees: 0,
        form: to_form(changeset)
      )

    {:ok, socket}
  end

  def handle_params(%{"id" => id}, _uri, socket) when id != "" do
    server = Servers.get_server!(id)
    {:noreply, assign(socket, selected_server: server, page_title: "What's up #{server.name}")}
  end

  def handle_params(_params, _uri, socket) do
    selected_server =
      if socket.assigns.live_action == :new do
        nil
      else
        hd(socket.assigns.servers)
      end

    {:noreply, assign(socket, selected_server: selected_server)}
  end

  def render(assigns) do
    ~H"""
    <h1>Servers</h1>
    <div id="servers">
      <div class="sidebar">
        <div class="nav">
          <.link class="add" patch={~p"/servers/new"}>
            + Add new server
          </.link>
          <.link
            :for={server <- @servers}
            patch={~p"/servers/#{server}"}
            class={if server == @selected_server, do: "selected"}
          >
            <span class={server.status}></span>
            <%= server.name %>
          </.link>
        </div>
        <div class="coffees">
          <button phx-click="drink">
            <img src="/images/coffee.svg" />
            <%= @coffees %>
          </button>
        </div>
      </div>
      <div class="main">
        <%= if @live_action == :new do %>
          <.form for={@form} phx-change="validate" phx-submit="save">
            <div class="field">
              <.input
                field={@form[:name]}
                placeholder="Name"
                autocomplete="off"
                phx-debounce="1000"
              />
            </div>
            <div class="field">
              <.input
                field={@form[:framework]}
                placeholder="Framework"
                autocomplete="off"
                phx-debounce="1000"
              />
            </div>
            <div class="field">
              <.input
                field={@form[:size]}
                type="number"
                placeholder="Size (MB)"
                phx-debounce="blur"
              />
            </div>

            <.button phx-disable-with="Saving...">
              Save
            </.button>
            <.link class="cancel" patch={~p"/servers"}>
              Cancel
            </.link>
          </.form>
        <% else %>
          <div class="wrapper">
            <.server server={@selected_server} />
            <div class="links">
              <.link navigate={~p"/light"}>
                Adjust Lights
              </.link>
            </div>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  def server(assigns) do
    ~H"""
    <div class="server">
      <div class="header">
        <h2><%= @server.name %></h2>
        <button
          class={@server.status}
          phx-click="toggle-server"
          phx-value-id={@server.id}
        >
          <%= @server.status %>
        </button>
      </div>
      <div class="body">
        <div class="row">
          <span>
            <%= @server.deploy_count %> deploys
          </span>
          <span>
            <%= @server.size %> MB
          </span>
          <span>
            <%= @server.framework %>
          </span>
        </div>
        <h3>Last Commit Message:</h3>
        <blockquote>
          <%= @server.last_commit_message %>
        </blockquote>
      </div>
    </div>
    """
  end

  def handle_event("drink", _, socket) do
    {:noreply, update(socket, :coffees, &(&1 + 1))}
  end

  def handle_event("save", %{"server" => server_params}, socket) do
    case Servers.create_server(server_params) do
      {:ok, server} ->
        socket = update(socket, :servers, fn servers -> [server | servers] end)
        socket = put_flash(socket, :info, "Sucessfully saved server")
        socket = push_patch(socket, to: ~p"/servers/#{server.id}")

        changeset = Servers.change_server(%Server{})

        {:noreply, assign(socket, :form, to_form(changeset))}

      {:error, changeset} ->
        IO.inspect(changeset)
        socket = put_flash(socket, :error, "Unable to save server")
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  def handle_event("validate", %{"server" => server_params}, socket) do
    changeset =
      %Server{}
      |> Servers.change_server(server_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: to_form(changeset))}
  end

  def handle_event("toggle-server", %{"id" => id}, socket) do
    server = Servers.get_server!(id)
    {:ok, server} = Servers.toggle_server_status(server)

    servers =
      Enum.map(socket.assigns.servers, fn s ->
        if s.id == server.id, do: server, else: s
      end)

    {:noreply, assign(socket, selected_server: server, servers: servers)}
  end
end
