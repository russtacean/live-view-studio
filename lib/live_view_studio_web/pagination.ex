defmodule LiveViewStudioWeb.Pagination do
  @moduledoc """
  This is a collection of functions used to aid in creating pagination controls
  in tables.
  """

  @doc """
  Determines if there are more pages after the current page given the number of
  items rendered per page and the total number of items for the table

  ## Examples
      iex> more_pages?(%{page: 2, page_size: 20}, 50)
      true

      iex> more_pages?(%{page: 1, page_size: 30}, 20)
      false
  """
  def more_pages?(options, item_count) do
    options.page * options.per_page < item_count
  end

  @doc """
  Gives a spread of pages, starting with the current page and potentially producing
  2 pages before and 2 pages after if they are valid pages given the item count

  ## Examples
      iex> pages(%{page: 3, page_size: 10}, 50)
      [{1, false}, {2, false}, {3, true}, {4, false}, {5, false}]

      iex> pages(%{page: 1, page_size: 30}, 40)
      [{1, true}, {2, false}]
  """
  def pages(options, item_count) do
    page_count = ceil(item_count / options.per_page)

    for page_number <- (options.page - 2)..(options.page + 2), page_number > 0 do
      if page_number <= page_count do
        current_page? = page_number == options.page
        {page_number, current_page?}
      end
    end
  end
end
