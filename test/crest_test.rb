require 'helper'

scope Crest do
  setup do
    @app = Cuba
  end

  scope 'passing a block' do
    test 'new routes can be defined' do
      get '/articles/hello'
      assert_status 200
      assert_matches /hello/, last_response.body
    end

    test 'new object routes can be defined' do
      get '/articles/1/hello'
      assert_status 200
      assert_matches /hello 1/, last_response.body
    end
  end

  scope 'list' do
    test 'renders the list template' do
      get '/articles'
      assert_status 200
      assert_matches /listing articles/, last_response.body
      assert_matches /Article 1/, last_response.body
      assert_matches /Article 2/, last_response.body
    end
  end

  scope 'create' do
    test 'displays the new page if the object is not valid' do
      post '/articles', article: { title: 'Article 1' }
      assert_status 200
      assert_matches /new article/, last_response.body
    end

    test 'creates an object and redirects to its show page' do
      post '/articles', article: { title: 'Article 1', body: 'Body' }
      assert_status 302
      assert_header 'Location', '/articles/1'
    end
  end

  scope 'new' do
    test 'renders the new template' do
      get '/articles/new'
      assert_status 200
      assert_matches /new article/, last_response.body
    end
  end

  scope 'show' do
    test 'renders the show template' do
      get '/articles/1'
      assert_status 200
      assert_matches /showing Article 1/, last_response.body
    end
  end

  scope 'update' do
    test 'displays the edit page if the object is not valid' do
      put '/articles/1', article: { title: 'Article 1' }
      assert_status 200
      assert_matches /editing Article 1/, last_response.body
    end

    test 'updates the object and redirects to its show page' do
      put '/articles/1', article: { title: 'Article 1', body: 'Body' }
      assert_status 302
      assert_header 'Location', '/articles/1'
    end
  end

  scope 'delete' do
    test 'deletes the object' do
      delete '/articles/1'
      assert_status 302
      assert_header 'Location', '/articles'
    end
  end

  scope 'edit' do
    test 'renders the show template' do
      get '/articles/1/edit'
      assert_status 200
      assert_matches /editing Article 1/, last_response.body
    end
  end

  scope 'overwrite actions' do
    setup do
      @app = Class.new Cuba do
        def list_articles
          res.write 'overwritten'
        end

        define do
          on 'articles' do
            rest Article
          end
        end
      end
    end

    test 'actions can be overwritten' do
      get '/articles'
      assert_status 200
      assert_matches /overwritten/, last_response.body
    end
  end

  scope 'nested routes' do
    setup do
      @app = Class.new Cuba do
        define do
          on 'articles' do
            rest Article do
              on ':id/comments' do |id|
                # normally you would like to find the Article and overwrite
                # #list_comments in order to get its related comments
                rest Comment
              end
            end
          end
        end
      end
    end

    test 'works' do
      get '/articles/1/comments'
      assert_status 200
      assert_matches /listing comments/, last_response.body
      assert_matches /Patricio/, last_response.body
      assert_matches /Matz/, last_response.body
    end

    # it doesn't make sense to test the other methods since they're already
    # tested
  end
end
