require "test_helper"

class BadgeTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(email: "badge-test@example.com", password: "password123", role: :super_admin)
  end

  test "valid with a catalog key" do
    badge = Badge.new(user: @user, key: "top_referrer", period: Date.current.beginning_of_month)
    assert badge.valid?
  end

  test "invalid with an unknown key" do
    badge = Badge.new(user: @user, key: "not_a_real_badge", period: Date.current.beginning_of_month)
    assert_not badge.valid?
  end

  test "enforces uniqueness per user, key, and period" do
    period = Date.current.beginning_of_month
    Badge.create!(user: @user, key: "top_referrer", period: period)
    duplicate = Badge.new(user: @user, key: "top_referrer", period: period)
    assert_not duplicate.valid?
  end

  test "exposes title, description, and icon from the catalog" do
    badge = Badge.new(user: @user, key: "hundred_k_club", period: Date.current.beginning_of_month)
    assert_equal "100k Club", badge.title
    assert_equal "bi-cash-stack", badge.icon
  end
end
