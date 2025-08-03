# frozen_string_literal: true

require "spec_helper"

RSpec.describe Signetron::Models::Document do
  let(:valid_pdf_base64) do
    content = "%PDF-1.4\n1 0 obj\n<<\n/Type /Catalog\n/Pages 2 0 R\n>>\nendobj\n" + "A" * 1200
    Base64.strict_encode64(content)
  end

  let(:valid_png_base64) do
    content = "\x89PNG\r\n\x1A\n" + "A" * 1200
    Base64.strict_encode64(content)
  end

  let(:valid_pdf_data_uri) { "data:application/pdf;base64,#{valid_pdf_base64}" }

  let(:valid_png_data_uri) { "data:image/png;base64,#{valid_png_base64}" }

  describe "#initialize" do
    context "with valid attributes" do
      it "creates a document with filename and content" do
        document = described_class.new(
          filename: "test.pdf",
          content_base64: valid_pdf_base64,
        )

        expect(document.filename).to eq("test.pdf")
        expect(document.content_base64).to eq(valid_pdf_base64)
      end
    end

    context "with invalid attributes" do
      it "raises ValidationError when both fields are missing" do
        expect {
          described_class.new
        }.to raise_error(Signetron::Models::ValidationError)
      end

      it "raises ValidationError when filename is missing" do
        expect {
          described_class.new(content_base64: valid_pdf_base64)
        }.to raise_error(Signetron::Models::ValidationError) do |error|
          expect(error.message).to include("filename")
        end
      end

      it "raises ValidationError when content is missing" do
        expect {
          described_class.new(filename: "test.pdf")
        }.to raise_error(Signetron::Models::ValidationError) do |error|
          expect(error.message).to include("content_base64")
        end
      end
    end
  end

  describe "#filename" do
    it "returns the filename from attributes" do
      document = described_class.new(
        filename: "contract.pdf",
        content_base64: valid_pdf_base64,
      )
      expect(document.filename).to eq("contract.pdf")
    end

    it "returns nil when no filename is set but content is valid" do
      expect {
        described_class.new(content_base64: valid_pdf_base64)
      }.to raise_error(Signetron::Models::ValidationError)
    end
  end

  describe "#content_base64" do
    it "returns the base64 content from attributes" do
      document = described_class.new(
        filename: "test.pdf",
        content_base64: valid_pdf_base64,
      )
      expect(document.content_base64).to eq(valid_pdf_base64)
    end

    it "raises error when no content is set" do
      expect {
        described_class.new(filename: "test.pdf")
      }.to raise_error(Signetron::Models::ValidationError)
    end
  end

  describe "#valid?" do
    context "with valid document data" do
      it "returns true for valid PDF document" do
        document = described_class.new(
          filename: "contract.pdf",
          content_base64: valid_pdf_base64,
        )

        expect(document).to be_valid
      end

      it "returns true for valid PNG document" do
        document = described_class.new(
          filename: "image.png",
          content_base64: valid_png_base64,
        )

        expect(document).to be_valid
      end

      it "returns true for all supported file formats" do
        formats = %w[pdf doc docx txt jpg jpeg png]

        formats.each do |format|
          document = described_class.new(
            filename: "test.#{format}",
            content_base64: valid_pdf_base64,
          )

          expect(document).to be_valid, "Expected #{format} format to be valid"
        end
      end
    end

    context "with invalid data that would raise on initialize" do
      it "raises ValidationError for empty filename" do
        expect {
          described_class.new(
            filename: "",
            content_base64: valid_pdf_base64,
          )
        }.to raise_error(Signetron::Models::ValidationError)
      end

      it "raises ValidationError for filename with invalid characters" do
        expect {
          described_class.new(
            filename: "file<test>.pdf",
            content_base64: valid_pdf_base64,
          )
        }.to raise_error(Signetron::Models::ValidationError)
      end

      it "raises ValidationError for filename without extension" do
        expect {
          described_class.new(
            filename: "document",
            content_base64: valid_pdf_base64,
          )
        }.to raise_error(Signetron::Models::ValidationError)
      end

      it "raises ValidationError for unsupported file extension" do
        expect {
          described_class.new(
            filename: "malware.exe",
            content_base64: valid_pdf_base64,
          )
        }.to raise_error(Signetron::Models::ValidationError)
      end

      it "raises ValidationError for empty content" do
        expect {
          described_class.new(
            filename: "test.pdf",
            content_base64: "",
          )
        }.to raise_error(Signetron::Models::ValidationError)
      end

      it "raises ValidationError for invalid base64 content" do
        expect {
          described_class.new(
            filename: "test.pdf",
            content_base64: "invalid_base64!",
          )
        }.to raise_error(Signetron::Models::ValidationError)
      end

      it "raises ValidationError when filename is missing" do
        expect {
          described_class.new(content_base64: valid_pdf_base64)
        }.to raise_error(Signetron::Models::ValidationError)
      end

      it "raises ValidationError when content_base64 is missing" do
        expect {
          described_class.new(filename: "test.pdf")
        }.to raise_error(Signetron::Models::ValidationError)
      end
    end
  end

  describe "#to_json_api" do
    context "with valid document" do
      it "returns JSON API formatted data" do
        document = described_class.new(
          filename: "contract.pdf",
          content_base64: valid_pdf_base64,
        )

        result = document.to_json_api

        expect(result).to eq({
          data: {
            type: "documents",
            attributes: {
              filename: "contract.pdf",
              content_base64: valid_pdf_base64,
            },
          },
        })
      end
    end

    context "with invalid document" do
      it "raises ValidationError for already invalid document in initialize" do
        expect {
          document = described_class.new(
            filename: "",
            content_base64: "",
          )
          document.to_json_api
        }.to raise_error(Signetron::Models::ValidationError)
      end
    end
  end

  describe "validator integration" do
    it "uses DocumentValidator internally" do
      document = described_class.new(
        filename: "test.pdf",
        content_base64: valid_pdf_base64,
      )

      validator = document.send(:validator)
      expect(validator).to be_a(Signetron::Validators::DocumentValidator)
    end

    it "can test validator directly for invalid cases" do
      validator = Signetron::Validators::DocumentValidator.new

      result = validator.call(
        filename: "",
        content_base64: "invalid!",
      )

      expect(result.success?).to be false
      expect(result.errors[:filename]).not_to be_empty
      expect(result.errors[:content_base64]).not_to be_empty
    end
  end
end
