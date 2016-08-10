require 'rails_helper'

RSpec.describe VotingBooth do
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
  let(:voting_booth) { described_class.new(user, movie) }

  describe '#vote' do
    let(:like_or_hate) { :like }

    subject { voting_booth.vote(like_or_hate) }

    it { is_expected.to be_eql voting_booth }

    context 'when not like or hate' do
      let(:like_or_hate) { :something }

      it 'raises an error' do
        expect { subject }.to raise_error
      end
    end

    context 'when like' do
      before { subject }

      it 'increments the number of likers' do
        expect(movie.likers.first).to be_eql user
        expect(movie.liker_count).to be 1
      end
    end

    context 'when hate' do
      let(:like_or_hate) { :hate }

      before { subject }

      it 'decrements the number of haters' do
        expect(movie.haters.first).to be_eql user
        expect(movie.hater_count).to be 1
      end
    end

    context 'when the user already voted' do
      before do
        voting_booth.vote :hate
        subject
      end

      it 'replaces the old vote by the new one' do
        expect(movie.likers.first).to be_eql user
        expect(movie.liker_count).to be 1
        expect(movie.haters.first).to be nil
        expect(movie.hater_count).to be 0
      end
    end

    it 'sends an email to the movie user' do
      Sidekiq::Testing.inline! do
        expect { subject }.to change { ActionMailer::Base.deliveries.count }.by(1)
      end
    end
  end

  describe '#unvote' do
    subject { voting_booth.unvote }

    before do
      voting_booth.vote :hate
      subject
    end

    it { is_expected.to be_eql voting_booth }

    it 'decrements the counter for the user' do
      expect(movie.haters.first).to be nil
      expect(movie.hater_count).to be 0
    end
  end
end
