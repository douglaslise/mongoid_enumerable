# frozen_string_literal: true

RSpec.describe MongoidEnumerable do
  let(:model) { klass.new }

  before { allow(model).to receive(:save).and_return(true) }

  context "with prefix value" do
    let(:klass) do
      Class.new do
        include MongoidEnumerable
        include Mongoid::Document
        enumerable :status, %i[completed running failed waiting], default: :waiting, prefix: "st_"
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

    it "returns all possible values" do
      expect(klass.all_status).to match_array(%w[completed running failed waiting])
    end
  end

  context "field as string" do
    let(:klass) do
      Class.new do
        include MongoidEnumerable
        include Mongoid::Document
        enumerable "status", %i[completed running failed waiting], default: :waiting, prefix: "st_"
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
        enumerable :status, %i[completed running failed waiting], default: :waiting
      end
    end

    context "completed!" do
      it "updates value with \"completed\"" do
        expect(model).to receive(:update!).with("status" => "completed")
        model.completed!
      end
    end

    context "completed?" do
      context "when completed" do
        before { model.completed! }
        it { expect(model.completed?).to be_truthy }
      end

      context "when not completed" do
        before { model.waiting! }
        it { expect(model.completed?).to be_falsey }
      end

      context "when there are other class with the same enumerable value" do
        let(:another_klass) do
          Class.new do
            include MongoidEnumerable
            include Mongoid::Document
            enumerable :other_field, %i[completed dead]
          end
        end

        let(:another_model) { another_klass.new(other_field: "completed") }
        before { another_model }

        it "cannot have running method" do
          expect(another_model).to respond_to(:dead?)
          expect(model).to_not respond_to(:dead?)
        end

        context "when completed" do
          before { model.completed! }
          it { expect(model.completed?).to be_truthy }
        end

        context "when not completed" do
          before { model.waiting! }
          it { expect(model.completed?).to be_falsey }
        end
      end
    end
  end

  context "default value" do
    context "when defined" do
      let(:klass) do
        Class.new do
          include MongoidEnumerable
          include Mongoid::Document
          enumerable :status, %i[completed running failed waiting], default: "waiting"
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
          enumerable :status, %i[completed running failed waiting]
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
        enumerable :status, %i[completed running failed waiting], prefix: "build_"
      end
    end

    context "define scopes for all values" do
      context "completed" do
        it { expect(klass).to respond_to(:build_completed) }
        it "is a scope" do
          expect(klass.build_completed).to be_a(Mongoid::Criteria)
        end
        it "with selector" do
          expect(klass.build_completed.selector).to eq({ "status" => "completed" })
        end
      end
      context "waiting" do
        it { expect(klass).to respond_to(:build_waiting) }
        it "is a scope" do
          expect(klass.build_waiting).to be_a(Mongoid::Criteria)
        end
        it "with selector" do
          expect(klass.build_waiting.selector).to eq({ "status" => "waiting" })
        end
      end
      context "failed" do
        it { expect(klass).to respond_to(:build_failed) }
        it "is a scope" do
          expect(klass.build_failed).to be_a(Mongoid::Criteria)
        end
        it "with selector" do
          expect(klass.build_failed.selector).to eq({ "status" => "failed" })
        end
      end
      context "running" do
        it { expect(klass).to respond_to(:build_running) }
        it "is a scope" do
          expect(klass.build_running).to be_a(Mongoid::Criteria)
        end
        it "with selector" do
          expect(klass.build_running.selector).to eq({ "status" => "running" })
        end
      end
    end

    context "does not define scopes in another classes" do
      let(:another_klass) do
        Class.new do
          include MongoidEnumerable
          include Mongoid::Document
          enumerable :status, %i[completed running failed waiting]
        end
      end

      it { expect(another_klass).to_not respond_to(:st_completed) }
    end

    context "when declared for a superclass" do
      let(:super_class) do
        Class.new do
          include MongoidEnumerable
          include Mongoid::Document
          enumerable :status, %i[completed running failed waiting]
        end
      end

      let(:sub_class) { Class.new(super_class) }

      it "preserves subclass in mongoid criterias" do
        expect(sub_class.completed.klass).to equal(sub_class)
      end
    end
  end

  context "callbacks" do
    context "before change" do
      context "when method is correctly defined" do
        let(:klass) do
          Class.new do
            include MongoidEnumerable
            include Mongoid::Document
            enumerable :status, %i[completed running failed waiting], before_change: :status_will_change

            def status_will_change(old_value, new_value); end
          end
        end

        it "calls before_change callback before update" do
          expect(model).to receive(:status_will_change).with("completed", "running")
          model.running!
        end

        context "and there is another class with the same callback name" do
          let(:another_klass) do
            Class.new do
              include MongoidEnumerable
              include Mongoid::Document
              enumerable :status, %i[completed dead], before_change: :status_will_change
            end
          end
          let!(:another_model) { another_klass }

          it "the same model callback is called" do
            expect(model).to receive(:status_will_change).with("completed", "running")
            model.running!
          end

          it "the other model callback is called" do
            expect(another_model).to_not receive(:status_will_change) # .with("completed", "running")
            model.running!
          end
        end
      end

      context "when method have wrong parameter number" do
        let(:klass) do
          Class.new do
            include MongoidEnumerable
            include Mongoid::Document
            enumerable :status, %i[completed running failed waiting], before_change: :status_will_change

            def status_will_change(old_value); end
          end
        end

        it "raises and error" do
          expect { model.running! }.to raise_error(
            "Method status_will_change must receive two parameters: old_value and new_value"
          )
        end
      end
    end

    context "after change" do
      context "when method is correctly defined" do
        let(:klass) do
          Class.new do
            include MongoidEnumerable
            include Mongoid::Document
            enumerable :status,
                       %i[completed running failed waiting],
                       after_change: :status_changed,
                       before_change: :status_will_change

            def status_will_change(_old_value, new_value)
              # Avoiding change status to failed
              new_value != "failed"
            end

            def status_changed(old_value, new_value); end
          end
        end

        context "and before callback allows the modification" do
          it "calls after_change callback before update" do
            expect(model).to receive(:status_changed).with("completed", "running")
            model.running!
          end
        end

        context "and before callback does not allow the modification" do
          it "calls after_change callback before update" do
            expect(model).to_not receive(:status_changed)
            model.failed!
          end
        end
      end

      context "when method has wrong parameter number" do
        let(:klass) do
          Class.new do
            include Mongoid::Document
            include MongoidEnumerable
            enumerable :status, %i[completed running failed waiting], after_change: :status_changed

            def status_changed(old_value); end
          end
        end

        it "raises an error" do
          expect { model.running! }.to raise_error(
            "Method status_changed must receive two parameters: old_value and new_value"
          )
        end
      end
    end
  end
end
