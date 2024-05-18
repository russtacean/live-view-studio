defmodule LiveViewStudioWeb.DonationsLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Donations
  alias LiveViewStudioWeb.Pagination
  alias LiveViewStudioWeb.ParamValidation
  alias LiveViewStudioWeb.TableSort

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(params, _uri, socket) do
    sort_by = valid_sort_by(params)
    sort_order = ParamValidation.valid_sort_order(params)
    page = ParamValidation.param_to_integer(params["page"], 1)
    per_page = ParamValidation.param_to_integer(params["per_page"], 5)

    donation_count = Donations.count_donations()

    options = %{
      sort_by: sort_by,
      sort_order: sort_order,
      page: page,
      per_page: per_page
    }

    donations = Donations.list_donations(options)

    socket =
      assign(socket,
        donations: donations,
        donation_count: donation_count,
        options: options
      )

    {:noreply, socket}
  end

  def valid_sort_by(%{"sort_by" => sort_by})
      when sort_by in ~w(item quantity days_until_expires) do
    String.to_atom(sort_by)
  end

  def valid_sort_by(_params), do: :id

  attr :sort_by, :atom, required: true
  attr :options, :map, required: true
  slot :inner_block, required: true

  def sort_link(assigns) do
    params = %{
      assigns.options
      | sort_by: assigns.sort_by,
        sort_order: TableSort.next_sort_order(assigns.options.sort_order)
    }

    assigns = assign(assigns, params: params)

    ~H"""
    <.link patch={~p"/donations?#{@params}"}>
      <%= render_slot(@inner_block) %>
      <%= TableSort.sort_indicator(@sort_by, @options) %>
    </.link>
    """
  end

  def handle_event("select-per-page", %{"per-page" => per_page}, socket) do
    params = %{socket.assigns.options | per_page: per_page}
    # push_patch causes handle_params to be invoked, same as clicking patch link on UI
    socket = push_patch(socket, to: ~p"/donations?#{params}")
    {:noreply, socket}
  end
end
