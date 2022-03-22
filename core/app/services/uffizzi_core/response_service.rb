# frozen_string_literal: true

module UffizziCore::ResponseService
  def meta(collection)
    {
      total_count: collection.total_count,
      current_page: collection.current_page,
      per_page: collection.limit_value,
      count: collection.to_a.count,
      total_pages: collection.total_pages,
    }
  end
end
