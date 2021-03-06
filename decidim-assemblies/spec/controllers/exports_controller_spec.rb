# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Assemblies
    module Admin
      describe ExportsController, type: :controller do
        routes { Decidim::Assemblies::AdminEngine.routes }

        let!(:organization) { create(:organization) }
        let!(:assembly) { create :assembly, organization: organization }
        let!(:user) { create(:user, :admin, :confirmed, organization: organization) }
        let!(:feature) { create(:feature, participatory_space: assembly, manifest_name: "dummy") }

        let(:params) do
          {
            id: "dummies",
            feature_id: feature.id,
            assembly_slug: assembly.slug
          }
        end

        before do
          request.env["decidim.current_organization"] = organization
          sign_in user, scope: :user
        end

        describe "POST create" do
          context "when a format is provided" do
            it "enqueues a job with the provided format" do
              params[:format] = "csv"

              expect(ExportJob).to receive(:perform_later)
                .with(user, feature, "dummies", "csv")

              post(:create, params: params)
            end
          end

          context "when a format is not provided" do
            it "enqueues a job with the default format" do
              expect(ExportJob).to receive(:perform_later)
                .with(user, feature, "dummies", "json")

              post(:create, params: params)
            end
          end
        end
      end
    end
  end
end
