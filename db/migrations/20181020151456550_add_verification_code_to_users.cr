class AddVerificationCodeToUsers < Jennifer::Migration::Base
  def up
    change_table(:users) do |t|
      t.add_column(:verification_code, :string, { :size => 16 })
    end

    exec(
      "UPDATE users SET verification_code = (SELECT array_to_string(ARRAY(SELECT chr((97 + round(random() * 25)) :: integer)
      FROM generate_series(1,16)), ''));"
    )
  end

  def down
    change_table(:users) do |t|
      t.drop_column(:verification_code)
    end
  end
end
