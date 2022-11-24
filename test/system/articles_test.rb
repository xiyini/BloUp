require 'application_system_test_case'

class ArticlesTest < ApplicationSystemTestCase
  setup do
    login_as users(:three)
    @article = articles(:six)
  end

  test 'visiting the index' do
    visit articles_url
    assert_selector 'div'
  end

  test 'should create article' do
    visit articles_url
    click_on 'New article'

    fill_in 'article_body', with: @article.body
    click_on 'Create Article'

    assert_text @article.body
  end

  # test 'should update Article' do
  #   visit article_url(@article)
  #   click_on 'Edit this article', match: :first

  #   fill_in 'Body', with: @article.body
  #   click_on 'Update Article'

  #   assert_text 'Article was successfully updated'
  #   click_on 'Back'
  # end

  # test 'should destroy Article' do
  #   visit article_url(@article)
  #   click_on 'Destroy this article', match: :first

  #   assert_text 'Article was successfully destroyed'
  # end
end
