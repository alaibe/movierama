require 'spec_helper'

RSpec.describe UserMailer, type: :mailer do
  let(:user) do
    User.create(
      uid:   'null|12345',
      name:  'Bob',
      email: 'foo@doe.com'
    )
  end
  let(:movie) do
    Movie.create(
      title:        'Empire strikes back',
      description:  'Who\'s scruffy-looking?',
      date:         '1980-05-21',
      user:         user
    )
  end
  let(:mail) { described_class.new_vote(user, movie, :like).deliver }

  it 'renders the subject' do
    expect(mail.subject).to eq('New vote')
  end

  it 'renders the receiver email' do
    expect(mail.to).to eq([user.email])
  end

  it 'displays the hate or likee' do
    expect(mail.body).to include('like')
  end

  it 'displays the movie name' do
    expect(mail.body).to include(movie.title)
  end
end
