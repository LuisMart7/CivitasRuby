# encoding:UTF-8
require_relative 'casilla'
require_relative 'mazo_sorpresas'
module Civitas
  class Tablero
    def initialize(n)
      if n>=1
        @num_casilla_carcel=n
      else
        @num_casilla_carcel=1
      end
      
      salida=Casilla.new(TipoCasilla::DESCANSO, "Salida")
      @casillas=[]
      @casillas.push(salida)
      @por_salida=0
      @tiene_juez=false
    end
    
    def correcto(num_casilla=nil)
      correct = ((@casillas.size > @num_casilla_carcel) && @tiene_juez == true)
         if num_casilla != nil
          parametros_correct = (num_casilla >= 0 && num_casilla < @casillas.size)
          return (correct && parametros_correct)
         end
       return correct
    end
    
    def es_correcto(num_cas)
      return correcto(num_cas)
    end
    
    def get_por_salida
      if @por_salida>0
        @por_salida-=1
        return @por_salida+1
      else
      return @por_salida
      end
    end
    
    def aniade_casilla(casilla)
      if @casillas.length == @num_casilla_carcel
        carcel = Casilla.new(TipoCasilla::DESCANSO, "Cárcel")
        @casillas.push(carcel)
      end
      @casillas.push(casilla)
      if @casillas.length == @num_casilla_carcel
        carcel = Casilla.new(TipoCasilla::DESCANSO, "Cárcel")
        @casillas.push(carcel)
      end
    end
    
    def aniade_juez
      juez=Casilla.new(TipoCasilla::JUEZ, "Juez")
      if(!@tiene_juez)
        aniade_casilla(juez)
      end
      @tiene_juez=true
    end
    
    def get_casilla(num_casilla)
      if correcto(num_casilla)
        return @casillas[num_casilla]
      else
        return nil
      end
    end
    
    def nueva_posicion(actual, tirada)
      if(!correcto)
        return -1
      else
        suma=(tirada+actual)
        if suma>@casillas.length
          suma%=@casillas.length
          @por_salida+=1
        end
        return suma
      end
    end
    
    def calcular_tirada(origen, destino)
      total=destino-origen
      if total<0
        total+=@casillas.length
      end
      return total
    end
    
     attr_reader :num_casilla_carcel,
                 :casillas
      
     private :correcto
    
  end
end
