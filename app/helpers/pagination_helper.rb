module PaginationHelper
  # Keeps the current filters and sort, and starts over at the first page.
  def per_page_link( pagy, limit, label = limit.to_s )
    current = pagy ? pagy.limit.to_s : 'all'
    query   = request.query_parameters.except('page').merge('limit' => limit.to_s).to_query
    link_to label, "#{request.path}?#{query}",
            class: class_names('btn btn-outline-secondary', active: current == limit.to_s),
            aria: { current: ('true' if current == limit.to_s) }
  end
end
