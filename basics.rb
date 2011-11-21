require 'rubygems'
require 'sinatra'
require 'net/http'
require 'active_record'


#db = URI.parse(ENV['DATABASE_URL'] || 'postgres://localhost/mydb')
db = (ENV['DATABASE_URL'] || "sqlite")
if(db=="sqlite")
  ActiveRecord::Base.establish_connection(
          :adapter => "sqlite3",
          :database => "posts.sql"
  )
else
  db = URI.parse(ENV['DATABASE_URL'])
  ActiveRecord::Base.establish_connection(
    :adapter  => db.scheme == 'postgres' ? 'postgresql' : db.scheme,
    :host     => db.host,
    :username => db.user,
    :password => db.password,
    :database => db.path[1..-1],
    :client_min_messages => 'NOTICE',
    :encoding => 'utf8'
  )
end


class Posts < ActiveRecord::Base
  # validates_uniqueness_of :cid
  set_primary_key :cid
  has_one(:result, {:foreign_key => :cid , :primary_key => :cid })
end
class Results < ActiveRecord::Base
 #  validates_uniqueness_of :cid
 set_primary_key :cid
 #belongs_to(:posts,{ :foreign_key => :cid, :primary_key => :cid})
end
i = 0 


get '/' do 
  @title = "Craigslist Rideshare enhancement suite"
  @to = [:seattle,:sb,:la,:sf,:pdx]
  @fresh = "sfbay|santabarbara|portland|seattle|losangeles".split("|")
  erb :slash
end
get '/to/:dest/?:mode?' do 
	@places = []
	if(params[:mode]==nil)
	  @mode=nil
	  @modeString = "All Posts to"
	else 
    	@mode = params[:mode]=~/offer/i? 1 : 0
	  #@mode = 1
    @modeString = @mode==1 ? "Find rides to" : "Passengers to"
  end
	if    params[:dest]=~/seattle/i
		@places +=%w{ Seattle Kirkland Tacoma Everett Redmond }
		@banner = "Seattle"
	elsif params[:dest]=~/s(anta)? ?b(arbara)?/i
	  @places += %w{ Goleta Montecito Carpinteria Ucsb}
	  @places += ["Santa Barbara", "Isla Vista"]
	  @banner =  "SB"
	elsif params[:dest]=~/la/
	  @places += %w{ La Socal Segundo Ucla Hollywood Venice Pasadena}
	  @places += ["Los Angeles", "Long Beach","Santa Monica","El Segundo"]
	  @places += ["San Gabriel Valley", "San Fernando Valley",]
	  @banner = "la"
  elsif params[:dest]=~/sf/i
    @places += %w{ Richmond Fremont Berkeley Oakland Sf}
    @places += ["San Francisco","Bay Area","San Jose","Palo Alto"]
    @banner = "SF"
  elsif params[:dest]=~/(portland|pdx)/i
    @places += %w{ Portland }
    @banner = "PDX"
  end
	@title = "Rides to #{params[:dest]}"
	erb :list
	##{}"Hello #{params[:dest]}";
end
get '/fresh/?:city?' do 
  @title = "Fresh updates from the feeds"
  @city = "sfbay"
  if params[:city]!=nil
    #(sfbay|pdx|santabarbara|portland|seattle|losangeles)
    if(params[:city]=~/(pdx|portland)/i)
      @cl = "portland"
      @city = "Portland"
      @banner = "PDX.png"
    elsif params[:city]=~/l(os)?a(ngeles)?/i
      @city = "Los Angeles"
      @cl = "la"
      @banner = "la.png"
    elsif params[:city]=~/s(anta)?b(arbara)?/i
      @cl = "santabarbara"
      @city = "Santa Barbara"
      @banner = "SB.png"
    elsif params[:city]=~/sea(ttle)?/i
      @cl = "seattle"
      @city = "Seattle"
      @banner = "seattle.png"
    elsif params[:city]=~/sf(bay)?/i
      @cl = "sfbay"
      @city = "The bay area"
      @banner = "SF.png"
    end
  end
  erb :fresh
end
get '/tonight/?:city?' do
  @title = "Leaving Today |"
  if(params[:city]=~/(pdx|portland)/i)
    @dbName = "portland"
    @city = "Portland"
    @bg = "PDX.png"
  elsif params[:city]=~/l(os)?a(ngeles)?/i
    @clName = "losangeles"
    @name = "la"
    @bgImg = "laBG.jpg"
  elsif params[:city]=~/s(anta)?b(arbara)?/i
    @cl = "santabarbara"
    @city = "sb"
    @banner = "sb1BG.jpg"
  elsif params[:city]=~/sea(ttle)?/i
    @clName = "seattle"
    @name = "sea"
    @bgImg = "seattle#{(rand*10%2).round}BG.jpg"
  else #if params[:city]=~/sf(bay)?/i
    @clName = "sfbay"
    @name = "SF"
    @bgImg = "sf#{(rand*10%5).round}BG.jpg"
  end
  erb :tonight
end
get '/hello/:name' do
	"Hello, #{params[:name]}"
end
get '/more/*' do
	params[:splat]
end
get '/post/:cid' do
  @post = Posts.find_by_cid(params[:cid].to_i)
  @result = Results.find_by_cid(params[:cid].to_i)
  @title =  @result.dest
  @title += " from "
  @title += @post.city.to_s
  @title += ": "
  @title += @post.title
	erb :aPost
end
get '/about' do
	"A little about me";
end
not_found do
  @title = "Tyoko"
	status 404
	erb :lost
end
