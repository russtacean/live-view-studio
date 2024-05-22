defmodule LiveViewStudioWeb.ServerFormComponent do
  use LiveViewStudioWeb, :live_component

  alias LiveViewStudio.Servers
  alias LiveViewStudio.Servers.Server

  def mount(socket) do
    changeset = Servers.change_server(%Server{})
    {:ok, assign(socket, :form, to_form(changeset))}
  end

  def render(assigns) do
    ~H"""
    <div>
      <.form
        for={@form}
        phx-change="validate"
        phx-submit="save"
        phx-target={@myself}
      >
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
    </div>
    """
  end

  def handle_event("save", %{"server" => server_params}, socket) do
    case Servers.create_server(server_params) do
      {:ok, server} ->
        send(self(), {:server_created, server})
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
end