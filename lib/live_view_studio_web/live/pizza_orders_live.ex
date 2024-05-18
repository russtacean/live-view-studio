defmodule LiveViewStudioWeb.PizzaOrdersLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.PizzaOrders
  alias LiveViewStudioWeb.Pagination
  alias LiveViewStudioWeb.ParamValidation
  alias LiveViewStudioWeb.TableSort
  import Number.Currency

  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        pizza_orders: PizzaOrders.list_pizza_orders()
      )

    {:ok, socket}
  end

  def handle_params(params, _uri, socket) do
    sort_order = ParamValidation.valid_sort_order(params)
    sort_by = valid_sort_by(params)
    page = ParamValidation.param_to_integer(params["page"], 1)
    per_page = ParamValidation.param_to_integer(params["per_page"], 5)

    options = %{
      sort_order: sort_order,
      sort_by: sort_by,
      page: page,
      per_page: per_page
    }

    pizza_orders = PizzaOrders.list_pizza_orders(options)
    order_count = PizzaOrders.count_pizza_orders()

    socket =
      assign(
        socket,
        pizza_orders: pizza_orders,
        order_count: order_count,
        options: options
      )

    {:noreply, socket}
  end

  attr :sort_by, :atom, required: true
  attr :options, :map, required: true
  slot :inner_block, required: true

  def sort_link(assigns) do
    ~H"""
    <.link patch={
      ~p"/pizza-orders?#{%{sort_by: @sort_by, sort_order: TableSort.next_sort_order(@options.sort_order)}}"
    }>
      <%= render_slot(@inner_block) %>
      <%= TableSort.sort_indicator(@sort_by, @options) %>
    </.link>
    """
  end

  def handle_event("select-per-page", %{"per-page" => per_page}, socket) do
    params = %{socket.assigns.options | per_page: per_page}
    # push_patch causes handle_params to be invoked, same as clicking patch link on UI
    socket = push_patch(socket, to: ~p"/pizza-orders?#{params}")
    {:noreply, socket}
  end

  defp valid_sort_by(%{"sort_by" => sort_by})
       when sort_by in ~w(size style topping_1 topping_2 price) do
    String.to_atom(sort_by)
  end

  defp valid_sort_by(_params), do: :id
end
