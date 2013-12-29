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

	describe "edit" do
		let(:user) { FactoryGirl.create(:user) }
		before do
			sign_in user 
			visit edit_user_path(user)
		end


		describe "page" do
			it { should have_content("Update your profile") }
			it { should have_title("Edit user") }
			it { should have_link('change', href: 'http://gravatar.com/emails') }
		end

		describe "with invalid information" do
			before { click_button "Save Changes" }
			
			it { should have_content('error') }
		end

		describe "with valid information" do
			let(:new_name) { "New Name" }
			let(:new_email) { "new@example.com" }

			before do
			  fill_in "Name",						with: new_name
			  fill_in "Email",					with: new_email
			  fill_in "Password",				with: user.password
			  fill_in "Confirm Password",		with: user.password
			  click_button "Save Changes"
			end

			it { should have_title(new_name) }
			it { should have_selector('div.alert.alert-success') }
			it { should have_link('Sign out', href: signout_path) }
			specify { expect(user.reload.name).to eq new_name }
			specify { expect(user.reload.email).to eq new_email }
		end
 	end

	describe "profile page" do
		let(:user) { FactoryGirl.create(:user) }
		before { visit user_path(user) }

		it { should have_content(user.name) }
		it { should have_title(user.name) }
	end

	describe "index" do
		let(:user) { FactoryGirl.create(:user) }

		before do
		  sign_in user
		  visit users_path
		end

		it { should have_title("All users") }
		it { should have_content('All users') }

		describe "pagination" do
			before(:all) { 10.times { FactoryGirl.create(:user) } }
			after(:all) { User.delete_all }

			it { should have_selector('div.pagination') }

			it "should list each user" do
				User.paginate(page: 1, per_page: 10).each do |user|
					expect(page).to have_selector('li', text: user.name)
				end
			end
		end

		describe "as an admin user" do
			let(:admin) { FactoryGirl.create(:admin) }
			before do
			  sign_in admin
			  visit users_path
			end

			it { should have_link('delete', href: user_path(User.first)) }
			it "should be able to delete another user" do
				expect do
					click_link('delete', match: :first)
				end.to change(User, :count).by(-1)
			end
			it { should_not have_link('delete', href: user_path(admin)) }
		end

		describe "as non-admin user" do
			let(:user) { FactoryGirl.create(:user) }
			let(:non_admin) { FactoryGirl.create(:user) }

			before { sign_in non_admin, no_capybara: true }

			describe "submitting a DELETE request to the Users#destroy action" do
				before { delete user_path(user) }
				specify { expect(response).to redirect_to(root_url) }
			end
		end
	end
end
