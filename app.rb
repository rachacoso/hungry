require 'sinatra'

require 'mongo'

include Mongo # add Mongo namespace

enable :sessions


#cookies test
get '/foo' do
	session['m'] = 'Hello World!'
	if session['order']
		session['order'] = session['order'] + ', and another'
	else 
		session['order'] = 'New Order'
	end

	redirect '/bar'
end

get '/bar' do
	session['m']   # => 'Hello World!'
	session['order']
end




# for local access
mongo = MongoClient.new
db = mongo['hungry']
menuitems_c = db['menuitems']
users_c = db['users']
orders_c = db['orders']



class Order

	attr_reader :items

	def initialize
		@data = []
	end

	def add_item(item)
		@data.push(item)
	end

end

# class User
# 	attr_accessor :first, :last
# end

# HOMEPAGE

get '/' do
	erb :home
end

# VIEW the menu
get '/menu' do 

	# if session['order'] # if order already exists
	# 	@order_in_progress = orders_c.find("_id" => BSON::ObjectId(params[session['order']])).first
	# end


	# get items by type
	@allitems = Hash.new

	@allitems['Appetizers'] = menuitems_c.find({type: "appetizer"}).sort(:name)
	@allitems['Mains'] = menuitems_c.find({type: "main"}).sort(:name)
	@allitems['Desserts'] = menuitems_c.find({type: "dessert"}).sort(:name)
	@allitems['Beverages'] = menuitems_c.find({type: "beverage"}).sort(:name)

	erb :menu
end

# ADD TO / CREATE order
post '/addtoorder' do 
	# if session['order'] #if order already exists

	# end



end


# EDIT the menu

get '/editmenu' do 

	@allitems = Hash.new
	# get items by type
	@allitems['Appetizers'] = menuitems_c.find({type: "appetizer"}).sort(:name)
	@allitems['Mains'] = menuitems_c.find({type: "main"}).sort(:name)
	@allitems['Desserts'] = menuitems_c.find({type: "dessert"}).sort(:name)
	@allitems['Beverages'] = menuitems_c.find({type: "beverage"}).sort(:name)

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

	if params[:itemid]
		menuitems_c.remove("_id" => BSON::ObjectId(params[:itemid]))
		redirect_page = '/editmenu' + '#' + params[:type]
		redirect to( redirect_page ) 
	else 
		redirect to('/editmenu')
	end
end

