class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    session[:checked_ratings] ||= Hash.new
    session[:selected_order] ||= ""
    
    if(params.size == 2)
      params[:sort_by] ||= session[:selected_order]
      params[:ratings] ||= session[:checked_ratings]
      redirect_to movies_path(params) and return
    end  
    #@movies = Movie.all
    #if params[:sort_by]== "release_date"
    #  @movies = Movie.order(:release_date)
    #elsif params[:sort_by] == "title"
    #  @movies = Movie.order(:title)
    #end
    
    @all_ratings = Movie.order(:rating).select(:rating).map(&:rating).uniq
    
    if !params[:ratings].nil?
      session[:checked_ratings] = params[:ratings]
    elsif !params[:commit].nil?
      session[:checked_ratings] = @all_ratings
    end  
    
   
    
    #if params[:ratings]
    #  session[:checked_ratings] = params[:ratings]      #  .keys
    #else
    #  session[:checked_ratings] = @all_ratings           # Hash.new
    #end
    
    #if params[:ratings]
    #  @checked_ratings = params[:ratings].keys
    #else
    #  @checked_ratings = @all_ratings
    ##end
    
    @checked_ratings = session[:checked_ratings]
    
    if !params[:sort_by].nil?
      session[:selected_order] = params[:sort_by]
    end 
    
    sort_by = (session[:selected_order] == "")?"title":session[:selected_order]
    
    @movies = Movie.order("#{sort_by}")
    
    if(@checked_ratings.any?)              #.keys
      @movies = @movies.where(:rating => @checked_ratings.keys)  
    end
    
    #@checked_ratings.each do |rating|
    #  params[rating] = true
    #end  
    
    #if params[:sort_by]
    #  @movies = Movie.order(params[:sort_by])
    #else
    #  @movies = Movie.where(:rating => @checked_ratings)
    #end  
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end
  
end
