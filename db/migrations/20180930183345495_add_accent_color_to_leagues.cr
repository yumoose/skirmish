class AddAccentColorToLeagues < Jennifer::Migration::Base
  def up
    change_table(:leagues) do |t|
      t.add_column(:accent_color, :string, { :default => "#fd971f", :size => 9 })
    end
  end

  def down
    change_table(:leagues) do |t|
      t.drop_column(:accent_color)
    end
  end
end
