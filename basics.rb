require 'rubygems'
require 'sinatra'
require 'net/http'
require 'active_record'
require 'logger'

set :logging, true

error_logger = Logger.new('errors.log')

ActiveRecord::Base.establish_connection(
        :adapter => "sqlite3",
        :database => "posts.sql"
)

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
	i=i+1;
	"Hello World #{i=i+1}";
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
	  @places += %w{ La Socal Segundo UCLA Hollywood Venice Pasadena}
	  @places += ["Los Angeles", "Long Beach","Santa Monica"]
	  @banner = "la"
  elsif params[:dest]=~/sf/i
    @places += %w{ Richmond Fremont Berkeley Oakland Sf}
    @places += ["San Francisco","Bay Area","San Jose","Palo Alto"]
    @banner = "SF"
  elsif params[:dest]=~/p(ortlan)?d(x)?/
    @places += %w{ Portland }
    @banner = "PDX"
  end
	@title = "Rides to #{params[:dest]}"
	erb :list
	##{}"Hello #{params[:dest]}";
end
get '/fresh/?:city?' do 
  @title = "Funky Fresh updates from the feeds"
  @city = "sfbay"
  puts params[:city]
  if params[:city]!=nil and params[:city]=~/(sfbay|pdx|santabarbara|portland|seattle|losangeles)/
    if(params[:city]=~/pdx/i)
      @city = "portland"
    else
      @city = params[:city] 
    end
  end
  puts params[:city]+"########"
	erb :fresh
end
get '/hello/:name' do
	"Hello, #{params[:name]}"
end
get '/more/*' do
	params[:splat]
end
get '/post/:cid' do
  @post = Posts.find_by_cid(params[:cid])
  @result = Results.find_by_cid(params[:cid])
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
