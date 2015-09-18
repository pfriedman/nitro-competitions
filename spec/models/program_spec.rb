# -*- coding: utf-8 -*-
# == Schema Information
#
# Table name: programs
#
#  id            :integer          not null, primary key
#  program_name  :string(255)
#  program_title :string(255)
#  program_url   :string(255)
#  created_id    :integer
#  created_ip    :string(255)
#  updated_id    :integer
#  updated_ip    :string(255)
#  deleted_at    :datetime
#  deleted_id    :integer
#  deleted_ip    :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  email         :string(255)
#

require 'spec_helper'

describe Program, :type => :model do
  it { is_expected.to have_many(:roles_users) }
  it { is_expected.to have_many(:admins).through(:roles_users) }
  it { is_expected.to have_many(:projects) }
  it { is_expected.to have_many(:reviewers) }
  it { is_expected.to have_many(:logs) }
  it { is_expected.to belong_to(:creator) }

  context '#valid?' do
    context '#program_name' do
      it { is_expected.to validate_presence_of(:program_name) }
      it { is_expected.to validate_uniqueness_of(:program_name) }
      it { is_expected.to validate_length_of(:program_name).is_at_least(2) }
      it { is_expected.to validate_length_of(:program_name).is_at_most(20) }

      it { is_expected.to allow_value('LETTERS_0123').for(:program_name) }

      it 'leaves a blank name blank' do
        p = Program.new
        p.valid?

        expect(p.program_name).to eq(nil)
      end

      it 'only allow alphanumeric characters, and replace spaces with underscores' do
        p = Program.new(program_name: ' Whitespace, c0mma.')
        p.valid?

        expect(p.program_name).to eq('Whitespace_c0mma_')
      end
    end

    context '#program_title' do
      it { is_expected.to validate_presence_of(:program_title) }
      it { is_expected.to validate_length_of(:program_title).is_at_least(2) }
      it { is_expected.to validate_length_of(:program_title).is_at_most(80) }
    end

    it { is_expected.to validate_presence_of(:program_url) }
  end
end
