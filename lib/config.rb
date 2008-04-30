require 'yaml'

class Settings
  
  attr_reader :rss_url, :twitter_email, :twitter_password
  
  def initialize
    begin
      prefs = YAML::load_file("#{@@yaml_file_name}")
    rescue
      missing_or_empty_yaml 
    end

    missing_or_empty_yaml unless prefs

    @twitter_email = yamlized(prefs,'twitter_email')
    @twitter_password = yamlized(prefs,'twitter_password')
    @rss_url = yamlized(prefs,'rss_url')
  end

  private
  
  @@yaml_file_name = 'rss2twitter.yml'

  def missing_or_empty_yaml
    print <<"EOF"

    Please define a YAML file named #{@@yaml_file_name}
    containing the following values:

      twitter_email: 'yourtwitteremail@bla.com'
      twitter_password: 'secret'
      rss_url: 'https://username:password@yoursite.com/index.xml'

EOF
    exit
  end

  def yamlized(prefs,token)
    if prefs["#{token}"]
      return prefs["#{token}"]
    else
      raise "Please define \"#{token}\" in your YAML file."    
    end
  end
end
