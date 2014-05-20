require 'sinatra'

require 'mongo'

include Mongo # add Mongo namespace



# for local access
mongo = MongoClient.new
db = mongo['hungry']
menuitems_c = db['menuitems']
users_c = db['users']
orders_c = db['orders']

# class Menu
# 	attr_accessor :
# end

# class MenuItem < Menu

# end

# class Order
# 	attr_accessor :total
# end

# class User
# 	attr_accessor :first, :last
# end

# display menu
get '/menu' do 

	# get items by type
	@appitems = menuitems_c.find({type: "appetizer"})
	@mainitems = menuitems_c.find({type: "main"})
	@bevitems = menuitems_c.find({type: "beverage"})
	erb :menu
end
