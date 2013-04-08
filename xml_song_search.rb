require 'rubygems'
require 'sinatra'
require 'nokogiri'
require 'ruby-progressbar'

artist_and_title = nil
configure do
  ## This happens at startup

  # Sample item
  #<Items_x0020_Query>
  #<Artist>Bryan, Luke</Artist>
  #<Title>Take My Drunk Ass Home</Title>
  #<ID>Kv155907</ID>
  #<SongPath>D:\Karaoke\01-New\Kv155907 - Bryan, Luke - Take My Drunk Ass Home.zip</SongPath>
  #</Items_x0020_Query>
  songsXML = Nokogiri::XML(File.open("assets/KJPaulSongList.xml"))
  titles = songsXML.xpath('//Title')
  artist_and_title = {}
  progressbar = ProgressBar.create(:title => "Setting up", :starting_at => 0, :total => titles.count)
  titles.each {|title|
    progressbar.increment
    item = title.parent
    artist_and_title["#{item.at_css('Artist').text} #{item.at_css('Title').text}".downcase] = item
  }
end

get '/' do
  songAdded = params["added"]
  haml :index, locals: {resultsList: nil, songAdded: songAdded}
end

post '/' do
  searchTerm = params[:song].downcase
  matches = []
  if not searchTerm.empty?
    terms = searchTerm.split(' ')
    artist_and_title.each {|k,v|
      terms_found = 0
      terms.each {|term|
        if k.include? term
          terms_found += 1
        else
          break
        end
      }
      matches.push v if (terms_found == terms.count)
    }
  end

  haml :index, locals: {resultsList: matches, songAdded: nil}
end

post '/addSong' do
  file = params[:file]
  # TODO: Maybe unzip?

  # TODO: Append filename to end of m3u file

  redirect '/?added=' + URI.encode(file)
end