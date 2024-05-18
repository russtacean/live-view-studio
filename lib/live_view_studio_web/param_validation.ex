defmodule LiveViewStudioWeb.ParamValidation do
  @moduledoc """
  Defines a set of functions for validating query/path params
  """

  @doc """
  Tries to parse an integer, returning the default value if unable to parse

  ## Examples
      iex> param_to_integer("10", 1)
      10

      iex> param_to_integer(nil, 3)
      3

      iex> param_to_integer("foo", 2)
      2
  """
  def param_to_integer(nil, default), do: default

  def param_to_integer(param, default) do
    case Integer.parse(param) do
      {number, _} -> number
      :error -> default
    end
  end

  @doc """
  Parses sort order from param map and returns it as an atom.
  When an invalid sort order is provided, defaults to ascending sort

  ## Examples
      iex> valid_sort_order(%{"sort_order" => "desc"})
      :desc

      iex> valid_sort_order(%{"sort_order" => "foo"})
      :asc
  """
  def valid_sort_order(%{"sort_order" => sort_order})
      when sort_order in ~w(asc desc) do
    String.to_atom(sort_order)
  end

  def valid_sort_order(_params), do: :asc
end
