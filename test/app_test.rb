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
    assert_equal "text/html;charset=utf-8", last_response["Content-Type"]
    assert_includes last_response.body, "Changes"
  end

  def test_document_not_found
    get "nonsensical.tuxt"
    assert_equal 302, last_response.status
    get last_response['Location']
    assert_equal 200, last_response.status
    assert_includes last_response.body, 'requested file does not exist.'
  end

  def test_show_rendered_md_document
    create_document('history.md', '# History')

    get '/history.md'
    assert_equal "text/html;charset=utf-8", last_response["Content-Type"]
    assert_includes last_response.body, '<h1>'
    refute_includes last_response.body, '#'
  end

  def test_show_edit_template
    create_document('history.md', 'History')

    get '/history.md/edit'
    assert_equal 200, last_response.status
    assert_equal "text/html;charset=utf-8", last_response["Content-Type"]
    assert_includes last_response.body, '<form'
    assert_includes last_response.body, '<textarea'
  end

  def test_submit_changed_document
    create_document('about.txt')

    post "/about.txt", :content => 'modified'
    assert_equal 302, last_response.status
    get last_response.headers['Location']
    assert_includes last_response.body, 'modified'
  end
end
