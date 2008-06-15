require 'test/unit'
require 'rubygems'
require 'mocha'
require 'rfacebook'




module RFacebook
  module Dummy
  
    API_KEY = "dummykey123"
    API_SECRET = "dummysecret456"
    
    AUTH_CREATETOKEN_RESPONSE = <<-EOF
      <?xml version="1.0" encoding="UTF-8"?>
      <auth_createToken_response xmlns="http://api.facebook.com/1.0/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://api.facebook.com/1.0/ http://api.facebook.com/1.0/facebook.xsd">3e4a22bb2f5ed75114b0fc9995ea85f1</auth_createToken_response>
    EOF
  
    ERROR_RESPONSE = <<-EOF
      <?xml version="1.0" encoding="UTF-8"?>
      <error_response xmlns="http://api.facebook.com/1.0/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://api.facebook.com/1.0/ http://api.facebook.com/1.0/facebook.xsd">
        <error_code>5</error_code>
        <error_msg>Unauthorized source IP address (ip was: 10.1.2.3)</error_msg>
        <request_args list="true">
          <arg>
            <key>method</key>
            <value>facebook.friends.get</value>
          </arg>
          <arg>
            <key>session_key</key>
            <value>373443c857fcda2e410e349c-i7nF4PqX4IW4.</value>
          </arg>
          <arg>
            <key>api_key</key>
            <value>0289b21f46b2ee642d5c42145df5489f</value>
          </arg>
          <arg>
            <key>call_id</key>
            <value>1170813376.3544</value>
          </arg>
          <arg>
            <key>v</key>
            <value>1.0</value>
          </arg>
          <arg>
            <key>sig</key>
            <value>570dcc2b764578af350ea1e1622349a0</value>
          </arg>
        </request_args>
      </error_response>
    EOF
  
    ERROR_RESPONSE_3 = <<-EOF
      <?xml version="1.0" encoding="UTF-8"?>
      <error_response xmlns="http://api.facebook.com/1.0/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://api.facebook.com/1.0/ http://api.facebook.com/1.0/facebook.xsd">
        <error_code>3</error_code>
        <error_msg>method does not exist</error_msg>
      </error_response>
    EOF
  
    ERROR_RESPONSE_100 = <<-EOF
      <?xml version="1.0" encoding="UTF-8"?>
      <error_response xmlns="http://api.facebook.com/1.0/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://api.facebook.com/1.0/ http://api.facebook.com/1.0/facebook.xsd">
        <error_code>100</error_code>
        <error_msg>bad arguments</error_msg>
      </error_response>
    EOF
  
    ERROR_RESPONSE_102 = <<-EOF
      <?xml version="1.0" encoding="UTF-8"?>
      <error_response xmlns="http://api.facebook.com/1.0/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://api.facebook.com/1.0/ http://api.facebook.com/1.0/facebook.xsd">
        <error_code>102</error_code>
        <error_msg>expired session</error_msg>
      </error_response>
    EOF
  
    ERROR_RESPONSE_606 = <<-EOF
      <?xml version="1.0" encoding="UTF-8"?>
      <error_response xmlns="http://api.facebook.com/1.0/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://api.facebook.com/1.0/ http://api.facebook.com/1.0/facebook.xsd">
        <error_code>606</error_code>
        <error_msg>wrong number of arguments</error_msg>
      </error_response>
    EOF
  
    AUTH_GETSESSION_RESPONSE = <<-EOF
      <?xml version="1.0" encoding="UTF-8"?>
      <auth_getSession_response
        xmlns="http://api.facebook.com/1.0/"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="http://api.facebook.com/1.0/ http://api.facebook.com/1.0/facebook.xsd">
          <session_key>5f34e11bfb97c762e439e6a5-8055</session_key>
          <uid>8055</uid>
          <expires>1173309298</expires>
      </auth_getSession_response>
    EOF
  
    GROUP_GETMEMBERS_RESPONSE = <<-EOF
      <?xml version="1.0" encoding="UTF-8"?>
      <groups_getMembers_response xmlns="http://api.facebook.com/1.0/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://api.facebook.com/1.0/ http://api.facebook.com/1.0/facebook.xsd">
        <members list="true">
          <uid>4567</uid>
          <uid>5678</uid>
          <uid>6789</uid>
          <uid>7890</uid>
        </members>
        <admins list="true">
          <uid>1234567</uid>
        </admins>
        <officers list="true"/>
        <not_replied list="true"/>
      </groups_getMembers_response>
    EOF
  
    USERS_GETLOGGEDINUSER_RESPONSE = <<-EOF
      <?xml version="1.0" encoding="UTF-8"?>
      <users_getLoggedInUser_response xmlns="http://api.facebook.com/1.0/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://api.facebook.com/1.0/ http://api.facebook.com/1.0/facebook.xsd">1234567</users_getLoggedInUser_response>
    EOF
  
    USERS_GETINFO_RESPONSE = <<-EOF
      <?xml version="1.0" encoding="UTF-8"?>
      <users_getInfo_response xmlns="http://api.facebook.com/1.0/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://api.facebook.com/1.0/ http://api.facebook.com/1.0/facebook.xsd" list="true">
        <user>
          <uid>8055</uid>
          <about_me>This field perpetuates the glorification of the ego.  Also, it has a character limit.</about_me>
          <activities>Here: facebook, etc. There: Glee Club, a capella, teaching.</activities>
          <affiliations list="true">
            <affiliation>
              <nid>50453093</nid>
              <name>Facebook Developers</name>
              <type>work</type>
              <status/>
              <year/>
            </affiliation>
          </affiliations> 
          <birthday>November 3</birthday>
          <books>The Brothers K, GEB, Ken Wilber, Zen and the Art, Fitzgerald, The Emporer's New Mind, The Wonderful Story of Henry Sugar</books>
          <current_location>
            <city>Palo Alto</city>
            <state>CA</state>
            <country>United States</country>
            <zip>94303</zip>
          </current_location>
          <education_history list="true">
            <education_info>
              <name>Harvard</name>
              <year>2003</year>
              <concentrations list="true">
                <concentration>Applied Mathematics</concentration>
                <concentration>Computer Science</concentration>
              </concentrations>
            </education_info>
          </education_history>
          <first_name>Dave</first_name>
           <hometown_location>
             <city>York</city>
             <state>PA</state>
             <country>United States</country>
             <zip>0</zip>
           </hometown_location>
           <hs_info>
             <hs1_name>Central York High School</hs1_name>
             <hs2_name/>
             <grad_year>1999</grad_year>
             <hs1_id>21846</hs1_id>
             <hs2_id>0</hs2_id>
           </hs_info>
           <is_app_user>1</is_app_user>
           <has_added_app>1</has_added_app>
           <interests>coffee, computers, the funny, architecture, code breaking,snowboarding, philosophy, soccer, talking to strangers</interests>
           <last_name>Fetterman</last_name>
           <meeting_for list="true">
             <seeking>Friendship</seeking>
           </meeting_for>
           <meeting_sex list="true">
             <sex>female</sex>
           </meeting_sex>
           <movies>Tommy Boy, Billy Madison, Fight Club, Dirty Work, Meet the Parents, My Blue Heaven, Office Space </movies>
           <music>New Found Glory, Daft Punk, Weezer, The Crystal Method, Rage, the KLF, Green Day, Live, Coldplay, Panic at the Disco, Family Force 5</music>
           <name>Dave Fetterman</name>
           <notes_count>0</notes_count>
           <pic>http://photos-055.facebook.com/ip007/profile3/1271/65/s8055_39735.jpg</pic>
           <pic_big>http://photos-055.facebook.com/ip007/profile3/1271/65/n8055_39735.jpg</pic>
           <pic_small>http://photos-055.facebook.com/ip007/profile3/1271/65/t8055_39735.jpg</pic>
           <pic_square>http://photos-055.facebook.com/ip007/profile3/1271/65/q8055_39735.jpg</pic>
           <political>Moderate</political>
           <profile_update_time>1170414620</profile_update_time>
           <quotes/>
           <relationship_status>In a Relationship</relationship_status>
           <religion/>
           <sex>male</sex>
           <significant_other_id xsi:nil="true"/>
           <status>
             <message/>
             <time>0</time>
           </status>
           <timezone>-8</timezone>
           <tv>cf. Bob Trahan</tv>
           <wall_count>121</wall_count>
           <work_history list="true">
             <work_info>
               <location>
                 <city>Palo Alto</city>
                 <state>CA</state>
                 <country>United States</country>
               </location>
               <company_name>Facebook</company_name>
               <position>Software Engineer</position>
               <description>Tech Lead, Facebook Platform</description>
               <start_date>2006-01</start_date>
               <end_date/>
              </work_info>
           </work_history>
         </user>
      </users_getInfo_response>
    EOF
  end
end