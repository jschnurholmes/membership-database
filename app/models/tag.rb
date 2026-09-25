class Tag < ApplicationRecord
	has_and_belongs_to_many :people

	after_commit -> { Rails.cache.delete("tag_color_styles") }
end

