module Reports
  class Selection
    PERSON_FILTERS = %i[with_tags without_tags with_members in_membership_periods].freeze

    def initialize(base, query = {})
      @base  = base
      @query = normalize((query || {}).to_h.symbolize_keys)
    end

    def search
      @search ||= @base.ransack(@query)
    end

    def result
      search.result
    end

    def members_of(membership)
      return membership.members if person_filters.empty?

      membership.members.select { |person| allowed_person_ids.include?(person.id) }
    end

    private

    def normalize(query)
      query = query.transform_values { |value| value.is_a?(Array) ? value.reject(&:blank?) : value }.
                    reject { |_key, value| value.blank? }

      tag_names = query.delete(:tag_names)
      tag_mode  = query.delete(:tag_mode)
      return query if tag_names.blank?

      tag_scope = tag_mode.to_s == 'exclude' ? :without_tags : :with_tags
      query.merge(tag_scope => tag_names)
    end

    def person_filters
      @person_filters ||= @query.slice(*PERSON_FILTERS)
    end

    def allowed_person_ids
      @allowed_person_ids ||= Person.ransack(person_filters).result.pluck(:id).to_set
    end
  end
end
