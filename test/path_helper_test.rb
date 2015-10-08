require 'helper'

scope Crest::PathHelper do
  setup do
    @subject = Class.new Cuba do
      plugin Crest::PathHelper
    end.new
  end

  scope '::define_paths_for' do
    setup do
      @subject.class.define_paths_for 'Article'

      @article = Article.new
    end

    test '#*s_path' do
      assert @subject.respond_to?(:articles_path)
      assert_equal @subject.articles_path, '/articles'
    end

    test '#*_path' do
      assert @subject.respond_to?(:article_path)
      assert_equal @subject.article_path(@article), "/articles/#{@article.id}"
    end

    test '#edit_*_path' do
      assert @subject.respond_to?(:edit_article_path)
      assert_equal @subject.edit_article_path(@article), "/articles/#{@article.id}/edit"
    end

    test '#new_*s_path' do
      assert @subject.respond_to?(:new_article_path)
      assert_equal @subject.new_article_path, '/articles/new'
    end

    scope 'works with a base uri defining a base_uri method' do
      setup do
        @subject.class.define_paths_for 'Article'

        def @subject.base_uri
          '/admin'
        end
      end

      test '#*s_path' do
        assert @subject.respond_to?(:articles_path)
        assert_equal @subject.articles_path, '/admin/articles'
      end

      test '#*_path' do
        assert @subject.respond_to?(:article_path)
        assert_equal @subject.article_path(@article), "/admin/articles/#{@article.id}"
      end

      test '#edit_*_path' do
        assert @subject.respond_to?(:edit_article_path)
        assert_equal @subject.edit_article_path(@article), "/admin/articles/#{@article.id}/edit"
      end

      test '#new_*_path' do
        assert @subject.respond_to?(:new_article_path)
        assert_equal @subject.new_article_path, '/admin/articles/new'
      end
    end

    scope "doesn't override methods" do
      setup do
        @subject = Class.new Cuba do
          def articles_path
            '/posts'
          end

          def article_path(article)
            "/posts/#{article.id}"
          end

          def edit_article_path(article)
            "/posts/#{article.id}/edit"
          end

          def new_article_path
            '/posts/new'
          end

          plugin Crest::PathHelper

          define_paths_for 'Article'
        end.new
      end

      test '#*s_path' do
        assert @subject.respond_to?(:articles_path)
        assert_equal @subject.articles_path, '/posts'
      end

      test '#*_path' do
        assert @subject.respond_to?(:article_path)
        assert_equal @subject.article_path(@article), "/posts/#{@article.id}"
      end

      test '#edit_*_path' do
        assert @subject.respond_to?(:edit_article_path)
        assert_equal @subject.edit_article_path(@article), "/posts/#{@article.id}/edit"
      end

      test '#new_*_path' do
        assert @subject.respond_to?(:new_article_path)
        assert_equal @subject.new_article_path, '/posts/new'
      end
    end
  end
end
