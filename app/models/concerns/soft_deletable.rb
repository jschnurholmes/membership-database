module SoftDeletable
  extend ActiveSupport::Concern

  included do
    include Discard::Model
    default_scope -> { kept }
  end

  # Soft-deletes, as paranoia's acts_as_paranoid did before the upgrade to Discard.
  def destroy
    discard
  end
end
