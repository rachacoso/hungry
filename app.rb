require 'sinatra'

require 'mongo'

include Mongo # add Mongo namespace



# for local access
mongo = MongoClient.new
db = mongo['hungry']
menu = db['menu']
u_coll = db['users']
o_coll = db['orders']

class Menu
	attr_accessor :
end

class MenuItem < Menu

end

class Order
	attr_accessor :total
end

class User
	attr_accessor :first, :last
end


get '/add' do 

	coll.insert({name: 'foo'})
	'done!'
end
