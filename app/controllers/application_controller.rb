class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :set_cache_buster

  include Pagy::Method

  UTF8_BOM = 0xFEFF.chr( Encoding::UTF_8 ).freeze

  PER_PAGE_OPTIONS = [20, 50, 100, 250].freeze
  DEFAULT_PER_PAGE = 100

  private

  # A limit of "all" skips pagination; pagy is nil then.
  def paginate( records )
    return [nil, records] if params[:limit] == 'all'

    pagy(:offset, records, limit: DEFAULT_PER_PAGE, client_limit: PER_PAGE_OPTIONS.max)
  end

  def set_cache_buster
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end

  # Excel guesses the encoding of a .csv opened from the filesystem, so the
  # UTF-8 declaration has to travel in the file itself as a byte order mark,
  # not only in the Content-Type header.
  def send_csv( data, **options )
    send_data UTF8_BOM + data, type: 'text/csv; charset=utf-8', **options
  end
end
