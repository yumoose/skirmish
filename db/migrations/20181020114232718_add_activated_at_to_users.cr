class AddActivatedAtToUsers < Jennifer::Migration::Base
  def up
    change_table(:users) do |t|
      t.add_column(:activated_at, :timestamp, { :default => nil })
    end

    exec("UPDATE users SET activated_at = users.created_at;")
  end

  def down
    change_table(:users) do |t|
      t.drop_column(:activated_at)
    end
  end
end
