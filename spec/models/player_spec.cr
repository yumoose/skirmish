require "./spec_helper"
require "../../src/models/player.cr"

describe Player do
  Spec.before_each do
    Player.all.destroy
  end
end
