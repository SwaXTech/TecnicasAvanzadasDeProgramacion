describe "Where tests" do
  let(:dummy_instance) { ClassWithMethods.new }
  let(:blah_regex) { /blah/ }

  subject do
    Aspects.on(ClassWithMethods, dummy_instance) {}
  end

  it "get methods should return instance methods" do
    subject
    expect(ClassWithMethods.method(:get_methods).call).to include(:method1, :method2)
  end

  context "Name condition" do
    it "should not return any method when a non matching regex is passed" do
      subject
      expect(ClassWithMethods.where with_name(blah_regex)).to be_empty
    end

    it "should return method1 on name condition" do
      subject
      expect(ClassWithMethods.where with_name(/method1/)).to include(:method1)
    end

    it "object should return saludar on name condition" do
      subject
      dummy_instance.define_singleton_method(:saludar) { "hola" }
      expect(dummy_instance.where with_name(/saludar/)).to include(:saludar)
    end
  
    it "should verify multiple name conditions" do
      subject
      expect(ClassWithMethods.where with_name(/^m.*/), with_name(/thod[1-9]$/)).to include(:method2, :method1)
    end

    it "should raise error when a Regexp is not pass as an argument" do
      subject
      expect { ClassWithMethods.where with_name("Method1") }.to raise_error(ArgumentError)
    end
  end

  context "Parameters condition" do
    let(:number_regex) { /p[1-9]/ }

    it "should not return any method another arity number is passed" do
      subject
      expect(ClassWithMethods.where has_parameters(50)).to be_empty
    end

    it "should verify a certain amount of parameters" do
      subject
      expect(ClassWithMethods.where has_parameters(3)).to include(:method1)
    end

    it "should not return method2 when querying for 3 params" do
      subject
      expect(ClassWithMethods.where has_parameters(3)).not_to include(:method2)
    end

    it "should return method1 when querying for 3 params that starts with p and ends with number" do
      subject
      expect(ClassWithMethods.where has_parameters(3, number_regex)).to include(:method1)
    end

    it "should not return method2 and mehthod3 when querying for 3 params that starts with p and ends with number" do
      subject
      expect(ClassWithMethods.where has_parameters(3, number_regex)).not_to include(:method2)
      expect(ClassWithMethods.where has_parameters(3, number_regex)).not_to include(:method3)
    end

    it "should return method1 when querying for 3 mandatory params" do
      subject
      expect(ClassWithMethods.where has_parameters(3, :mandatory)).to include(:method1)
    end

    it "should return method2 when querying for 2 optional params" do
      subject
      expect(ClassWithMethods.where has_parameters(2, :optional)).to include(:method2)
    end

    it "should not include any method when querying for 5 mandatory params" do
      subject
      expect(ClassWithMethods.where has_parameters(5, :mandatory)).to be_empty
    end

    it "should include method3 when querying for 4 params that matches with [a-z][1-9]" do
      subject
      expect(ClassWithMethods.where has_parameters(4, /[a-z][1-9]/)).to include(:method3)
    end

    it "should return method4 when querying for no params" do
      subject
      expect(ClassWithMethods.where has_parameters(0)).to include(:method4)
    end

    it "should return method1 and method4 when querying for 0 optional params" do
      subject
      expect(ClassWithMethods.where has_parameters(0, :optional)).to include(:method1)
      expect(ClassWithMethods.where has_parameters(0, :optional)).to include(:method4)
    end

    it "should return method5 and method4 when querying for 0 mandatory params" do
      subject
      expect(ClassWithMethods.where has_parameters(0, :mandatory)).to include(:method5)
      expect(ClassWithMethods.where has_parameters(0, :mandatory)).to include(:method4)
    end

    it "should raise error when you pass as a second parameter a wrong type" do
      subject
      expect { ClassWithMethods.where has_parameters(2, "Not valid string")  }.to raise_error(ArgumentError)
    end

    it "should raise error when you pass as a second parameter a wrong symbol" do
      subject
      expect { ClassWithMethods.where has_parameters(2, :invalid)  }.to raise_error(ArgumentError)
    end

    it "should raise error when you pass as a first parameter a wrong type" do
      subject
      expect { ClassWithMethods.where has_parameters("blah", :optional)  }.to raise_error(ArgumentError)
    end

    it "should raise error when you pass as a first parameter a wrong type 2" do
      subject
      expect { ClassWithMethods.where has_parameters(:symbol)  }.to raise_error(ArgumentError)
    end
  end

  context "Negate condition" do
    it "should not return method1 when querying for NOT 3 params" do
      subject
      expect(ClassWithMethods.where neg(has_parameters(3))).not_to include(:method1)
    end

    it "should not return method1 when querying for NOT /method1/" do
      subject
      expect(ClassWithMethods.where neg(with_name(/method1/))).not_to include(:method1)
    end

    it "should return all methods except method4 when querying for NOT /.*4/" do
      subject
      expect(ClassWithMethods.where neg(with_name(/.*4/))).to include(:method1, :method2, :method3, :method5)
    end

    it "should return all methods except method1 when querying for NOT 3 params" do
      subject
      expect(ClassWithMethods.where neg(has_parameters(3))).to include(:method2, :method3, :method4, :method5)
    end

    it "should return all methods except method4 when querying for NOT 0 params" do
      subject
      expect(ClassWithMethods.where neg(has_parameters(0))).to include(:method1, :method2, :method3, :method5)
    end

    it "should return all methos except method3 and method5 when querying for NOT 1 optional param" do
      subject
      expect(ClassWithMethods.where neg(has_parameters(1, :optional))).to include(:method1, :method2, :method4)
    end

    it "should return method all methods excep method2 when querying for NOT 4 mandatory params" do
      subject
      expect(ClassWithMethods.where neg(has_parameters(4, :mandatory))).to include(:method1, :method3, :method4, :method5)
    end

    it "should raise error when a condition is not pass as an argument" do
      subject
      expect {ClassWithMethods.where neg("Not a condition") }.to raise_error(ArgumentError)
    end
  end

  context 'Integration where tests' do

    it "should return method1 on parameters and name condition" do
      Aspects.on ClassWithMethods do
        where with_name(/method1/), has_parameters(3)
      end

      expect(ClassWithMethods.instance_variable_get :@__temp_filtered_methods__).to include(:method1)
    end

    it "should not return method2, method3, method4 on parameters and name condition" do
      Aspects.on ClassWithMethods do
        where with_name(/method1/), has_parameters(3)
      end

      expect(ClassWithMethods.instance_variable_get :@__temp_filtered_methods__).not_to include(:method2)
      expect(ClassWithMethods.instance_variable_get :@__temp_filtered_methods__).not_to include(:method3)
      expect(ClassWithMethods.instance_variable_get :@__temp_filtered_methods__).not_to include(:method4)
    end


    it "should return method2 on parameters and name condition" do
      Aspects.on ClassWithMethods do
        where with_name(/method2/), has_parameters(5)
      end

      expect(ClassWithMethods.instance_variable_get :@__temp_filtered_methods__).to include(:method2)
    end

    it "should not return method1, method3, method4 on parameters and name condition" do
      Aspects.on ClassWithMethods do
        where with_name(/method2/), has_parameters(5)
      end

      expect(ClassWithMethods.instance_variable_get :@__temp_filtered_methods__).not_to include(:method1)
      expect(ClassWithMethods.instance_variable_get :@__temp_filtered_methods__).not_to include(:method3)
      expect(ClassWithMethods.instance_variable_get :@__temp_filtered_methods__).not_to include(:method4)
    end

    it "should not return any method with parameters condition" do
      Aspects.on ClassWithMethods do
        where has_parameters(7)
      end

      expect(ClassWithMethods.instance_variable_get :@__temp_filtered_methods__).to be_empty
    end

    it "should return all methods with name condition /.*/" do
      Aspects.on ClassWithMethods do
        where with_name(/.*/)
      end

      expect(ClassWithMethods.instance_variable_get :@__temp_filtered_methods__).to include(:method1, :method2, :method3, :method4, :method5)
    end

    it "should not return any methods when negating name condition /.*/" do
      Aspects.on ClassWithMethods do
        where neg(with_name(/.*/))
      end

      expect(ClassWithMethods.instance_variable_get :@__temp_filtered_methods__).to be_empty
    end

    it "should return method5 when querying for one optional parameter" do
      Aspects.on ClassWithMethods do
        where has_parameters(1, :optional)
      end

      expect(ClassWithMethods.instance_variable_get :@__temp_filtered_methods__).to include(:method5)
    end

    it "should return all methods when negatin a high value of parameters" do
      Aspects.on ClassWithMethods do
        where neg(has_parameters(7))
      end

      expect(ClassWithMethods.instance_variable_get :@__temp_filtered_methods__).to include(:method1, :method2, :method3, :method4, :method5)
    end
  end
end

