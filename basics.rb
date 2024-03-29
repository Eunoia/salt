require 'rubygems'
require 'sinatra'
require 'net/http'
require 'active_record'
require 'haml'

db = (ENV['DATABASE_URL'] || "dev")
if(db=="dev")
  ActiveRecord::Base.establish_connection(
    # :adapter  => 'postgresql',
    # :host     => '127.0.0.1',
    # :username => 'shawsome',
    # :password => '',
    # :database => "shawsome_test",
    # :client_min_messages => 0,
    # :encoding => 'utf8'
    :adapter => "sqlite3",
    :database  => "posts.sql"
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

#db = URI.parse(ENV['DATABASE_URL'])
#ActiveRecord::Base.establish_connection(:adapter  => db.scheme == 'postgres' ? 'postgresql' : db.scheme, :host     => db.host, :username => db.user,:password => db.password,:database => db.path[1..-1],:client_min_messages => 0,:encoding => 'utf8')

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


get '/about' do 
  @title = "Craigslist Rideshare enhancement suite"
  @to = [:seattle,:sb,:la,:sf,:pdx]
  @fresh = "sfbay|santabarbara|portland|seattle|losangeles".split("|")
  erb :about
end
get '/to/?:dest?/?:mode?' do 
	@places = []
	if    params[:dest]=~/seattle/i
		@places +=%w{ Seattle Kirkland Tacoma Everett Redmond }
		@banner = "seattle"
	elsif params[:dest]=~/(pdx|portland)/i
    @places += %w{ Portland Beaverton Hillsborough}
    @banner = "PDX"
	elsif params[:dest]=~/(santabarbara|sb)/i
	  @places += %w{ Goleta Montecito Carpinteria Ucsb}
	  @places += ["Santa Barbara", "Isla Vista"]
	  @banner =  "SB"
	elsif params[:dest]=~/(la|lax|losangeles)/i
	  @places += %w{ La Socal Segundo Ucla Hollywood Venice Pasadena}
	  @places += ["Los Angeles", "Long Beach","Santa Monica","El Segundo"]
	  @places += ["San Gabriel Valley", "San Fernando Valley",]
	  @banner = "la"
  else
    @places += %w{ Richmond Fremont Berkeley Oakland Sf}
    @places += ["San Francisco","Bay Area","San Jose","Palo Alto"]
    @banner = "SF"
  end
  
  if(params[:mode]==nil)
	  @mode=nil
	  @modeString = "All Posts to"
	else 
    @mode = params[:mode]=~/offer/i? 1 : 0
    @modeString = @mode==1 ? "Find rides to" : "Passengers to"
  end
	@title = "Rides to #{@banner}"
	erb :list
end

get '/search/?:city?' do 
  @title = "Megoszt | Search"
  @city = "sfbay"
  if params[:city]!=nil
    #(sfbay|pdx|santabarbara|portland|seattle|losangeles)
    if(params[:city]=~/(pdx|portland)/i)
      @cl = "portland"
      @city = "Portland"
      # @banner = "PDX.png"
    elsif params[:city]=~/l(os)?a(ngeles)?/i
      @city = "Los Angeles"
      @cl = "la"
      # @banner = "la.png"
    elsif params[:city]=~/s(anta)?b(arbara)?/i
      @cl = "santabarbara"
      @city = "Santa Barbara"
      # @banner = "SB.png"
    elsif params[:city]=~/sea(ttle)?/i
      @cl = "seattle"
      @city = "Seattle"
      # @banner = "seattle.png"
    else #if params[:city]=~/sf(bay)?/i
      @cl = "sfbay"
      @city = "The bay area"
      # @banner = "SF.png"
    end
  end
  haml(:search, {:format => :html5, :layout_engine => :erb})
end
get '/:city?' do
  @title = "Leaving Today |"
  if(params[:city]=~/(pdx|portland)/i)
    @clName = "portland"
    @name = "pdx"
    @bgImg = "pdx#{rand(2)}BG.jpg"
  elsif params[:city]=~/l(os)?a(ngeles)?/i
    @clName = "losangeles"
    @name = "la"
    @bgImg = "laBG.jpg"
  elsif params[:city]=~/s(anta)?b(arbara)?/i
    @clName = "santabarbara"
    @name = "sb"
    @bgImg = "sb#{(rand*10%1).round}BG.jpg"
  elsif params[:city]=~/sea(ttle)?/i
    @clName = "seattle"
    @name = "sea"
    @bgImg = "seattle#{(rand*10%1).round}BG.jpg"
  elsif params[:city]=~/sf(bay)?/i
    @clName = "sfbay"
    @name = "SF"
    @bgImg = "sf#{rand(4)}BG.jpg"
  end
  @title += " #{(@name||"").upcase}"
  erb :today
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
	erb :about
end
get '/api/latest/:city/?:num?' do
  valid_cities = %w{sfbay santabarbara portland seattle losangeles}
  return "not a city" unless valid_cities.include? params[:city]
  posts =   Posts.find(:all, :conditions => [ "city= (?)", params[:city]], :limit => params[:num])
  combined = posts.map do |post|
    result = Results.find(post.cid)
    post_attr = %w{ posted city title content link cid }
    result_attr = %w{ cid wo orig dest leaving fitness }
    post_hash = post_attr.inject({}) do |mem, var|    
      mem[var.to_sym] = post.send(var);
      mem;
    end
    result_hash = result_attr.inject({}) do |mem, var|    
      mem[var.to_sym] = result.send(var);
      mem;
    end
    result_hash.merge(post_hash)
  end
  combined.to_json
end
not_found do
  @title = "Tyoko"
	status 404
	erb :lost
end
