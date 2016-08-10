class UserMailer < ActionMailer::Base
  default from: "john@movierama.com"

  def new_vote(user, movie, like_or_hate)
    @movie = movie
    @like_or_hate = like_or_hate
    mail to: user.email, subject: 'New vote'
  end
end
