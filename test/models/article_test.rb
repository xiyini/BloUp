require 'test_helper'

class ArticleTest < ActiveSupport::TestCase
  test 'should not save article without body' do
    article = Article.new
    assert_not article.save, 'Saved the article without a body'
  end

  test 'Should not save article without user' do
    article = Article.new(body: 'this is article')
    assert_not article.save, 'Saved the article without a user'
  end

  test 'Should save article with user and body' do
    article = Article.new(user_id: users(:one).id, body: 'good')
    assert article.save, 'Saved article with user and body'
  end
end
