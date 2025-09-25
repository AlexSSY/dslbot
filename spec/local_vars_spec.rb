require_relative "../state_group"

RSpec.describe LocalVars do
  describe "#let" do
    it "creates a new variable" do
      local_vars = LocalVars.new
      local_vars.let(:foo, "bar")
      expect(local_vars.instance_variable_get("@foo")).to eq "bar"
    end
  end

  describe "#get" do
    it "get an existing variable" do
      local_vars = LocalVars.new
      local_vars.instance_variable_set "@foo", "bar"
      expect(local_vars.get(:foo)).to eq "bar"
    end
  end

  describe "#set" do
    it "changes existing variable value" do
      local_vars = LocalVars.new
      local_vars.instance_variable_set "@foo", "bar"
      local_vars.set(:foo) { |foo| "foo_" + foo }
      expect(local_vars.get(:foo)).to eq "foo_bar"
    end
  end
end