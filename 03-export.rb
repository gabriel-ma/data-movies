require "rubygems"
require "arrayfields"
require "sqlite3"
require "set"
$db = SQLite3::Database.new( "movies.sqlite3" )
$genres_of_interest = ["Horror", "Thriller"]
$ratings_map = {"." => 0, "0" => 4.5, "1" => 14.5, "2" => 24.5, "3" => 34.5, "4" => 44.5, "5" => 45.5, "6" => 64.5, "7" => 74.5, "8" => 84.5, "9" => 94.5, "*" => 100}


def genres_binary(id)
	genres = $db.execute("SELECT genre FROM Genres where movie_id = #{id};").flatten

	if id == 568334
		File.open("grrrr.txt", "w") do |out|
			out << genres
		end
		puts genres
		puts genres.include? "Horror"
	end
	$genres_of_interest.map { |genre| (genres.include? genre) ? 1 : 0}
end

def ratings_breakdown(ratings)
    ratings[0..ratings.length].to_s.split(//).map{|s| $ratings_map[s]} rescue nil
end



sql = "
	SELECT id, title, year, country  
	FROM Movies
	WHERE length > 0 and imdb_votes > 0
	ORDER BY title"

i = 0 

File.open("movies.csv", "w") do |out|
	out << ['id',
		'title', 'year', 
		'country', $genres_of_interest
	].flatten.join(",") + "\n"
	$db.execute(sql) do |row| 
		puts i if (i = i + 1) % 5000 == 0	
		out << [
			row[0],
			row[1], 
			row[2], 
			row[3], genres_binary(row[0])
		].flatten.join(",") + "\n"
	end
end
