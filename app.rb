require 'sinatra'

require 'mongo'

include Mongo # add Mongo namespace

enable :sessions


#cookies test
get '/foo' do
	session['m'] = 'Hello World!'
	session['order'] = 'this is an order'
	# if session['ordertest']
	# 	session['ordertest'] = session['ordertest'] + ', and another'
	# else 
	# 	session['ordertest'] = 'New Order'
	# end

	redirect '/bar'
end

get '/bar' do
	session['m']   # => 'Hello World!'
	session['order']
	# session['ordertest']
	# if session['order']
	# 	session['order']
	# end
	# session['order']
end

get '/resetcookie' do
	session['order'] = nil
	session['m'] = nil
	redirect '/menu'
end



# for local access
mongo = MongoClient.new
db = mongo['hungry']
menuitems_c = db['menuitems']
users_c = db['users']
orders_c = db['orders']


class Hash
  def except(which)
    self.tap{ |h| h.delete(which) }
  end
end

# class Order

# 	attr_reader :items

# 	def initialize
# 		@data = []
# 	end

# 	def add_item(item)
# 		@data.push(item)
# 	end

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
	@allitems = Hash.new
	all_allitems = Hash.new

	@allitems['Appetizers'] = menuitems_c.find({type: "appetizer"}).sort(:name)
	@allitems['Mains'] = menuitems_c.find({type: "main"}).sort(:name)
	@allitems['Desserts'] = menuitems_c.find({type: "dessert"}).sort(:name)
	@allitems['Beverages'] = menuitems_c.find({type: "beverage"}).sort(:name)

	all_allitems = menuitems_c.find()
	
	if session['order'] # if order already exists output hash with Item name and Quantity
		@order_in_progress = Hash.new
		@order_total = 0
		items_list = orders_c.find( "_id" => BSON::ObjectId(session['order'].to_s) ).first
		items_list.each do |k,v|
			next if k == '_id'
			this_item = menuitems_c.find( "_id" => BSON::ObjectId(k) ).first
			item_price_total = v * this_item['price']
			@order_in_progress[this_item['name']] = [ v.to_s , this_item['price'] ,  item_price_total.to_f , k ]
			@order_total += item_price_total.to_f
		end
	end

	erb :menu
end

# ADD TO / CREATE order
post '/addtoorder' do 
	if session['order'] #if order already exists
		order_in_progress = orders_c.find("_id" => BSON::ObjectId(session['order'].to_s)).first
		if order_in_progress[params[:itemid]] #if item already is in order
			order_in_progress[params[:itemid]] += params[:quantity].to_i
		else	#if item is not yet in order
			order_in_progress[params[:itemid]] = params[:quantity].to_i
		end

		orders_c.save(order_in_progress)

	else

		order_thing = { params[:itemid] => params[:quantity].to_i }
		new_orderid = orders_c.insert ( order_thing )
		session['order'] = new_orderid # make cookie the order ID
	end

	redirect '/menu'
end

# EDIT order
get '/deleteorderitem' do

	if params[:itemid]
		order_in_progress = orders_c.find("_id" => BSON::ObjectId(session['order'].to_s)).first # get order
		order_in_progress.except(params[:itemid])
		orders_c.save(order_in_progress) # save order


		if order_in_progress.length <= 1 # delete order if no more items in it and reset cookie
			orders_c.remove("_id" => BSON::ObjectId(session['order'].to_s))
			session['order'] = nil
		end

	end


	redirect to('/menu')

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

