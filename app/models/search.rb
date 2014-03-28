class Search < ActiveRecord::Base
  PARAMETERS = ["diet","allergy","cuisine","course","holiday"]

  def self.load_search_parameters()
    search_parameter = {}
    PARAMETERS.each do |parameter|
      search = self.find_by_name parameter
      if search == nil
        answer = get_from_API(parameter)
        search = self.create(name:parameter, value: JSON.generate(JSON.parse(answer)))
      end
      search_parameter["#{parameter}"] = search
    end
    search_parameter
  end

  def self.get_from_API(parameter)
    answer = HTTParty.get(yummly_parameter_url(parameter))
    case answer.code
      when 200
        answer_json(answer)
      when 404
        # TODO not found
      when 500...600
        #TODO BOOM
    end
  end

  def self.answer_json(answer)
    first = /set_metadata\('[^']*', /
    last = /\);\Z/
    answer.gsub!(last, "").gsub!(first,"")
  end

  def self.yummly_parameter_url(parameter)
    url = "http://api.yummly.com/v1/api/metadata/#{parameter}?_app_id=#{ENV['YUMMLY_APP_ID']}&_app_key=#{ENV['YUMMLY_APP_KEY']}"
    URI.escape(url)
  end
end
