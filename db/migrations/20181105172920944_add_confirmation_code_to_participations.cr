class AddConfirmationCodeToParticipations < Jennifer::Migration::Base
  def up
    change_table(:participations) do |t|
      t.add_column(:confirmation_code, :string, { :size => 16 })
    end

    exec(
      "UPDATE participations SET confirmation_code = (
        SELECT array_to_string(ARRAY(SELECT chr((97 + round(random() * 25)) :: integer)
        FROM generate_series(1,16)
        WHERE participations.id IS NOT NULL), '')
      );"
    )
  end

  def down
    change_table(:participations) do |t|
      t.drop_column(:confirmation_code)
    end
  end
end
