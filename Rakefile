require 'rubygems'
require 'hoe'
$:.unshift(File.dirname(__FILE__) + "/lib")
require 'rplatform'

Hoe.new('RPlatform', RPlatform::VERSION) do |p|
  p.name = "rPlatform"
  p.author = "Curtis Edmond"
  p.description = "ruby interface for Facebook's Platform API."
  p.email = 'curtis.edmond@gmail.com'
  p.summary = "ruby interface for Facebook's Platform API.."
  p.url = "http://rplatform.rubyforge.org/"
  p.test_globs = ["test/**/*_test.rb"]
  p.clean_globs = ['test/actual'] # Remove this directory on "rake clean"
  p.remote_rdoc_dir = '' # Release to root
  p.changes = p.paragraphs_of('CHANGELOG', 0..1).join("\n\n")
  # * extra_deps - An array of rubygem dependencies.
end


desc "Release and publish documentation"
task :repubdoc => [:release, :publish_docs]