defmodule LiveViewStudioWeb.PizzaOrdersLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.PizzaOrders
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

  def handle_params(params, _uri, socket) do
    sort_order = ParamValidation.valid_sort_order(params)
    sort_by = valid_sort_by(params)

    options = %{sort_order: sort_order, sort_by: sort_by}
    pizza_orders = PizzaOrders.list_pizza_orders(options)

    socket = assign(socket, pizza_orders: pizza_orders, options: options)
    {:noreply, socket}
  end

  defp valid_sort_by(%{"sort_by" => sort_by})
       when sort_by in ~w(size style topping_1 topping_2 price) do
    String.to_atom(sort_by)
  end

  defp valid_sort_by(_params), do: :id
end
