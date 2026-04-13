class SearchLog < ApplicationRecord
  KINDS = %w[text tag year voice].freeze

  validates :kind, inclusion: { in: KINDS }
end
