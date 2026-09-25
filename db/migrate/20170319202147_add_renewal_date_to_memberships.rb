class AddRenewalDateToMemberships < ActiveRecord::Migration[4.2]
  def up
    ActiveRecord::Base.transaction do
      add_column :memberships, :renewal_date, :datetime
      initialize_renewal_date_to(Time.now)
    end
  end

  def down
    remove_column :memberships, :renewal_date
  end

  def initialize_renewal_date_to(initial_date)
    sql_date_format = '%Y-%m-%d %H:%i:%s'
    ruby_date_format = '%Y-%m-%d %H:%M:%S'
    initial_date_string = initial_date.strftime(ruby_date_format)
    query = <<-EOQ
      UPDATE memberships SET renewal_date = STR_TO_DATE('#{initial_date_string}', '#{sql_date_format}')
    EOQ
    ActiveRecord::Base.connection.execute(query, initial_date)
  end
end
