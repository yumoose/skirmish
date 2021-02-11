class AddVisibilityToLeagues < Jennifer::Migration::Base
  def up
    change_table(:leagues) do |t|
      t.add_column(:visibility, :string, { :size => 32 })
    end

    exec("
      UPDATE leagues
      SET visibility = 'open'
    ")
  end

  def down
    change_table(:leagues) do |t|
      t.drop_column(:visibility)
    end
  end
end
