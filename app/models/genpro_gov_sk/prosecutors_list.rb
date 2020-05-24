module GenproGovSk
  class ProsecutorsList < ApplicationRecord
    validates :data, presence: true
    validates :file, presence: true
    validates :digest, presence: true, uniqueness: true

    def self.import_from(data:, file:)
      digest = Digest::MD5.hexdigest(file)

      return if exists?(digest: digest)

      list = create!(digest: digest, file: file, data: data)

      data.each do |value|
        reconciler = ProsecutorReconciler.new(data, list)

        reconciler.reconcile!
      end
    end
  end
end
