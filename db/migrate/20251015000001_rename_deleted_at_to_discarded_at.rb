class RenameDeletedAtToDiscardedAt < ActiveRecord::Migration[7.2]
  def change
    # Rename deleted_at columns to discarded_at for Discard gem compatibility
    # This maintains the same soft-delete functionality with updated naming

    rename_column :people, :deleted_at, :discarded_at if column_exists?(:people, :deleted_at)
    rename_column :memberships, :deleted_at, :discarded_at if column_exists?(:memberships, :deleted_at)
    rename_column :membership_types, :deleted_at, :discarded_at if column_exists?(:membership_types, :deleted_at)
    rename_column :addresses, :deleted_at, :discarded_at if column_exists?(:addresses, :deleted_at)
  end
end
