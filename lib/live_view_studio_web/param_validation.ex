defmodule LiveViewStudioWeb.ParamValidation do
  def param_to_integer(nil, default), do: default

  def param_to_integer(param, default) do
    case Integer.parse(param) do
      {number, _} -> number
      :error -> default
    end
  end

  def valid_sort_order(%{"sort_order" => sort_order})
      when sort_order in ~w(asc desc) do
    String.to_atom(sort_order)
  end

  def valid_sort_order(_params), do: :asc
end
