class Search < ActiveRecord::Base


  def self.load_search_parameters()
    search_parameter = {}
    parameters = ["diet","allergy","cuisine","course","holiday"]
    parameters.each do |parameter|
      search = self.find_by_name(parameter)
      if search == nil
        search = get_from_API(parameter);
      end
      search_parameter["#{parameter}"] = search
    end
    return search_parameter
  end



  def self.get_from_API(parameter)
    url = "http://api.yummly.com/v1/api/metadata/#{parameter}?_app_id=#{ENV['YUMMLY_APP_ID']}&_app_key=#{ENV['YUMMLY_APP_KEY']}"
    first = /set_metadata\('[^']*', /
    last = /\);\Z/
    answer = HTTParty.get(URI.escape(url))
    answer.gsub!(last, "").gsub!(first,"")
    search = self.create(name:parameter, value: JSON.generate(answer))
    return search
  end


end
