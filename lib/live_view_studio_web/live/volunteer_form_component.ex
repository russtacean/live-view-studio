defmodule LiveViewStudioWeb.VolunteerFormComponent do
  use LiveViewStudioWeb, :live_component

  alias LiveViewStudio.Volunteers
  alias LiveViewStudio.Volunteers.Volunteer

  def mount(socket) do
    changeset = Volunteers.change_volunteer(%Volunteer{})
    {:ok, assign(socket, :form, to_form(changeset))}
  end

  def update(assigns, socket) do
    socket =
      socket
      # This is the default behavior if update() is not defined explicity
      |> assign(assigns)
      # This is behavior we're adding
      |> assign(:count, assigns.count + 1)

    {:ok, socket}
  end

  def render(assigns) do
    # Live components require a single static HTML component at their root
    # hence the div here
    ~H"""
    <div>
      <div class="count">
        Go for it, you'll be volunteer number <%= @count %>
      </div>
      <.form
        for={@form}
        phx-change="validate"
        phx-submit="save"
        phx-target={@myself}
      >
        <.input
          field={@form[:name]}
          placeholder="Name"
          autocomplete="off"
          phx-debounce="1000"
        />
        <.input
          field={@form[:phone]}
          type="tel"
          placeholder="Phone"
          phx-debounce="blur"
        />
        <.button phx-disable-with="Saving...">
          Check In
        </.button>
      </.form>
    </div>
    """
  end

  def handle_event("save", %{"volunteer" => volunteer_params}, socket) do
    case Volunteers.create_volunteer(volunteer_params) do
      {:ok, volunteer} ->
        # Live components run in the same process as the parent live view using them
        send(self(), {:volunteer_created, volunteer})

        socket = put_flash(socket, :info, "Volunteer successfully checked in.")

        changeset = Volunteers.change_volunteer(%Volunteer{})

        {:noreply, assign(socket, :form, to_form(changeset))}

      {:error, changeset} ->
        socket = put_flash(socket, :error, "Unable to check volunteer in.")
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  def handle_event("validate", %{"volunteer" => volunteer_params}, socket) do
    changeset =
      %Volunteer{}
      |> Volunteers.change_volunteer(volunteer_params)
      # Action needs to be non-nil for errors to show on form
      |> Map.put(:action, :validate)

    socket = assign(socket, form: to_form(changeset))
    {:noreply, socket}
  end
end
