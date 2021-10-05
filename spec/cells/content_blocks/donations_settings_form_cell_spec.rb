# frozen_string_literal: true

require "spec_helper"

module Decidim::Donations
  describe ContentBlocks::DonationsSettingsFormCell, type: :cell do
    let(:cell) { described_class.new }

    describe "#form" do
      subject { cell.form }

      it { is_expected.to be_nil }
    end

    describe "#i18n_scope" do
      subject { cell.i18n_scope }

      it { is_expected.to eq("decidim.donations.content_blocks.donations_settings_form") }
    end
  end
end
