#encoding:UTF-8
require_relative 'jugador'
module Civitas
  class TituloPropiedad
    @@FACTOR_INTERESES_HIPOTECA= 1.1
    
    def initialize(nombre, alquiler_base, factor_revalorizacion, hipoteca_base, 
        precio_compra, precio_edificar)

      @nombre = nombre
      @alquiler_base = alquiler_base
      @factor_revalorizacion = factor_revalorizacion
      @hipoteca_base = hipoteca_base
      @precio_compra = precio_compra
      @precio_edificar = precio_edificar
      @propietario = nil
      
      @num_casas = 0 
      @num_hoteles = 0 
      @hipotecado = false
    end
    
    def to_string
      rep ="\nNombre: #{@nombre} \n"+
           "Alquiler base = #{@alquiler_base} \n"+
           "Factor Revalorización = #{@factor_revalorizacion} \n"+
           "Hipoteca base = #{@hipoteca_base} \n"+
           "Precio compra = #{@precio_compra} \n"+
           "Precio edificar = #{@precio_edificar} \n"+
           "Factor int. hipoteca = #{@@FACTOR_INTERESES_HIPOTECA} \n"+
           "Hipotecado = #{@hipotecado} \n"+
           "Numero de casas = #{@num_casas} \n"+
           "Numero de hoteles = #{@num_hoteles} \n"
         
      return rep
    end
    
    def get_precio_alquiler
      precio_alquiler=0
      if(@hipotecado == false || !propietario_encarcelado)
        precio_alquiler = @alquiler_base * (1+(@num_casas*(0.5)+(@num_hoteles*(2.5))))
      end
      return precio_alquiler
    end
    
    def es_este_el_propietario(jugador)
      return jugador==@propietario
    end
    
    def propietario_encarcelado
      return @propietario.is_encarcelado || @propietario==nil
    end
    
    def get_precio_venta
      variable = @precioCompra+((@numCasas+(5*@numHoteles))*@precioEdificar*@factorRevalorizacion).to_f
      return variable
    end
    
    def get_importe_hipoteca
      variable = @hipoteca_base*((@num_casas*0.5)+1+(2.5*@num_hoteles))
      return variable
    end
  
    def get_importe_cancelar_hipoteca
      return (@@FACTOR_INTERESES_HIPOTECA*get_importe_hipoteca)
    end

    #EXAMEN
    def tramitar_alquiler(jugador)
      if(tiene_propietario && @propietario != jugador && @propietario.amigo != jugador)
        precio_alquiler = get_precio_alquiler
        jugador.paga_alquiler(precio_alquiler)
        @propietario.recibe(precio_alquiler)
      end
    end
    
    def cantidad_casas_hoteles
      return @num_casas+@num_hoteles
    end
    
    def vender(jugador)
      if(es_este_el_propietario(jugador) && !@hipotecado)
        @propietario.recibe(get_precio_venta)
        
        derruir_casas(cantidad_casas_hoteles, @propietario)
        
        @propietario=nil
        @num_casas=0
        @num_hoteles=0
        
        return true
      end
      
      return false
    end
    
    def tiene_propietario
      return @propietario != nil
    end
    
    def derruir_casas(n, jugador)
      resultado = false
      
      if(jugador==@propietario)
        if(n <= @num_casas)
          @num_casas = 0
        else
          if(n <= @num_hoteles+@num_casas)
          @num_hoteles -= (n - @num_casas)
          @num_casas = 0
          else
            @num_hoteles = 0
            @num_casas = 0
          end
        end
        
        resultado = true
      end
      return resultado
    end
    
    def actualiza_jugador_por_conversion(jugador)
      @propietario = jugador
    end
    
    def cancelar_hipoteca(jugador)
      resultado = false
      
      if(@hipotecado && es_este_el_propietario(jugador))
        @propietario.paga(get_importe_cancelar_hipoteca)
        @hipotecado = false
        
        resultado = true
      end
      
      return resultado
    end
    
    def comprar(jugador)
      resultado = false
      
      if (!tiene_propietario)
        @propietario = jugador
        @propietario.paga(@precio_compra)
        
        resultado = true
      end
      
      return resultado
    end
    
    def construir_casa(jugador)
      resultado = false
      
      if(es_este_el_propietario(jugador))
        @propietario.modificar_saldo((-1)*@precio_edificar)
        @num_casas+=1
        
        resultado = true
      end
      
      return resultado
    end
    
    def construir_hotel(jugador)
      resultado = false
      
      if (es_este_el_propietario(jugador))
        @propietario.modificar_saldo((-1)*@precio_edificar)
        @num_hoteles+=1
        
        resultado = true
      end
      return resultado
    end
    
    def hipotecar(jugador)
      resultado = true
      if(!@hipotecado && es_este_el_propietario(jugador))
        @propietario.recibe(get_importe_hipoteca)
        @hipotecado = true
        
        resultado = true
      end
      return resultado
    end
    
    attr_reader :nombre,
                :precio_compra,
                :precio_edificar,
                :num_casas,
                :num_hoteles,
                :alquiler_base,
                :hipotecado,
                :propietario,
                :FACTOR_INTERESES_HIPOTECA
              
    private :propietario_encarcelado, :get_precio_venta, :get_precio_alquiler,
      :get_importe_hipoteca, :es_este_el_propietario
    
  end
end
