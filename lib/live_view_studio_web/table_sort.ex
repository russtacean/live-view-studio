defmodule LiveViewStudioWeb.TableSort do
  @moduledoc """
  Defines functions that aid in creating table sort links
  """

  @doc """
  Determines what the next table sort order should be given the current sort order

  ## Examples
      iex> next_sort_order(:asc)
      :desc

      iex> next_sort_order(:desc)
      :asc

  """
  def next_sort_order(sort_order) do
    case sort_order do
      :asc -> :desc
      :desc -> :asc
    end
  end

  @doc """
  Provides a sort indicator for a column based on:
  1. Is it actively being sorted?
  2. If so, what is the sort ordering?

  ## Examples
      iex> sort_indicator(:quantity, %{sort_by: :quantity, sort_order: :asc})
      "👆"

      iex> sort_indicator(:price, %{sort_by: :quantity, sort_order: :asc})
      ""
  """
  def sort_indicator(column, %{sort_by: sort_by, sort_order: sort_order})
      when column == sort_by do
    case sort_order do
      :asc -> "👆"
      :desc -> "👇"
    end
  end

  def sort_indicator(_, _), do: ""
end
