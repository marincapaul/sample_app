require "test_helper"

class MicropostsInterfaceTest < ActionDispatch::IntegrationTest
  
  def setup 
    @user=users(:paul)
  end
  
  test "microtest interface" do
    log_in_as(@user)
    get root_path
    assert_select 'div.pagination'
    assert_select 'input[type=file]'
    # invalid submission
    assert_no_difference 'Micropost.count' do
      post microposts_path, params: { micropost: { content: "" } }
    end
    assert_select 'div#error_explanation'
    assert_select 'a[href=?]', '/?page=2'
    # valid submission
    content = "This micropost really ties the room together"
    image = fixture_file_upload('test/fixtures/files/kitten.jpg', 'image/jpeg', :binary)
    assert_difference 'Micropost.count', 1 do
      post microposts_path, params: { micropost: { content: content, image: image } }
    end
    assert_redirected_to root_url
    assert @user.microposts.paginate(page: 1).first.image.attached?
    follow_redirect!
    assert_match content, response.body
    # delete post
    assert_select 'a', text: 'delete'
    first_post = @user.microposts.paginate(page: 1).first
    assert_difference 'Micropost.count', -1 do
      delete micropost_path(first_post)
    end
    # visit different users
    get user_path(users(:dan))
    assert_select 'a', text: 'delete', count: 0
  end

  test 'micropost sidebar count' do
    log_in_as(@user)
    get root_path
    assert_match "#{@user.microposts.count.to_s} microposts", response.body
    #user with 0 posts
    other_user = users(:malory)
    log_in_as(other_user)
    get root_path
    assert_match "0 microposts", response.body
    other_user.microposts.create!(content: "git gud")
    get root_path
    assert_match "1 micropost", response.body
  end
end
