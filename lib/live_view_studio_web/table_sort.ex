defmodule LiveViewStudioWeb.TableSort do
  def next_sort_order(sort_order) do
    case sort_order do
      :asc -> :desc
      :desc -> :asc
    end
  end

  def sort_indicator(column, %{sort_by: sort_by, sort_order: sort_order})
      when column == sort_by do
    case sort_order do
      :asc -> "👆"
      :desc -> "👇"
    end
  end

  def sort_indicator(_, _), do: ""
end
