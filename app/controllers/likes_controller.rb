class LikesController < ApplicationController
  before_action :set_params
  before_action :authenticate_user!

  def create
    if @user.liked_articles.include?(@article)
      destroy
    else
      @like = @article.likes.create(liker: @user)

      respond_to do |format|
        if @like.save
          format.turbo_stream do
            render turbo_stream: turbo_stream.update("likes article_#{@article.id}", @article.likes.count)
          end
          format.html { redirect_to articles_url, notice: 'Liked' }
        end
      end
    end
  end

  def destroy
    @like = @user.likes.find_by(liked_article: @article)

    @like.destroy
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.update("likes article_#{@article.id}", @article.likes.count)
      end
      format.html { redirect_to articles_url }
      format.json { head :no_content }
    end
  end

  private

  def set_params
    @article = Article.find(params[:article_id])
    @user = current_user
  end
end
