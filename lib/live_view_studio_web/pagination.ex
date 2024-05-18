defmodule LiveViewStudioWeb.Pagination do
  def more_pages?(options, item_count) do
    options.page * options.per_page < item_count
  end

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
