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

require "digest/md5"
require "net/https"
require "cgi"
require "facepricot"

module RFacebook

  # TODO: better handling of session expiration
  

  # API_VERSION               = "1.0"
  # 
  # API_HOST                  = "api.facebook.com"
  # API_PATH_REST             = "/restserver.php"
  # 
  # WWW_HOST                  = "www.facebook.com"
  # WWW_PATH_LOGIN            = "/login.php"
  # WWW_PATH_ADD              = "/add.php"
  # WWW_PATH_INSTALL          = "/install.php"
  
  HOST_CONSTANTS = { 'facebook' => { :api_version               => "1.0",
                                     :api_host                  => "api.facebook.com",
                                     :api_path_rest             => "/restserver.php",
                                     :www_host                  => "www.facebook.com",
                                     :www_path_login            => "/login.php",
                                     :www_path_add              => "/add.php",
                                     :www_path_install          => "/install.php"},                                     
                     'bebo'     => { :api_version               => "1.0",
                                     :api_host                  => "apps.bebo.com",
                                     :api_path_rest             => "/restserver.php",
                                     :www_host                  => "bebo.com",
                                     :www_path_login            => "/SignIn.jsp",
                                     :www_path_add              => "/add.php",
                                     :www_path_install          => "/c/apps/add"}}
  
  
  class FacebookSession
  
    ################################################################################################
    ################################################################################################
    # :section: Error classes
    ################################################################################################
  
    # TODO: better exception classes in v1.0?
    class RemoteStandardError < StandardError
      attr_reader :code
      def initialize(message, code)
        @code = code
      end
    end
    class ExpiredSessionStandardError < RemoteStandardError; end
    class NotActivatedStandardError < StandardError; end
    
    ################################################################################################
    ################################################################################################
    # :section: Properties
    ################################################################################################
    
    # The network this session is being used on (Bebo, Facebook, etc)
    attr_accessor :network 
  
    # The user id of the user associated with this sesssion.
    attr_reader :session_user_id
  
    # The key for this session. You will need to save this for infinite sessions.
    attr_reader :session_key
  
    # The expiration time of this session, as given from Facebook API login.
    attr_reader :session_expires
  
    # Can be set to any valid logger (for example, RAIL_DEFAULT_LOGGER)
    attr_accessor :logger
  
    ################################################################################################
    ################################################################################################
    # :section: Public Interface
    ################################################################################################

    # Constructs a FacebookSession.
    #
    # api_key::     your API key
    # api_secret::  your API secret
    # quiet::       boolean, set to true if you don't want exceptions to be thrown (defaults to false)
    def initialize(api_key, api_secret, quiet = false)
      # required parameters
      @api_key = api_key
      @api_secret = api_secret
        
      # optional parameters
      @quiet = quiet
    
      # initialize internal state
      @last_error_message = nil # DEPRECATED
      @last_error_code = nil # DEPRECATED
      @expired = false
    end
  
    # Template method. Returns true when the session is definitely prepared to make API calls.
    def ready?
      raise NotImplementedError
    end
  
    # Returns true if the session is expired (will often mean that the session is not ready as well)
    def expired?
      return @expired
    end
  
    # Returns true if exceptions are being suppressed in favor of log messages
    def quiet?
      return @quiet
    end
  
    # Sets whether or not we suppress exceptions from being thrown
    def quiet=(val)
      @quiet = val
    end

    # Template method. Used for signing a set of parameters in the way that Facebook
    # specifies: <http://developers.facebook.com/documentation.php?v=1.0&doc=auth>
    #
    # params:: a Hash containing the parameters to sign
    def signature(params)
      raise NotImplementedError
    end
      
    protected
    def get_network_param(name)
      HOST_CONSTANTS[network][name]
    end
    
    ################################################################################################
    ################################################################################################
    # :section: Utility methods
    ################################################################################################
    private
  
    # This allows *any* Facebook method to be called, using the Ruby
    # mechanism for responding to unimplemented methods.  Basically,
    # this converts a call to "auth_getSession" to "auth.getSession"
    # and does the proper API call using the parameter hash given.
    # 
    # This allows you to call an API method such as facebook.users.getInfo
    # by calling "fbsession.users_getInfo"
    def method_missing(methodSymbol, *params)
      # get the remote method name
      remoteMethod = methodSymbol.to_s.gsub("_", ".")
      if methodSymbol.to_s.match(/cached_(.*)/)
        log_debug "** RFACEBOOK(GEM) - DEPRECATION NOTICE - cached methods are deprecated, making a raw call without caching."
        tokens.shift
      end
    
      # there can only be one parameter, a Hash, for remote methods
      unless (params.size == 1 and params.first.is_a?(Hash))
        log_debug "** RFACEBOOK(GEM) - when you call a remote Facebook method"
      end
    
      # make the remote method call
      return remote_call(remoteMethod, params.first)  
    end
  
    # Sets everything up to make a POST request to Facebook's API servers.
    #
    # method::  i.e. "users.getInfo"
    # params::  hash of key,value pairs for the parameters to this method
    # useSSL::  set to true if the call will be made over SSL
    def remote_call(method, params={}, useSSL=false) # :nodoc:

      log_debug "** RFACEBOOK(GEM) - RFacebook::FacebookSession\#remote_call - #{method}(#{params.inspect}) - making remote call"
    
      # set up the parameters
      params = (params || {}).dup
      params[:method] = "facebook.#{method}"
      params[:api_key] = @api_key
      params[:v] = API_VERSION
      # params[:format] ||= @response_format # TODO: consider JSON capability
    
      # non-auth methods get special consideration
      unless(method == "auth.getSession" or method == "auth.createToken")
        # session must be activated for non-auth methods
        raise NotActivatedStandardError, "You must activate the session before using it." unless ready?
      
        # secret and call ID must be set for non-auth methods
        params[:session_key] = session_key
        params[:call_id] = Time.now.to_f.to_s
      end
    
      # in the parameters, all arrays must be converted to comma-separated lists
      params.each{|k,v| params[k] = v.join(",") if v.is_a?(Array)}
    
      # sign the parameter list by adding a proper sig
      params[:sig] = signature(params)
    
      # make the remote call and contain the results in a Facepricot XML object
      xml = post_request(params, useSSL)
      return handle_xml_response(xml)
    end
  
    # Wraps an XML response in a Facepricot XML document, and checks for
    # an error response (raising or logging errors as needed)
    #
    # NOTE: Facepricot chaining may be deprecated in the 1.0 release
    def handle_xml_response(rawXML)
      facepricotXML = Facepricot.new(rawXML)

      # error checking    
      if facepricotXML.at("error_response")
      
        # get the error code
        errorCode = facepricotXML.at("error_code").inner_html.to_i
        errorMessage = facepricotXML.at("error_msg").inner_html
        log_debug "** RFACEBOOK(GEM) - RFacebook::FacebookSession\#remote_call - remote call failed (#{errorCode}: #{errorMessage})"
      
        # TODO: remove these 2 lines
        @last_error_message = "ERROR #{errorCode}: #{errorMessage}" # DEPRECATED
        @last_error_code = errorCode # DEPRECATED
      
        # check to see if this error was an expired session error
        case errorCode

        # the remote method did not exist, convert that to a standard Ruby no-method error
        when 3
          raise NoMethodError, errorMessage unless quiet? == true
        
        # the parameters were wrong, or not enough parameters...convert that to a standard Ruby argument error
        when 100,606
          raise ArgumentError, errorMessage unless quiet? == true
        
        # when the session expires, we need to record that internally
        when 102
          @expired = true
          raise ExpiredSessionStandardError.new(errorMessage, errorCode) unless quiet? == true
      
        # otherwise, just raise a regular remote error with the error code
        else
          raise RemoteStandardError.new(errorMessage, errorCode) unless quiet? == true
        end
      
        # since the quiet flag may have been activated, we may not have thrown
        # an actual exception, so we still need to return nil here
        return nil
      end
    
      # everything was just fine, return the Facepricot XML response
      return facepricotXML
    end
  
    # Posts a request to the remote Facebook API servers, and returns the
    # raw text body of the result
    #
    # params:: a Hash of the post parameters to send to the REST API
    # useSSL:: defaults to false, set to true if you want to use SSL for the POST
    def post_request(params, useSSL=false)
      # get a server handle
      port = (useSSL == true) ? 443 : 80
      http_server = Net::HTTP.new(API_HOST, port)
      http_server.use_ssl = useSSL
    
      # build a request
      http_request = Net::HTTP::Post.new(API_PATH_REST)
      http_request.form_data = params
    
      # get the response XML
      return http_server.start{|http| http.request(http_request)}.body
    end
  
    # Generates a proper Facebook signature.
    #
    # params::  a Hash containing the parameters to sign
    # secret::  the secret to use to sign the parameters
    def signature_helper(params, secret) # :nodoc:
      args = []
      params.each{|k,v| args << "#{k}=#{v}"}
      sortedArray = args.sort
      requestStr = sortedArray.join("")
      return Digest::MD5.hexdigest("#{requestStr}#{secret}")
    end
  
    # log a debug message
    def log_debug(message) # :nodoc:
      @logger.debug(message) if @logger
    end
  
    # log an informational message
    def log_info(message) # :nodoc:
      @logger.info(message) if @logger
    end
  
    ################################################################################################
    ################################################################################################
    # :section: Serialization
    ################################################################################################
    public
  
    # dump to a serialized string, removing the logger object (which cannot be serialized)
    def _dump(depth) # :nodoc:
      instanceVarHash = {}
      self.instance_variables.each { |k| instanceVarHash[k] = self.instance_variable_get(k) }
      return Marshal.dump(instanceVarHash.delete_if{|k,v| k == "@logger"})
    end
  
    # load from a serialized string
    def self._load(dumpedStr) # :nodoc:
      instance = self.new(nil,nil)
      dumped = Marshal.load(dumpedStr)
      dumped.each do |k,v|
        instance.instance_variable_set(k,v)
      end
      return instance
    end  
  
  
    ################################################################################################
    ################################################################################################
    # :section: Deprecated Methods
    ################################################################################################
    public

    # DEPRECATED
    def is_expired? # :nodoc:
      RAILS_DEFAULT_LOGGER.info "** RFACEBOOK(GEM) DEPRECATION WARNING: is_expired? is deprecated, use expired? instead"
      return expired?
    end

    # DEPRECATED
    def is_activated? # :nodoc:
      RAILS_DEFAULT_LOGGER.info "** RFACEBOOK(GEM) DEPRECATION WARNING: is_activated? is deprecated, use ready? instead"
      return ready?
    end
  
    # DEPRECATED
    def is_valid? # :nodoc:
      RAILS_DEFAULT_LOGGER.info "** RFACEBOOK(GEM) DEPRECATION WARNING: is_valid? is deprecated, use ready? instead"
      return ready?
    end
  
    # DEPRECATED
    def is_ready? # :nodoc:
      RAILS_DEFAULT_LOGGER.info "** RFACEBOOK(GEM) DEPRECATION WARNING: is_valid? is deprecated, use ready? instead"
      return ready?
    end
  
    # DEPRECATED
    def last_error_message # :nodoc:
      RAILS_DEFAULT_LOGGER.info "** RFACEBOOK(GEM) DEPRECATION WARNING: last_error_message is deprecated"
      return @last_error_message
    end
  
    # DEPRECATED
    def last_error_code # :nodoc:
      RAILS_DEFAULT_LOGGER.info "** RFACEBOOK(GEM) DEPRECATION WARNING: last_error_code is deprecated"
      return @last_error_code
    end
  
    # DEPRECATED
    def suppress_errors # :nodoc:
      RAILS_DEFAULT_LOGGER.info "** RFACEBOOK(GEM) DEPRECATION WARNING: suppress_errors is deprecated, use quiet? instead"
      return quiet?
    end
  
    # DEPRECATED
    def suppress_errors=(val) # :nodoc:
      RAILS_DEFAULT_LOGGER.info "** RFACEBOOK(GEM) DEPRECATION WARNING: suppress_errors= is deprecated, use quiet= instead"
      @quiet=val
    end

  end

end
