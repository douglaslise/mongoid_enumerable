RSpec.describe MongoidEnumerable do
  let(:model) { klass.new }

  before { allow(model).to receive(:save).and_return(true) }

  context "with prefix value" do
    let(:klass) do
      Class.new do
        include MongoidEnumerable
        include Mongoid::Document
        enumerable :status, %i(completed running failed waiting), default: :waiting, prefix: "st_"
      end
    end

    context "st_completed!" do
      it "updates value with \"completed\"" do
        expect(model).to receive(:update!).with("status" => "completed")
        model.st_completed!
      end
    end

    context "completed?" do
      context "when completed" do
        before { model.st_completed! }
        it { expect(model.st_completed?).to be_truthy }
      end

      context "when not completed" do
        before { model.st_waiting! }
        it { expect(model.st_completed?).to be_falsey }
      end
    end
  end

  context "field as string" do
    let(:klass) do
      Class.new do
        include MongoidEnumerable
        include Mongoid::Document
        enumerable "status", %i(completed running failed waiting), default: :waiting, prefix: "st_"
      end
    end

    it "define methods as well as a symbol" do
      expect(model).to respond_to(:st_completed?)
    end
  end

  context "without prefix value" do
    let(:klass) do
      Class.new do
        include MongoidEnumerable
        include Mongoid::Document
        enumerable :status, %i(completed running failed waiting), default: :waiting, prefix: "st_"
      end
    end

    context "completed!" do
      it "updates value with \"completed\"" do
        expect(model).to receive(:update!).with("status" => "completed")
        model.st_completed!
      end
    end

    context "completed?" do
      context "when completed" do
        before { model.st_completed! }
        it { expect(model.st_completed?).to be_truthy }
      end

      context "when not completed" do
        before { model.st_waiting! }
        it { expect(model.st_completed?).to be_falsey }
      end
    end
  end

  context "default value" do
    context "when defined" do
      let(:klass) do
        Class.new do
          include MongoidEnumerable
          include Mongoid::Document
          enumerable :status, %i(completed running failed waiting), default: "waiting"
        end
      end

      it "starts with the defined status as default" do
        expect(model).to_not be_completed
        expect(model).to be_waiting
      end
    end

    context "when not defined" do
      let(:klass) do
        Class.new do
          include MongoidEnumerable
          include Mongoid::Document
          enumerable :status, %i(completed running failed waiting)
        end
      end

      it "starts with first status as default" do
        expect(model).to be_completed
      end
    end
  end

  context "scopes" do
    let(:klass) do
      Class.new do
        include MongoidEnumerable
        include Mongoid::Document
        enumerable :status, %i(completed running failed waiting)
      end
    end

    context "define scopes for all values" do
      context "completed" do
        it {expect(klass).to respond_to(:completed)}
        it "is a scope" do
          expect(klass.completed).to be_a(Mongoid::Criteria)
        end
        it "with selector" do
          expect(klass.completed.selector).to eq({"status" => "completed"})
        end
      end
    end
  end
end
