ENV["RACK_ENV"] = "test"

require "minitest/autorun"
require "rack/test"
require 'fileutils'

require_relative "../app"

class AppTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def setup
    FileUtils.mkdir_p(data_path)
  end

  def teardown
    FileUtils.rm_rf(data_path)
  end

  def create_document(name, content = "")
    File.open(File.join(data_path, name), "w") do |file|
      file.write(content)
    end
  end

  def session
    last_request.env["rack.session"]
  end

  def admin_session
    { "rack.session" => { user: 'admin' } }
  end

  def test_accessing_session_hash
    post(
      "/document/new",
      { :filename => 'filename' },
      admin_session
    )
    assert_equal 302, last_response.status
    assert_includes session[:message], 'has been created'
  end

  def test_index
    create_document('about.txt')

    get "/"
    assert_equal 200, last_response.status
    assert_equal "text/html;charset=utf-8", last_response["Content-Type"]
    assert_includes last_response.body, 'about.txt'
  end

  def test_show_txt_document
    create_document('changes.txt', 'Changes')
    get "/changes.txt"
    assert_equal 200, last_response.status
    assert_equal "text/plain", last_response["Content-Type"]
    assert_includes last_response.body, "Changes"
  end

  def test_document_not_found
    get "nonsensical.tuxt"
    assert_equal 302, last_response.status
    assert_includes session[:message], 'requested file does not exist.'
  end

  def test_show_rendered_md_document
    create_document('history.md', '# History')

    get '/history.md'
    assert_equal "text/html", last_response["Content-Type"]
    assert_includes last_response.body, '<h1>'
    refute_includes last_response.body, '#'
  end

  def test_show_edit_template
    create_document('history.md', 'History')

    get(
      '/history.md/edit',
      {},
      admin_session
    )
    assert_equal 200, last_response.status
    assert_equal "text/html;charset=utf-8", last_response["Content-Type"]
    assert_includes last_response.body, '<form'
    assert_includes last_response.body, '<textarea'
  end

  def test_submit_changed_document
    create_document('about.txt')

    post(
      "/about.txt",
      { :content => 'modified'},
      admin_session
    )
    assert_equal 302, last_response.status
    assert_includes session[:message], 'modified'
  end

  def test_new_document_view
    get "/document/new", {}, admin_session
    assert_equal 200, last_response.status
    assert_includes last_response.body, '<form'
  end

  def test_submit_new_document
    post(
      "/document/new",
      { :filename => 'filename' },
      admin_session
    )
    assert_equal 302, last_response.status
    assert_includes session[:message], 'has been created'
  end

  def test_with_empty_filename
    post(
      "/document/new",
      { :filename => '' },
      admin_session
    )
    assert_equal 422, last_response.status
  end

  def test_delete_document
    create_document('about.txt')

    post('/about.txt/delete', { :filename => 'about.txt' }, admin_session)
    assert_equal 302, last_response.status

    get last_response.headers['Location']
    assert_equal 200, last_response.status
    assert_includes last_response.body, "'about.txt' has been deleted"

    get '/'
    refute_includes last_response.body, 'about.txt'
  end

  def test_signin
    post "/users/sign_in", :user => "ben", :password => "password"
    assert_equal 302, last_response.status

    get last_response["Location"]
    assert_includes last_response.body, "Welcome"
    assert_includes last_response.body, "Logged in as ben"
  end

  def test_signin_with_bad_credentials
    post "/users/sign_in", user: "guest", password: "shhhh"
    assert_equal 422, last_response.status
    assert_includes last_response.body, "Invalid credentials"
  end

  def test_signout
    post "/users/sign_in", user: "admin", password: "secret"
    assert_equal 302, last_response.status
    get last_response["Location"]
    assert_includes last_response.body, "Welcome"

    post "/users/sign_out"
    get last_response["Location"]

    assert_includes last_response.body, "You have been logged out"
    assert_includes last_response.body, "Sign In"
  end
end
