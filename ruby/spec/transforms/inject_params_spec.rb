describe "Transforms" do
  before(:each) do
    class Saludador
  
      def saludar(nombre1, nombre2, nombre3)
        "Hola #{nombre1}, #{nombre2}, #{nombre3}"
      end
  
      def despedir(nombre1 = "Carlos", nombre2 = "Pedro", nombre3)
        "Adios #{nombre1}, #{nombre2}, #{nombre3}"
      end
  
      def hola_y_chau(nombre1: "Carlos", nombre2: "Pedro")
        "Hola #{nombre1}, Adiós #{nombre2}"
      end
  
      def hola_a_todos(*nombres)
        "Hola #{nombres.join(', ')}"
      end
    
    end
  end

  after(:each) do
    Object.send(:remove_const, :Saludador)
  end

  context "injecting params on class" do
    it "should say 'Hola' to carlos as first parameter" do

      Aspects.on(Saludador) do
        transform([:saludar]){
          inject(nombre1: "Carlos")
        }
      end
  
      saludador = Saludador.new
  
      expect(saludador.saludar("Pepe", "Roberto", "Pablo")).to eq("Hola Carlos, Roberto, Pablo")
      
    end
  
    it "should say 'Hola' to carlos as second param" do
    
      Aspects.on(Saludador) do
        transform([:saludar]){
          inject(nombre2: "Carlos")
        }
      end
  
      saludador = Saludador.new
  
      expect(saludador.saludar("Pepe", "Roberto", "Pablo")).to eq("Hola Pepe, Carlos, Pablo")
      
    
    end
  
    it "should say 'Hola' to carlos as third param" do
  
      Aspects.on(Saludador) do
        transform([:saludar]){
          inject(nombre3: "Carlos")
        }
      end
  
      saludador = Saludador.new
  
      expect(saludador.saludar("Pepe", "Roberto", "Pablo")).to eq("Hola Pepe, Roberto, Carlos")
      
    end
  
    it "should say 'Hola' to carlos as third param but passing 2 params" do
  
      Aspects.on(Saludador) do
        transform([:saludar]){
          inject(nombre3: "Carlos")
        }
      end
  
      saludador = Saludador.new
  
      expect(saludador.saludar("Pepe", "Roberto")).to eq("Hola Pepe, Roberto, Carlos")
      
    end
  
    it "should say 'Hola' to carlos and pepe as first and second param" do
      
      Aspects.on(Saludador) do
        transform([:saludar]){
          inject(nombre1: "Carlos", nombre2: "Pepe")
        }
      end
  
      saludador = Saludador.new
  
      expect(saludador.saludar("Juan","Peter","Roberto")).to eq("Hola Carlos, Pepe, Roberto")
      
    end
  
    it "should say 'Hola' to carlos and pepe as second and third param" do
        Aspects.on(Saludador) do
          transform([:saludar]){
            inject(nombre2: "Carlos", nombre3: "Pepe")
          }
        end
    
        saludador = Saludador.new
    
        expect(saludador.saludar("Juan","Peter","Roberto")).to eq("Hola Juan, Carlos, Pepe")
        
    end
  
    it "should say 'Hola' to carlos and pepe as second and third param but passing only 1 param" do
      
      Aspects.on(Saludador) do
        transform([:saludar]){
          inject(nombre2: "Carlos", nombre3: "Pepe")
        }
      end
    
      saludador = Saludador.new
    
      expect(saludador.saludar("Juan")).to eq("Hola Juan, Carlos, Pepe")
      
    end
  
    it "should say 'Hola' to Carlos, Pepe, and Pablo without passing any param" do
      
      Aspects.on(Saludador) do
        transform([:saludar]){
          inject(nombre1: "Carlos", nombre2: "Pepe", nombre3: "Pablo")
        }
      end
    
      saludador = Saludador.new
    
      expect(saludador.saludar).to eq("Hola Carlos, Pepe, Pablo")
      
    end
  
    it "should say 'Hola' to Carlos, Pepe, and Pablo passing three params" do
  
      Aspects.on(Saludador) do
        transform([:saludar]){
          inject(nombre1: "Carlos", nombre2: "Pepe", nombre3: "Pablo")
        }
      end
    
      saludador = Saludador.new
    
      expect(saludador.saludar("Juan","Peter","Roberto")).to eq("Hola Carlos, Pepe, Pablo")
      
    end


    it "should say 'Adios' to Roberto, Pedro and Peter" do
        
        Aspects.on(Saludador) do
          transform([:despedir]){
            inject(nombre1: "Roberto")
          }
        end
      
        saludador = Saludador.new
      
        expect(saludador.despedir(nombre1 = "Raul", nombre2 = "María", nombre3 = "Peter")).to eq("Adios Roberto, María, Peter")
    end

    it "should say 'Adios' to Roberto, Pedro and Peter passing only one param" do
        Aspects.on(Saludador) do
          transform([:despedir]){
            inject(nombre3: "Roberto")
          }
        end
      
        saludador = Saludador.new
      
        expect(saludador.despedir("Raul", "Pablo")).to eq("Adios Raul, Pablo, Roberto")
    end

    it "should say 'Adios' to Roberto, Raul and María when injectin 2 optional parameters" do
      Aspects.on(Saludador) do
        transform([:despedir]){
          inject(nombre1: "Roberto", nombre2: "Raul")
        }
      end
    
      saludador = Saludador.new
    
      expect(saludador.despedir("Raul", "Pablo", "María")).to eq("Adios Roberto, Raul, María")
    end

    xit "should say 'Hola' and 'Adios' to Roberto and María when injecting named parameters" do
      
      Aspects.on(Saludador) do
        transform([:hola_y_chau]){
          inject(nombre1: "Roberto")
        }
      end
    
      saludador = Saludador.new
    
      expect(saludador.hola_y_chau(nombre1: "Raul", nombre2: "María")).to eq("Hola Roberto, Adiós María")
    end

    it "should say 'Hola' to Roberto only" do
      
      Aspects.on(Saludador) do
        transform([:hola_a_todos]){
          inject(nombres: ["Roberto"])
        }
      end
    
      saludador = Saludador.new
    
      expect(saludador.hola_a_todos("Raul", "Maria", "Pedro")).to eq("Hola Roberto")
    end
  end


  context "injecting params on object" do

    it "should not affect another instance of the same class" do
      
      saludador = Saludador.new
      saludador2 = Saludador.new

      Aspects.on(saludador) do
        transform([:saludar]){
          inject(nombre1: "Carlos")
        }
      end
    
      saludador3 = Saludador.new
      
      expect(saludador.saludar("Juan","Peter","Roberto")).to eq("Hola Carlos, Peter, Roberto")
      expect(saludador2.saludar("Juan","Peter","Roberto")).to eq("Hola Juan, Peter, Roberto")
      expect(saludador3.saludar("Juan","Peter","Roberto")).to eq("Hola Juan, Peter, Roberto")
      
    end
    
    it "should say 'Hola' to carlos as first parameter" do

      saludador = Saludador.new

      Aspects.on(saludador) do
        transform([:saludar]){
          inject(nombre1: "Carlos")
        }
      end
  
      expect(saludador.saludar("Pepe", "Roberto", "Pablo")).to eq("Hola Carlos, Roberto, Pablo")
      
    end
  
    it "should say 'Hola' to carlos as second param" do
    
      saludador = Saludador.new

      Aspects.on(saludador) do
        transform([:saludar]){
          inject(nombre2: "Carlos")
        }
      end
  
  
      expect(saludador.saludar("Pepe", "Roberto", "Pablo")).to eq("Hola Pepe, Carlos, Pablo")
      
    
    end
  
    it "should say 'Hola' to carlos as third param" do
  
      saludador = Saludador.new

      Aspects.on(saludador) do
        transform([:saludar]){
          inject(nombre3: "Carlos")
        }
      end
  
      expect(saludador.saludar("Pepe", "Roberto", "Pablo")).to eq("Hola Pepe, Roberto, Carlos")
      
    end
  
    it "should say 'Hola' to carlos as third param but passing 2 params" do
  
      saludador = Saludador.new

      Aspects.on(saludador) do
        transform([:saludar]){
          inject(nombre3: "Carlos")
        }
      end
  
      expect(saludador.saludar("Pepe", "Roberto")).to eq("Hola Pepe, Roberto, Carlos")
      
    end
  
    it "should say 'Hola' to carlos and pepe as first and second param" do
      
      saludador = Saludador.new

      Aspects.on(saludador) do
        transform([:saludar]){
          inject(nombre1: "Carlos", nombre2: "Pepe")
        }
      end

  
      expect(saludador.saludar("Juan","Peter","Roberto")).to eq("Hola Carlos, Pepe, Roberto")
      
    end
  
    it "should say 'Hola' to carlos and pepe as second and third param" do
        saludador = Saludador.new

        Aspects.on(saludador) do
          transform([:saludar]){
            inject(nombre2: "Carlos", nombre3: "Pepe")
          }
        end
    
        expect(saludador.saludar("Juan","Peter","Roberto")).to eq("Hola Juan, Carlos, Pepe")
        
    end
  
    it "should say 'Hola' to carlos and pepe as second and third param but passing only 1 param" do
      
      saludador = Saludador.new

      Aspects.on(saludador) do
        transform([:saludar]){
          inject(nombre2: "Carlos", nombre3: "Pepe")
        }
      end
    
      expect(saludador.saludar("Juan")).to eq("Hola Juan, Carlos, Pepe")
      
    end
  
    it "should say 'Hola' to Carlos, Pepe, and Pablo without passing any param" do
      
      saludador = Saludador.new

      Aspects.on(saludador) do
        transform([:saludar]){
          inject(nombre1: "Carlos", nombre2: "Pepe", nombre3: "Pablo")
        }
      end
    
      expect(saludador.saludar).to eq("Hola Carlos, Pepe, Pablo")
      
    end
  
    it "should say 'Hola' to Carlos, Pepe, and Pablo passing three params" do
  
      saludador = Saludador.new

      Aspects.on(saludador) do
        transform([:saludar]){
          inject(nombre1: "Carlos", nombre2: "Pepe", nombre3: "Pablo")
        }
      end
    
      expect(saludador.saludar("Juan","Peter","Roberto")).to eq("Hola Carlos, Pepe, Pablo")
      
    end


    it "should say 'Adios' to Roberto, Pedro and Peter" do
        
        saludador = Saludador.new

        Aspects.on(saludador) do
          transform([:despedir]){
            inject(nombre1: "Roberto")
          }
        end
      
        expect(saludador.despedir(nombre1 = "Raul", nombre2 = "María", nombre3 = "Peter")).to eq("Adios Roberto, María, Peter")
    end

    it "should say 'Adios' to Roberto, Pedro and Peter passing only one param" do
        saludador = Saludador.new

        Aspects.on(saludador) do
          transform([:despedir]){
            inject(nombre3: "Roberto")
          }
        end
      
        expect(saludador.despedir("Raul", "Pablo")).to eq("Adios Raul, Pablo, Roberto")
    end

    it "should say 'Adios' to Roberto, Raul and María when injectin 2 optional parameters" do
      
      saludador = Saludador.new

      Aspects.on(saludador) do
        transform([:despedir]){
          inject(nombre1: "Roberto", nombre2: "Raul")
        }
      end
    
      expect(saludador.despedir("Raul", "Pablo", "María")).to eq("Adios Roberto, Raul, María")
    end

    xit "should say 'Hola' and 'Adios' to Roberto and María when injecting named parameters" do
      
      saludador = Saludador.new

      Aspects.on(saludador) do
        transform([:hola_y_chau]){
          inject(nombre1: "Roberto")
        }
      end
    
      expect(saludador.hola_y_chau(nombre1: "Raul", nombre2: "María")).to eq("Hola Roberto, Adiós María")
    end

    xit "should say 'Hola' and 'Adios' to Roberto and Pedro when injectin first named parameter" do
        
        saludador = Saludador.new
  
        Aspects.on(saludador) do
          transform([:hola_y_chau]){
            inject(nombre1: "Roberto")
          }
        end
      
        expect(saludador.hola_y_chau(nombre2: "Pedro")).to eq("Hola Roberto, Adiós Pedro")
    end


    it "should say 'Hola' to Roberto only" do
      
      saludador = Saludador.new

      Aspects.on(saludador) do
        transform([:hola_a_todos]){
          inject(nombres: ["Roberto"])
        }
      end
    
      expect(saludador.hola_a_todos("Raul", "Maria", "Pedro")).to eq("Hola Roberto")
    end

    
  end
end