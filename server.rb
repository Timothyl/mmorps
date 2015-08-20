require "sinatra"
require "pry"

use Rack::Session::Cookie, {
  secret: "keep_it_secret_keep_it_safe"
}

get "/" do
  if session[:visit_count].nil?
    visit_count = 1
    session[:comp_score] = 0
    session[:human_score] = 0
    session[:winner] = 'nobody'
    # binding.pry
  else
    visit_count = session[:visit_count].to_i
  end

  session[:visit_count] = visit_count + 1

  erb :game
  # "You've visited this page #{visit_count} time(s).\n"
end

post "/" do
  session[:human_choice] = params[:choice].to_sym
  session[:comp_choice] = Game.get_comp_choice
  result = Game.evaluate_moves(session[:comp_choice], session[:human_choice])
  if result == :tie
    session[:result] = 'This round is a tie'
  elsif result == :comp_win
    session[:result] = 'The computer won this round'
    session[:comp_score] = session[:comp_score].to_i + 1
  elsif
    session[:result] = 'You won this round'
    session[:human_score] = session[:human_score].to_i + 1
  end

  if session[:human_score].to_i == 2
    session[:winner] = :player
  end

  if session[:comp_score].to_i == 2
    session[:winner] = :computer
  end

redirect "/"

end

post "/reset" do
  session[:human_choice] = nil
  session[:comp_choice] = ""
  session[:comp_score] = 0
  session[:human_score] = 0
  session[:winner] = 'nobody'

  redirect "/"
end

class Game

  def self.get_comp_choice
    move = rand(3)
    if move == 1
      :rock
    elsif move == 2
      :paper
    else
      :scissors
    end
  end

  def self.evaluate_moves(comp_move, person_move)
    if comp_move == person_move
      return :tie
    elsif comp_move == :rock && person_move == :scissors ||
      comp_move == :paper && person_move == :rock ||
      comp_move == :scissors && person_move == :paper
      return :comp_win
    else
      return :person_win
    end
  end

end
