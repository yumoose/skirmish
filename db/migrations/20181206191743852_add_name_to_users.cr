class AddNameToUsers < Jennifer::Migration::Base
  def up
    change_table(:users) do |t|
      t.add_column(:name, :string, { :size => 128 })
    end

    exec("
      UPDATE users
      SET name = players.tag
      FROM players
      WHERE users.id = players.user_id;
    ")
  end

  def down
    change_table(:users) do |t|
      t.drop_column(:name)
    end
  end
end
