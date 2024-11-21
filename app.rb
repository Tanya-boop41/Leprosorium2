#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def init_db
	@db = SQLite3::Database.new 'leprosorium.db'
	@db.results_as_hash = true
end

before do
	init_db
end

configure do
	init_db
	@db.execute 'CREATE TABLE IF NOT EXISTS Posts 
		("id" INTEGER PRIMARY KEY AUTOINCREMENT,
		 "created_date" DATE,
		 "content" TEXT,
		 "author" TEXT)'

	@db.execute 'CREATE TABLE IF NOT EXISTS Comments 
		("id" INTEGER PRIMARY KEY AUTOINCREMENT,
		 "created_date" DATE,
		 "content" TEXT,
		 "post_id" INTEGER)'
end

get '/' do
	
	@results = @db.execute 'SELECT * FROM Posts ORDER BY id DESC'
	erb :index			
end

get '/new' do
	erb :new
end

post '/new' do
	@content = params[:content]
	#@author = params[:author]

	if @content.length < 1
		@error = 'Type text'
		return erb :new
	end

	#if @author.length < 1
	#	@error = 'Type author'
	#	return erb :new
	#end

	@db.execute 'INSERT INTO Posts (content, created_date, author) VALUES (?, datetime(), ?)', [@content, @author]
	#возврат на главную страницу
	redirect to '/'
	
end

#вывод информации о посте

get '/details/:post_id' do
	#получаем переменную из url'а
	post_id = params[:post_id]
	#получаем список постов (у нас будет только один пост)
	results = @db.execute 'SELECT * FROM Posts WHERE id = ?', [post_id]
	#выбираем этот один пост в переменную @row
	@row = results[0]
	#выбираем комментарии для нашего поста
	@comments = @db.execute 'SELECT * FROM Comments WHERE post_id = ? ORDER BY id', [post_id]
	#возвращаем представление
	erb :details
end

post '/details/:post_id' do
	#получаем переменную из url'а
	post_id = params[:post_id]
	#получаем переменную из post-запроса
	content = params[:content]
		if content.length < 1
		
		@error = 'Type comment'
		erb 'Добавьте комментарий'
		else
		@db.execute 'INSERT INTO Comments (content, created_date, post_id) 
		VALUES (?, datetime(), ?)', [content, post_id]
		#возврат на страницу поста
		redirect to('/details/' + post_id)
	end
end

