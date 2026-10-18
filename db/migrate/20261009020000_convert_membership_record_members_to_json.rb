class ConvertMembershipRecordMembersToJson < ActiveRecord::Migration[7.2]
  def up
    rows = select_rows("SELECT id, members FROM membership_records WHERE members LIKE '---%'")

    transaction do
      rows.each do |id, yaml|
        execute "UPDATE membership_records SET members = #{quote(json_for(yaml))} WHERE id = #{Integer(id)}"
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  def json_for(yaml)
    ids = YAML.safe_load(yaml)
    unless ids.is_a?(Array) && ids.all?(Integer)
      raise "membership_records.members is not a list of person ids: #{yaml.inspect}"
    end

    ids.to_json
  end
end
