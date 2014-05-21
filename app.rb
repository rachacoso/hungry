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
# 	attr_accessor :total, :
# end

# class User
# 	attr_accessor :first, :last
# end

# HOMEPAGE

get '/' do
	erb :home
end

# VIEW the menu
get '/menu' do 

	# get items by type
	@appitems = menuitems_c.find({type: "appetizer"}).sort(:name)
	@mainitems = menuitems_c.find({type: "main"}).sort(:name)
	@dessitems = menuitems_c.find({type: "dessert"}).sort(:name)
	@bevitems = menuitems_c.find({type: "beverage"}).sort(:name)

	@allitems = Hash.new
	@allitems['Appetizers'] = @appitems
	@allitems['Mains'] = @mainitems
	@allitems['Desserts'] = @dessitems
	@allitems['Beverages'] = @bevitems

	erb :menu
end

# EDIT the menu

get '/editmenu' do 

	# get items by type
	@appitems = menuitems_c.find({type: "appetizer"}).sort(:name)
	@mainitems = menuitems_c.find({type: "main"}).sort(:name)
	@dessitems = menuitems_c.find({type: "dessert"}).sort(:name)
	@bevitems = menuitems_c.find({type: "beverage"}).sort(:name)

	@allitems = Hash.new
	@allitems['Appetizers'] = @appitems
	@allitems['Mains'] = @mainitems
	@allitems['Desserts'] = @dessitems
	@allitems['Beverages'] = @bevitems
	erb :editmenu

end

post '/editmenu' do

	wholeprice = params[:price_dollars] + '.' + params[:price_cents]

	edititem = menuitems_c.find("_id" => BSON::ObjectId(params[:itemid])).first
	edititem['name'] = params[:name]
	edititem['description'] = params[:description]
	edititem['price'] = wholeprice.to_f

	menuitems_c.save(edititem)
	
	redirect_page = '/editmenu' + '#' + params[:type]
	redirect to( redirect_page ) 

end

post '/addtomenu' do

	wholeprice = params[:price_dollars] + '.' + params[:price_cents]

	additem = Hash.new
	additem['name'] = params[:name]
	additem['description'] = params[:description]
	additem['price'] = wholeprice.to_f
	additem['type'] = params[:type]

	menuitems_c.save(additem)

	redirect_page = '/editmenu' + '#' + params[:type]
	redirect to( redirect_page ) 

end

get '/deletemenu' do

	menuitems_c.remove("_id" => BSON::ObjectId(params[:itemid]))
	
	redirect_page = '/editmenu' + '#' + params[:type]
	redirect to( redirect_page ) 
end

