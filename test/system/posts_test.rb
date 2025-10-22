require "application_system_test_case"

class PostsTest < ApplicationSystemTestCase
  setup do
    @post = posts(:one)
  end

  test "visiting the index" do
    visit posts_url
    assert_selector "h1", text: "Posts"
  end

  test "should create post" do
    visit posts_url
    click_on "New post"

    fill_in "Description", with: @post.description
    fill_in "Group", with: @post.group_id
    fill_in "Group type", with: @post.group_type
    fill_in "Img orizontal url", with: @post.img_orizontal_url
    fill_in "Img square url", with: @post.img_square_url
    fill_in "Img vertical url", with: @post.img_vertical_url
    fill_in "Meta", with: @post.meta
    fill_in "Published at", with: @post.published_at
    fill_in "Slug", with: @post.slug
    fill_in "Title", with: @post.title
    fill_in "User", with: @post.user_id
    click_on "Create Post"

    assert_text "Post was successfully created"
    click_on "Back"
  end

  test "should update Post" do
    visit post_url(@post)
    click_on "Edit this post", match: :first

    fill_in "Description", with: @post.description
    fill_in "Group", with: @post.group_id
    fill_in "Group type", with: @post.group_type
    fill_in "Img orizontal url", with: @post.img_orizontal_url
    fill_in "Img square url", with: @post.img_square_url
    fill_in "Img vertical url", with: @post.img_vertical_url
    fill_in "Meta", with: @post.meta
    fill_in "Published at", with: @post.published_at.to_s
    fill_in "Slug", with: @post.slug
    fill_in "Title", with: @post.title
    fill_in "User", with: @post.user_id
    click_on "Update Post"

    assert_text "Post was successfully updated"
    click_on "Back"
  end

  test "should destroy Post" do
    visit post_url(@post)
    accept_confirm { click_on "Destroy this post", match: :first }

    assert_text "Post was successfully destroyed"
  end
end
