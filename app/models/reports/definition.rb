module Reports
  class Definition
    REPORTS = {
      address_list: {
        label:    'Address List',
        base:     'Membership',
        path:     'reports_address_list_path',
        formats:  %i[csv],
        filters:  %i[tags mailing_preference membership_period],
        defaults: { tag_mode: 'exclude', tag_names: %w[banned deceased] }
      },
      email_list: {
        label:    'Email List',
        base:     'Person',
        path:     'reports_email_list_path',
        formats:  %i[text],
        filters:  %i[tags membership_period],
        defaults: { tag_mode: 'exclude', tag_names: %w[banned deceased] }
      },
      member_directory: {
        label:    'Member Directory',
        base:     'Membership',
        path:     'reports_member_directory_path',
        formats:  %i[csv],
        filters:  %i[tags membership_type membership_period],
        defaults: {}
      },
      member_list: {
        label:    'Member List',
        base:     'Person',
        path:     'reports_member_list_path',
        formats:  %i[html csv],
        filters:  %i[tags active_on],
        defaults: { tag_mode: 'exclude', tag_names: %w[banned deceased] }
      },
      membership_cards: {
        label:    'Membership Cards',
        base:     'Person',
        path:     'reports_membership_cards_path',
        formats:  %i[html],
        filters:  %i[tags active_on members],
        defaults: { active_on: -> { Organization.today } }
      }
    }.freeze

    FILTER_PARAMS = {
      tags:               [:tag_mode, { tag_names: [] }],
      mailing_preference: [{ with_mailing_preferences: [] }],
      membership_type:    [{ with_membership_types: [] }],
      active_on:          [:active_on],
      members:            [{ with_members: [] }],
      membership_period:  [{ in_membership_periods: [] }]
    }.freeze

    def self.all
      REPORTS.keys.map { |key| new(key) }
    end

    def self.exists?(key)
      REPORTS.key?(key.to_s.to_sym)
    end

    def self.find(key)
      key = key.to_sym
      raise ArgumentError, "unknown report: #{key}" unless REPORTS.key?(key)

      new(key)
    end

    attr_reader :key

    def initialize(key)
      @key = key.to_sym
    end

    def label
      attributes[:label]
    end

    def base
      attributes[:base].constantize
    end

    def path_helper
      attributes[:path]
    end

    def formats
      attributes[:formats]
    end

    def filters
      attributes[:filters]
    end

    def permitted_params
      filters.flat_map { |filter| FILTER_PARAMS.fetch(filter) }
    end

    def defaults
      attributes[:defaults].transform_values { |value| value.respond_to?(:call) ? value.call : value }
    end

    private

    def attributes
      REPORTS.fetch(@key)
    end
  end
end
