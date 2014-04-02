RubyTram
=========
###Clone of Ruby on Rails
This is a custom library implementing a subset of the functionality of Rails.

###Tour of this project: 

Clone the repo and go to the route directory, then run "ruby server.rb". WEBrick should start up on port 8080. Then open a browser and 
go to localhost:8080. You should see a very simple application for "tweeting" and viewing your "tweets." 

Then go to the /app directory to see the code that is responsible for creating the server. It looks essentially what it would look like in rails, except without the benefit of some helper methods.

This is not a rails app however, instead it uses RubyTram. The code of the lib directory, containing the RubyTram library, can be divided into two major parts: active record lite, in it's own directory, and the rest, in the ruby_tram directory.

####Active Record lite: 
This part of the code handles interfacing with the database through models. It implements, save, update, find, all, relations, has_one_through, and lazy evaluation of chained where queries using Relation objects. Metaprogramming is used to turn column names of a SQL table into accessor methods for model classes.

####The rest:
The rest of the code covers the router, the controllers the views. Controllers actions are correlated to Routes using metaprogramming, and views are implemented by evaluating ERB templates in the context of the cooresponding controller methods.
