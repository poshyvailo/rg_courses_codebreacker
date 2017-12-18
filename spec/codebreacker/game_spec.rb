require 'pry'

module Codebreaker
  RSpec.describe Game do

    subject { described_class.new('Player') }

    context '#initialize' do

      context 'Secret code' do
        it 'generates secret code' do
          expect(subject.secret_code).not_to be_nil
        end

        it 'secret code length 4 characters' do
          expect(subject.secret_code.size) == 4
        end

        it 'saves secret code with numbers from 1 to 6' do
          expect(subject.valid_code? subject.secret_code ).to be_truthy
        end
      end

      context 'Attempts' do
        it 'attempts set' do
          expect(subject.attempts).not_to be_nil
        end

        it 'attempts is Integer' do
          expect(subject.attempts).to be_an(Integer)
        end

        it 'attempts > 0' do
          expect(subject.attempts).to be > 0
        end
      end

      context 'Hints' do
        it 'hints set' do
          expect(subject.hints).not_to be_nil
        end

        it 'hints is Integer' do
          expect(subject.hints).to be_an(Integer)
        end

        it 'hints > 0' do
          expect(subject.hints).to be > 0
        end
      end
    end

    context '#make_guess' do

      # let(:game) { described_class.new('Player') }

      it 'raise error when passing wrong guess' do
        expect { subject.make_guess('11112') }.to raise_error(ArgumentError)
        expect { subject.make_guess('qqwe') }.to raise_error(ArgumentError)
        expect { subject.make_guess('12er') }.to raise_error(ArgumentError)
        expect { subject.make_guess('xxxx') }.to raise_error(ArgumentError)
      end

      it 'remove one attempts' do
        expect { subject.make_guess('1111') }.to change(subject, :attempts).by(-1)
      end

      it 'change status if player win' do
        subject.instance_variable_set(:@secret_code, '1234')
        expect { subject.make_guess('1234') }.to change(subject, :status).from(:play).to(:win)
      end

      it 'change status if player lose' do
        subject.instance_variable_set(:@attempts, 0)
        expect { subject.make_guess('1234') }.to change(subject, :status).from(:play).to(:lose)
      end

    end

    context '#check_guess' do

      data = [
          %W[5555 1111 #{''}],
          %W[5555 5555 ++++],
          %W[1234 1243 ++--],
      ]

      data.each do |item|
        it "result #{item[2].inspect} for code #{item[0].inspect}, and guess #{item[1].inspect}" do
          subject.instance_variable_set(:@secret_code, item[0])
          expect(subject.send(:check_guess, item[1])).to be == item[2]
        end
      end

    end

  end
end