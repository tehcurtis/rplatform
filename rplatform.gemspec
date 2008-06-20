Gem::Specification.new do |s|
  s.name = "rplatform"
  s.version = "0.0.1"
  s.date = "2008-06-19"
  s.summary = "ruby iterface to Facebook's Platform API"
  s.email = "curtis.edmond@gmail.com"
  s.homepage = "http://github.com/tehcurtis/rplatform/"
  s.description = "rPlatform is a ruby interface for Facebook's Platform API. Compatible with any site that implements Facebook's Platform."
  s.has_rdoc = true
  s.authors = ["Curtis Edmond"]
  s.files = [
    "README",
    "rplatform.gemspec", 
    "lib/facebook_desktop_session.rb", 
    "lib/facebook_session.rb", 
    "lib/facebook_web_session.rb", 
    "lib/facepricot.rb", 
    "lib/rfacebook.rb", 
    "test/facebook_desktop_session_test.rb",
    "test/facebook_session_test_methods.rb",
    "test/facebook_web_session_test.rb",
    "test/test_helper.rb"
    ]
  s.test_files = [
    "test/facebook_desktop_session_test.rb",
    "test/facebook_session_test_methods.rb",
    "test/facebook_web_session_test.rb",
    "test/test_helper.rb"
    ]
  s.rdoc_options = ["--main", "README.txt"]
  s.extra_rdoc_files = ["README.txt"]
  s.add_dependency("hpricot", ["> 0.4.0"])
end