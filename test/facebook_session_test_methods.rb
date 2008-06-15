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

module FacebookSessionTestMethods
  
  def force_to_be_activated(fbsession)
    fbsession.stubs(:ready?).returns(true)
  end
  
  def test_method_missing_dispatches_to_facebook_api
    fbsession = @fbsession.dup
    force_to_be_activated(fbsession)
    fbsession.expects(:remote_call).returns("mocked")
    assert_equal "mocked", fbsession.friends_get
  end
    
  def test_remote_error_causes_fbsession_to_raise_errors
    fbsession = @fbsession.dup
    force_to_be_activated(fbsession)
    fbsession.expects(:post_request).returns(RFacebook::Dummy::ERROR_RESPONSE)
    assert_raise(RFacebook::FacebookSession::RemoteStandardError){fbsession.friends_get}
  end
    
  def test_nomethod_error_raises_ruby_equivalent
    fbsession = @fbsession.dup
    force_to_be_activated(fbsession)
    fbsession.expects(:post_request).returns(RFacebook::Dummy::ERROR_RESPONSE_3)
    assert_raise(NoMethodError){fbsession.friends_get}
  end
    
  def test_badargument_error_raises_ruby_equivalent
    fbsession = @fbsession.dup
    force_to_be_activated(fbsession)
    fbsession.expects(:post_request).returns(RFacebook::Dummy::ERROR_RESPONSE_100)
    assert_raise(ArgumentError){fbsession.friends_get}
    fbsession.expects(:post_request).returns(RFacebook::Dummy::ERROR_RESPONSE_606)
    assert_raise(ArgumentError){fbsession.friends_get}
  end
    
  def test_expiration_error_raises_error_and_sets_expired_flag
    fbsession = @fbsession.dup
    force_to_be_activated(fbsession)
    fbsession.expects(:post_request).returns(RFacebook::Dummy::ERROR_RESPONSE_102)
    assert_raise(RFacebook::FacebookSession::ExpiredSessionStandardError){fbsession.friends_get}
    assert fbsession.expired?
  end
  
  def test_facepricot_response_to_group_getMembers
    fbsession = @fbsession.dup
    force_to_be_activated(fbsession)
    fbsession.expects(:post_request).returns(RFacebook::Dummy::GROUP_GETMEMBERS_RESPONSE)
    memberInfo = fbsession.group_getMembers
    assert memberInfo
    assert_equal 4, memberInfo.members.uid_list.size
    assert_equal 1, memberInfo.admins.uid_list.size
    assert memberInfo.officers
    assert memberInfo.not_replied
  end
  
  def test_api_call_to_users_getLoggedInUser
    fbsession = @fbsession.dup
    force_to_be_activated(fbsession)
    fbsession.expects(:post_request).returns(RFacebook::Dummy::USERS_GETLOGGEDINUSER_RESPONSE)
    assert_equal "1234567", fbsession.users_getLoggedInUser
  end

  def test_api_call_to_users_getInfo
    fbsession = @fbsession.dup
    force_to_be_activated(fbsession)
    fbsession.expects(:post_request).returns(RFacebook::Dummy::USERS_GETINFO_RESPONSE)
    userInfo = fbsession.users_getInfo    
    assert userInfo
    assert_equal "94303", userInfo.current_location.get(:zip)
  end
  
  def test_should_raise_not_activated
    assert_raise(RFacebook::FacebookSession::NotActivatedStandardError){@fbsession.friends_get}
  end

end
