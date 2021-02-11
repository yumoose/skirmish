class AddResetFieldsToUser < Jennifer::Migration::Base
  def up
    change_table(:users) do |t|
      t.add_column(:reset_digest, :string)
      t.add_column(:reset_sent_at, :timestamp)
      t.add_index(field: :reset_digest, name: "users_reset_digest_index", type: :uniq)
    end
  end

  def down
    change_table(:users) do |t|
      t.drop_column(:reset_digest)
      t.drop_column(:reset_sent_at)
    end
  end
end
