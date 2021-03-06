# -*- coding: utf-8 -*-
# == Schema Information
#
# Table name: submissions
#
#  id                                :integer          not null, primary key
#  project_id                        :integer
#  applicant_id                      :integer
#  submission_title                  :string(255)
#  submission_status                 :string(255)
#  is_human_subjects_research        :boolean
#  is_irb_approved                   :boolean
#  irb_study_num                     :string(255)
#  use_nucats_cru                    :boolean
#  nucats_cru_contact_name           :string(255)
#  use_stem_cells                    :boolean
#  use_embryonic_stem_cells          :boolean
#  use_vertebrate_animals            :boolean
#  is_iacuc_approved                 :boolean
#  iacuc_study_num                   :string(255)
#  direct_project_cost               :float
#  is_new                            :boolean
#  use_nmh                           :boolean
#  use_nmff                          :boolean
#  use_va                            :boolean
#  use_ric                           :boolean
#  use_cmh                           :boolean
#  not_new_explanation               :text
#  other_funding_sources             :text
#  is_conflict                       :boolean
#  conflict_explanation              :text
#  effort_approver_ip                :string(255)
#  submission_at                     :datetime
#  completion_at                     :datetime
#  effort_approver_username          :string(255)
#  department_administrator_username :string(255)
#  effort_approval_at                :datetime
#  submission_reviews_count          :integer          default(0)
#  submission_category               :string(255)
#  core_manager_username             :string(255)
#  cost_sharing_amount               :float
#  cost_sharing_organization         :text
#  received_previous_support         :boolean          default(FALSE)
#  previous_support_description      :text
#  committee_review_approval         :boolean          default(FALSE)
#  application_document_id           :integer
#  budget_document_id                :integer
#  abstract                          :text
#  other_support_document_id         :integer
#  document1_id                      :integer
#  document2_id                      :integer
#  document3_id                      :integer
#  document4_id                      :integer
#  applicant_biosketch_document_id   :integer
#  notification_cnt                  :integer          default(0)
#  notification_sent_at              :datetime
#  notification_sent_by_id           :integer
#  notification_sent_to              :string(255)
#  created_id                        :integer
#  created_ip                        :string(255)
#  updated_id                        :integer
#  updated_ip                        :string(255)
#  deleted_at                        :datetime
#  deleted_id                        :integer
#  deleted_ip                        :string(255)
#  created_at                        :datetime         not null
#  updated_at                        :datetime         not null
#  supplemental_document_id          :integer
#  total_amount_requested            :float
#  amount_awarded                    :float
#  type_of_equipment                 :string
#


# Helper module for Submissions model
module SubmissionsHelper
  require "#{Rails.root}/app/helpers/application_helper"
  include ApplicationHelper

  def link_to_key_personnel_documents(key_people, do_lookup = true, include_name = true)
    out = ''
    key_people.each_with_index do |key_user, index|
      title = "Biosketch for #{key_user.name}"
      unless key_user.blank? || key_user.biosketch_document_id.blank?
        out << link_to_file(key_user.biosketch_document_id, title, 'document', title, false, nil, do_lookup)
        out << '<br/> '
      end
    end
    out
  end

  def link_to_project_docs(project)
    %{
      Docs:
      #{link_to_rfa(project)}
      #{link_to_application_documents(project)}
      #{link_to_budget_documents(project)}
    }
  end

  def link_to_rfa(project)
    project.project_url.blank? ? '' : link_to_document(project.project_url_label, project.project_url)
  end

  def link_to_application_documents(project)
    link_to_application_template(project) + link_to_application_info(project)
  end

  def link_to_application_template(project)
    project.application_template_url.blank? ? '' : link_to_document(project.application_template_url_label, project.application_template_url)
  end

  def link_to_application_info(project)
    project.application_info_url.blank? ? '' : ' ' + link_to_document(project.application_info_url_label, project.application_info_url)
  end

  def link_to_budget_documents(project)
    link_to_budget_template + link_to_budget_info(project)
  end

  def link_to_budget_template(project)
    project.budget_template_url.blank? ? '' : link_to_document(project.budget_template_url_label, project.budget_template_url)
  end

  def link_to_budget_info(project)
    project.budget_info_url.blank? ? '' : ' ' + link_to_document(project.budget_info_url_label, project.budget_info_url)
  end

  def link_to_other_support_documents
    %{
      #{link_to('NIH Other Support Template', 'http://grants.nih.gov/grants/funding/phs398/othersupport.doc', title: 'Download NIH Other Support Template', target: '_blank')}
      #{link_to('PHS398 instructions', 'http://grants.nih.gov/grants/funding/phs398/phs398.html', title: 'View PHS398 instructions', target: '_blank')}
     .
   }
  end

  def link_to_nih_biosketch_info
    %{
      Download the NIH Biosketch template as a
      #{link_to('MS Word document', 'http://grants.nih.gov/grants/funding/phs398/biosketch.doc', title: 'NIH Biosketch Template as a MS Word document', target: '_blank')}
     or
      #{link_to('PDF document', 'http://grants.nih.gov/grants/funding/phs398/biosketchsample.pdf', title: 'NIH Biosketch Sample as a PDF', target: '_blank')}
    }
  end

  def link_to_document_template(project, number)
    if project.send("document#{number}_template_url").blank?
      ''
    else
      link_to_document(project.send("document#{number}_name") + ' Template', project.send("document#{number}_template_url"))
    end
  end

  def link_to_document_info(project, number)
    if project.send("document#{number}_info_url").blank?
      ''
    else
      ' ' + link_to_document(project.send("document#{number}_name") + ' Info',
                             project.send("document#{number}_info_url"),
                             project.send("document#{number}_name") + 'Instructions and Information')
    end
  end

  def link_to_document1_template_info(project)
    link_to_document_template(project, 1) + link_to_document_info(project, 1) + '.'
  end

  def link_to_document2_template_info(project)
    link_to_document_template(project, 2) + link_to_document_info(project, 2) + '.'
  end

  def link_to_document3_template_info(project)
    link_to_document_template(project, 3) + link_to_document_info(project, 3) + '.'
  end

  def link_to_document4_template_info(project)
    link_to_document_template(project, 4) + link_to_document_info(project, 4) + '.'
  end

  def link_to_document(link_prefix, path, title = nil)
    title ||= link_prefix
    link_to_download(link_prefix, path, 'document', title)
  end

  def link_to_spreadsheet(link_prefix, path, title = nil)
    title ||= link_prefix
    link_to_download(link_prefix, path, 'spreadsheet', title)
  end

  def link_to_download(link_text, path, file_type = 'document', mouse_over = nil)
    mouse_over ||= link_text
    image_name = determine_image_name(file_type)
    # link_to(image_tag('add.png', width: '16px', height: '16px') + ' New competition', new_project_path)
    link_to(image_tag(image_name, width: "16px", height: "16px" ) + ' ' + link_text, path, title: 'View ' + mouse_over, target: '_blank')
  end

  def determine_image_name(file_type)
    case file_type
    when :document, 'document', 'txt'
      'hyperlink_blue.png'
    when :spreadsheet, 'spreadsheet'
      'page_excel.png'
    when :pdf, 'pdf'
      'page_white_acrobat.png'
    else
      'documenticon.gif'
    end
  end

  def list_key_personnel_documents_as_array(key_people)
    out = []
    key_people.each_with_index do |key_user, index|
      out << "Biosketch for #{key_user.name} : " + format_document_info(key_user.biosketch) unless key_user.biosketch_document_id.blank?
    end
    out
  end

  def list_submission_files_as_array(submission)
    out = []
    out << "PI&nbsp;biosketch: #{format_document_info(submission.applicant_biosketch_document)}" unless submission.applicant_biosketch_document_id.blank?
    out << "Application&nbsp;doc: #{format_document_info(submission.application_document)}" unless submission.application_document_id.blank?
    out << "Budget&nbsp;doc: #{format_document_info(submission.budget_document)}" unless submission.budget_document_id.blank?
    out << "Other&nbsp;Support&nbsp;doc: #{format_document_info(submission.other_support_document)}" unless submission.other_support_document_id.blank?
    out << "#{submission.project.document1_name} doc: " + format_document_info(submission.document1) unless !submission.project.show_document1 || submission.document1_id.blank?
    out << "#{submission.project.document2_name} doc: " + format_document_info(submission.document2) unless !submission.project.show_document2 || submission.document2_id.blank?
    out << "#{submission.project.document3_name} doc: " + format_document_info(submission.document3) unless !submission.project.show_document3 || submission.document3_id.blank?
    out << "#{submission.project.document4_name} doc: " + format_document_info(submission.document4) unless !submission.project.show_document4 || submission.document4_id.blank?
    out << "#{submission.project.supplemental_document_name}: " + format_document_info(submission.supplemental_document) unless submission.supplemental_document_id.blank?
    out << list_key_personnel_documents_as_array(submission.key_people)
    out.flatten.compact
  end

  def link_to_submission_files_as_array(submission, project, lookup = true)
    [
      link_to_file(submission.applicant_biosketch_document_id,
                   'PI&nbsp;biosketch',
                   'document',
                   'PI&nbsp;biosketch ',
                   project.show_manage_biosketches,
                   edit_documents_submission_path(submission.id),
                   lookup),
      link_to_file(submission.application_document_id,
                   'Application',
                   'document',
                   nil,
                   true,
                   edit_documents_submission_path(submission.id),
                   lookup),
      link_to_file(submission.budget_document_id,
                   'Budget',
                   'spreadsheet',
                   'Budget ',
                   project.show_budget_form,
                   edit_documents_submission_path(submission.id),
                   lookup),
      link_to_file(submission.other_support_document_id,
                   'Other&nbsp;Support',
                   'document',
                   'Other&nbsp;Support',
                   project.show_manage_other_support,
                   edit_documents_submission_path(submission.id),
                   lookup),
      link_to_file(submission.document1_id,
                   'Doc&nbsp;1',
                   'document',
                   project.document1_name,
                   project.show_document1,
                   edit_documents_submission_path(submission.id),
                   lookup),
      link_to_file(submission.document2_id,
                   'Doc&nbsp;2',
                   'document',
                   project.document2_name,
                   project.show_document2,
                   edit_documents_submission_path(submission.id),
                   lookup),
      link_to_file(submission.document3_id,
                   'Doc&nbsp;3',
                   'document',
                   project.document3_name,
                   project.show_document3,
                   edit_documents_submission_path(submission.id),
                   lookup),
      link_to_file(submission.document4_id,
                   'Doc&nbsp;4',
                   'document',
                   project.document4_name,
                   project.show_document4,
                   edit_documents_submission_path(submission.id),
                   lookup),
      link_to_file(submission.supplemental_document_id,
                   project.supplemental_document_name,
                   'document',
                   nil,
                   true,
                   edit_documents_submission_path(submission.id),
                   lookup),
      link_to_key_personnel_documents(submission.key_people, true, false)
    ].compact
  end

  def link_to_submission_files(submission, project, lookup = true)
    link_to_submission_files_as_array(submission, project, lookup)
  end
end
