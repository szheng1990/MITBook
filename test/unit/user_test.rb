require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  test "a user should enter a first name"
    user = User.new
    assert !user.errors[:first_name].empty?
  end

  test "a user should have a unique profile name"
    user = User.new
    user.profile_name = users(:jason).profile_name
    assert !user.save
    assert !user.errors[:profile_name].empty?
  end


end
