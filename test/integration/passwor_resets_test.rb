require "test_helper"

class PassworResetsTest < ActionDispatch::IntegrationTest
  def setup
    ActionMailer::Base.deliveries.clear
    @user = users(:paul)
  end

  test "password reset" do
    get new_passwor_reset_path
    assert_template 'passwor_resets/new'
    assert_select 'input[name=?]', 'passwor_reset[email]'
    # invalid email
    post passwor_resets_path, params: { passwor_reset: { email: "" } }
    assert_not flash.empty?
    assert_template 'passwor_resets/new'
    # valid email
    post passwor_resets_path, params: { passwor_reset: { email: @user.email } }
    assert_not_equal @user.reset_digest, @user.reload.reset_digest
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_not flash.empty?
    assert_redirected_to root_url
    # Password reset form
    user = assigns(:user)
    # Wrong email
    get edit_passwor_reset_path(user.reset_token, email: "")
    assert_redirected_to root_url
    # Inactive user
    user.toggle!(:activated)
    get edit_passwor_reset_path(user.reset_token, email: user.email)
    assert_redirected_to root_url
    user.toggle!(:activated)
    # Right email, wrong token
    get edit_passwor_reset_path("wrong_token", email: user.email)
    assert_redirected_to root_url
    # Right email, right token
    get edit_passwor_reset_path(user.reset_token, email: user.email)
    assert_template 'passwor_resets/edit'
    assert_select "input[name=email][type=hidden][value=?]", user.email
    # Invalid password confirmation
    patch passwor_reset_path(user.reset_token),
          params: { email: user.email,
                    user: { password:               "foobaz",
                            password_confirmation:  "barquiz" } }
    assert_select 'div#error_explanation'
    # Empty password
    patch passwor_reset_path(user.reset_token),
          params: { email: user.email,
                    user: { password:               "",
                            password_confirmation:  "" } }
    assert_select 'div#error_explanation'
    assert_not is_logged_in?
    # Valid password & confirmation
    patch passwor_reset_path(user.reset_token),
          params: { email: user.email,
                    user: { password:               "foobaz",
                            password_confirmation:  "foobaz" } }
    assert is_logged_in?
    assert_not flash.empty?
    assert_nil user.reload.reset_digest
    assert_redirected_to user
  end

  test "expired token" do
    get new_passwor_reset_path
    post passwor_resets_path,
         params: { passwor_reset: { email: @user.email } }
    @user = assigns(:user)
    @user.update_attribute(:reset_sent_at, 3.hours.ago)
    patch passwor_reset_path(@user.reset_token), 
          params: { email: @user.email,
                    user: { password:               "foobar",
                            password_confirmation:  "foobar" } }
    assert_response :redirect
    follow_redirect!
    assert_match /expired/i, response.body
  end
end
