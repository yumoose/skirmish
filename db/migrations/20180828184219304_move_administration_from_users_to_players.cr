class MoveAdministrationFromUsersToPlayers < Jennifer::Migration::Base
  def up
    exec("ALTER TABLE administrators ADD COLUMN IF NOT EXISTS player_id BIGSERIAL;")

    exec(
      "DO $$
        BEGIN
            BEGIN
              UPDATE administrators
              SET player_id = players.id
              FROM players
              JOIN users ON players.user_id = users.id
              WHERE users.id = administrators.user_id
              AND player_id IS NULL;
            EXCEPTION
                WHEN undefined_column THEN RAISE NOTICE 'column <column_name> does not exist in <table_name>. Skipping update.';
            END;
        END;
      $$"
    )

    exec("ALTER TABLE administrators ALTER COLUMN player_id SET NOT NULL;")
    exec("ALTER TABLE administrators DROP CONSTRAINT IF EXISTS administrators_player_id_fkey")
    exec("ALTER TABLE administrators ADD CONSTRAINT administrators_player_id_fkey FOREIGN KEY (player_id) REFERENCES players (id) MATCH FULL ON DELETE CASCADE;")
  end

  def down
    exec("ALTER TABLE administrators DROP COLUMN player_id;")
  end
end
