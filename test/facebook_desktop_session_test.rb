# Copyright (c) 2007, Matt Pizzimenti (www.livelearncode.com)
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that the following conditions are met:
# 
# Redistributions of source code must retain the above copyright notice,
# this list of conditions and the following disclaimer.
# 
# Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation
# and/or other materials provided with the distribution.
# 
# Neither the name of the original author nor the names of contributors
# may be used to endorse or promote products derived from this software
# without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#

require File.dirname(__FILE__) + '/test_helper'
require File.dirname(__FILE__) + '/facebook_session_test_methods'

class RFacebook::FacebookDesktopSession
  def test_initialize(*params)
    initialize(*params)
  end
end

class FacebookDesktopSessionTest < Test::Unit::TestCase
  
  include FacebookSessionTestMethods
  
  def setup
    # setting up a desktop session means that we need to allow the initialize method to 'access' the API for a createToken request
    @fbsession = RFacebook::FacebookDesktopSession.allocate
    @fbsession.expects(:post_request).returns(RFacebook::Dummy::AUTH_CREATETOKEN_RESPONSE)
    @fbsession.test_initialize(RFacebook::Dummy::API_KEY, RFacebook::Dummy::API_SECRET)
  end
  
  def test_should_return_login_url
    assert_equal "http://www.facebook.com/login.php?v=1.0&api_key=#{RFacebook::Dummy::API_KEY}&auth_token=3e4a22bb2f5ed75114b0fc9995ea85f1&popup=true", @fbsession.get_login_url
  end
  
end
