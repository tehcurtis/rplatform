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

require "facebook_session"

module RFacebook

  class FacebookDesktopSession < FacebookSession

    # you should need this for infinite desktop sessions
    attr_reader :session_secret 
    
    # Constructs a FacebookDesktopSession, calling the API to grab an auth_token.
    #
    # api_key::         your API key
    # api_secret::      your API secret
    # quiet::           boolean, set to true if you don't want errors to be thrown (defaults to false)
    def initialize(api_key, api_secret, quiet = false)
      super(api_key, api_secret, quiet)
      result = remote_call("auth.createToken", {})
      @desktop_auth_token = result.at("auth_createToken_response")
      @desktop_auth_token = @desktop_auth_token.nil? ? nil : @desktop_auth_token.inner_html.to_s
    end
    
    # Gets the authentication URL
    #
    # options.next::          the page to redirect to after login
    # options.popup::         boolean, whether or not to use the popup style (defaults to true)
    # options.skipcookie::    boolean, whether to force new Facebook login (defaults to false)
    # options.hidecheckbox::  boolean, whether to show the "infinite session" option checkbox (defaults to false)
    def get_login_url(options={})
      # options
      path_next = options[:next] ||= nil
      popup = (options[:popup] == nil) ? true : false
      skipcookie = (options[:skipcookie] == nil) ? false : true
      hidecheckbox = (options[:hidecheckbox] == nil) ? false : true
    
      # get some extra portions of the URL
      optionalNext = (path_next == nil) ? "" : "&next=#{CGI.escape(path_next.to_s)}"
      optionalPopup = (popup == true) ? "&popup=true" : ""
      optionalSkipCookie = (skipcookie == true) ? "&skipcookie=true" : ""
      optionalHideCheckbox = (hidecheckbox == true) ? "&hide_checkbox=true" : ""
    
      # build and return URL
      return "http://#{get_network_param(:www_host)}#{get_network_param(:www_path_login)}?v=1.0&api_key=#{@api_key}&auth_token=#{@desktop_auth_token}#{optionalPopup}#{optionalNext}#{optionalSkipCookie}#{optionalHideCheckbox}"
    end
    
    # Activates the session and makes it ready for usage. Call this method only after
    # the user has logged in via the login URL.
    def activate
      result = remote_call("auth.getSession", {:auth_token => @desktop_auth_token}, true)
      if result != nil
        @session_user_id = result.at("uid").inner_html
        @session_key = result.at("session_key").inner_html
        @session_secret = result.at("secret").inner_html
      end
    end
  
    # Activate using the session key and secret directly (for example, if you have an infinite session)
    # 
    # key::    the session key to use
    # secret:: the session secret to use
    def activate_with_previous_session(key, secret)
      # set the session key and secret
      @session_key = key
      @session_secret = secret
    
      # determine the current user's id
      result = remote_call("users.getLoggedInUser")
      @session_user_id = result.at("users_getLoggedInUser_response").inner_html
    end
  
    # returns true if this session is completely ready to be used and make API calls
    def ready?
      return (@session_key != nil and @session_secret != nil and !expired?)
    end
  
    # Used for signing a set of parameters in the way that Facebook
    # specifies: <http://developers.facebook.com/documentation.php?v=1.0&doc=auth>
    #
    # params:: a Hash containing the parameters to sign
    def signature(params)
      # choose the proper secret
      signatureSecret = nil
      unless (params[:method] == "facebook.auth.getSession" or params[:method] == "facebook.auth.createToken")
        signatureSecret = @session_secret
      else
        signatureSecret = @api_secret
      end
    
      # sign the parameters with that secret
      return signature_helper(params, signatureSecret)
    end
  
  end

end
    
