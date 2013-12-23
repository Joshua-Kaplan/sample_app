require 'spec_helper'

describe "User Pages" do
  
  subject { page }



  describe "signup page" do
  		before { visit signup_path }

	  	describe "tile and heading" do
		  	it { should have_content('Sign up') }
		  	it { should have_title(full_title('Sign up'))}
	  	end

	  	describe "user signup" do
	  		let(:submit) { "Create my account" }

		  	describe "with invalid information" do
		  	 	it "should should not create a user" do
		  	 		expect { click_button submit }.not_to change(User, :count)
		  	 	end
		  	end

		  	describe "display error messages with invalid input" do
		  		before {click_button submit}

		  		it { should have_title('Sign up')}
		  		it { should have_selector('div.alert.alert-error', text: 'The form contains 5 errors')}
		  		it { should have_content('Name can\'t be blank') }
		  		it { should have_content('Email can\'t be blank') }
		  		it { should have_content('Email is invalid') }
		  		it { should have_content('Password is too short') }
		  	end

	  		describe "with valid information" do
		  	 	before do
		  	 	  fill_in "Name", 		  with: "Yehoshua T Kaplan"
		  	 	  fill_in "Email",		  with: "ytkaplan@gmail.com"
		  	 	  fill_in "Password",	  with: "foobar"
		  	 	  fill_in "Confirmation", with: "foobar"
		  	 	end

		  	 	it "should create a user" do
		  	 		expect { click_button submit }.to change(User, :count).by(1)
		  	 	end

		  	 	describe "after saving the user" do
        			before { click_button submit }
        			let(:user) { User.find_by(email: 'ytkaplan@gmail.com') }

        			it { should have_link('Sign out') }
        			it { should have_title(user.name) }
        			it { should have_selector('div.alert.alert-success', text: 'Welcome') }
      		end
	  		end
	  	end
  end

   describe "profile page" do
  	let(:user) { FactoryGirl.create(:user) }
  	before { visit user_path(user) }

  	it { should have_content(user.name) }
  	it { should have_title(user.name) }
  end
end