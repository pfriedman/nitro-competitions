# -*- coding: utf-8 -*-
require 'spec_helper'

describe User do

  it { should have_many(:reviewers) }
  it { should have_many(:key_personnel) }
  it { should have_many(:submission_reviews) }
  it { should have_many(:reviewed_submissions) }
  it { should have_many(:roles_users) }
  it { should have_many(:roles).through(:roles_users) }
  it { should have_many(:logs) }
  it { should have_many(:submissions) }
  it { should have_many(:proxy_submissions) }

  it { should belong_to(:biosketch) }

  it 'can be instantiated' do
    FactoryGirl.build(:user).should be_an_instance_of(User)
  end

  it 'can be saved successfully' do
    FactoryGirl.create(:user).should be_persisted
  end

  context 'user validations' do
    let(:user) { User.new }
    describe 'with validations set to true' do
      before do
        user.validate_email_attr = true
        user.validate_era_commons_name = true
      end
      it 'is not valid' do
        user.should_not be_nil
        user.should_not be_valid
        [:username, :first_name, :last_name, :email, :era_commons_name].each do |att|
          user.errors.should include(att)
        end
      end
    end
    describe 'with validations set to false' do
      before do
        user.validate_email_attr = false
        user.validate_era_commons_name = false
      end
      it 'attributes are not included in errors' do
        user.should_not be_nil
        user.should_not be_valid
        [:email, :era_commons_name].each do |att|
          user.errors.should_not include(att)
        end
      end
    end
    describe 'with validations set to nil' do
      before do
        user.validate_email_attr = nil
        user.validate_era_commons_name = nil
      end
      it 'attributes are not included in errors' do
        user.should_not be_nil
        user.should_not be_valid
        [:email, :era_commons_name].each do |att|
          user.errors.should_not include(att)
        end
      end
    end
  end

  # TODO: fix this test - or determine if this should be a test
  #  test 'user is project reviewer' do
  #    the_user = users(:one)

  #    assert !the_user.nil?
  #    assert the_user.valid?
  # end

  describe '#key_personnel' do
    let(:key_person) { FactoryGirl.create(:key_person) }
    let(:user) { key_person.user }
    it 'returns KeyPerson associations' do
      user.key_personnel.should_not be_blank
      user.should eq user.key_personnel.first.user
    end
  end

  describe '#reviewers' do
    let(:reviewer) { FactoryGirl.create(:reviewer) }
    let(:user) { reviewer.user }
    it 'returns Reviewer associations' do
      user.reviewers.should_not be_blank
      user.should eq user.reviewers.first.user
      user.reviewers.first.program.should_not be_blank
    end
  end

  describe '#submission_reviews' do
    let(:submission_review) { FactoryGirl.create(:submission_review) }
    let(:user) { submission_review.reviewer }
    it 'returns SubmissionReview associations' do
      user.submission_reviews.should_not be_blank
      user.should eq user.submission_reviews.first.reviewer
    end
  end

  describe '#reviewed_submissions' do
    let(:submission_review) { FactoryGirl.create(:submission_review) }
    let(:user) { submission_review.reviewer }
    it 'returns SubmissionReview associations' do
      user.reviewed_submissions.should_not be_blank
    end
  end

  describe '#roles_users' do
    let(:ru) { FactoryGirl.create(:roles_user) }
    let(:user) { ru.user }
    it 'returns RolesUser associations' do
      user.roles_users.should_not be_blank
      user.roles_users.first.role.should_not be_blank
    end
  end

  context 'as applicant' do
    let(:submission) { FactoryGirl.create(:submission) }
    let(:user) { submission.applicant }
    describe '#submissions' do
      it 'returns Submission associations' do
        user.submissions.should_not be_blank
        user.submissions.each do |submission|
          submission.applicant.should eq user
        end
      end

      it 'is associated with a project' do
        user.submissions.each do |submission|
          submission.project.should_not be_blank
        end
      end
    end

    describe '.project_applicants' do
      it 'returns applicants for a project' do
        project = user.submissions.first.project
        applicants = User.project_applicants(project.id)
        applicants.should_not be_blank
        applicants.each do |applicant|
          applicant.should eq applicant.submissions.first.applicant
        end
      end
    end
  end

  context 'as reviewer' do
    let(:reviewer) { FactoryGirl.create(:reviewer) }
    let(:user) { reviewer.user }

    describe '.program_reviewers' do
      it 'returns reviewers for a program' do
        reviewers = User.program_reviewers(reviewer.program_id)
        reviewers.should_not be_blank
        reviewers.first.should_not be_blank
      end
    end
  end

  context 'as submitter' do
    describe '#proxy_submissions' do
      let(:submission) { FactoryGirl.create(:submission) }
      let(:user) { submission.submitter }
      it 'returns Submission associations' do
        user.proxy_submissions.should_not be_blank
        user.proxy_submissions.each do |submission|
          submission.submitter.should eq user
        end
      end
    end
  end

  describe '.find_or_create_from_omniauth' do
    let(:netid) { 'netid' }
    let(:email) { 'username@gmail.com' }
    let(:nu_email) { 'netid@northwestern.edu' }
    let(:omniauth) do
      OmniAuth::AuthHash.new(
      {
        provider: 'nucatsmembership',
        uid: 99,
        info: OmniAuth::AuthHash.new(
          {
            name: 'John X. Doe',
            first_name: 'John',
            last_name: 'Doe',
            email: email,
          }
        ),
        extra: OmniAuth::AuthHash.new(
          {
            name: 'John X. Doe',
            first_name: 'John',
            last_name: 'Doe',
            email: email,
            person_identities: [
              OmniAuth::AuthHash.new(
              {
                provider: 'google_oauth2',
                uid: '111111111111111111111',
                email: email,
                provider_username: nil,
                username: nil,
                nickname: nil,
                domain: nil
              }),
              OmniAuth::AuthHash.new(
              {
                provider: 'northwestern_medicine',
                uid: "nu\\#{netid}",
                email: nu_email,
                provider_username: netid,
                username: "nu\\#{netid}",
                nickname: nil,
                domain: 'nu'
              })
            ]
          }
        )
      })
    end
    context 'for a new User' do
      it 'creates a User record with data from omniauth' do
        u = User.find_or_create_from_omniauth(omniauth)
        u.should be_persisted
        u.should be_an_instance_of(User)
        u.username.should eq netid
      end
    end

    context 'for existing User records' do
      context 'with the same email address' do
        let!(:user) { FactoryGirl.create(:user, email: email, first_name: 'f', last_name: 'l') }
        it 'finds the User' do
          updated = User.find_or_create_from_omniauth(omniauth)
          updated.id.should eq user.id
        end
      end

      context 'without an email address' do
        context 'with google oauth provider' do
          let!(:user) { FactoryGirl.create(:user, email: nil, first_name: 'f', last_name: 'l', username: email) }
          it 'finds the User' do
            updated = User.find_or_create_from_omniauth(omniauth)
            updated.id.should eq user.id
          end
        end

        context 'with the northwestern oauth provider' do
          let!(:user) { FactoryGirl.create(:user, email: nil, first_name: 'f', last_name: 'l', username: netid) }
          it 'finds the User and updates User attributes' do
            updated = User.find_or_create_from_omniauth(omniauth)
            updated.id.should eq user.id
          end
        end

        # It is quite possible that a User will be logged in using
        # differing providers resulting in more than one User record
        # having been created @see User.find_or_create_from_omniauth
        context 'with multiple oauth providers' do
          let!(:nu_user) { FactoryGirl.create(:user, email: nil, first_name: 'f', last_name: 'l', username: netid) }
          let!(:ext_user) { FactoryGirl.create(:user, email: nil, first_name: 'f', last_name: 'l', username: email) }
          it 'prefers the nu over outside if User exists matching both' do
            updated = User.find_or_create_from_omniauth(omniauth)
            updated.id.should eq nu_user.id
            updated.id.should_not eq ext_user.id
          end
        end
      end
    end
  end
end
