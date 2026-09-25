json.array!(@memberships) do |membership|
  json.extract! membership, :id, :membership_type_id, :effective_date, :expiration_date
  json.url membership_url(membership, format: :json)
end
