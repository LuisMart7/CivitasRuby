#encoding:UTF-8 
require_relative 'tipo_casilla'
require_relative 'titulo_propiedad'
require_relative 'sorpresa'
require_relative 'tablero'
require_relative 'mazo_sorpresas'
require_relative 'diario'
module Civitas
  class Casilla
    def init
      @carcel = nil
      @importe = 0
      @titulo = nil
      @tipo = nil
      @sorpresa = nil
      @mazo = []
    end
    
    def initialize(tipo, *args)
      init
      
      @tipo = tipo
      
      if(@tipo == TipoCasilla::DESCANSO)
        @nombre = args[0]
      elsif(@tipo == TipoCasilla::CALLE)
        @titulo_propiedad = args[0]
        @nombre = @titulo_propiedad.nombre
      elsif(@tipo == TipoCasilla::IMPUESTO)
        @cantidad = args[0]
        @nombre = args[1]
      elsif(@tipo == TipoCasilla::JUEZ)
        @carcel = args[0]
        @nombre = args[1]
      elsif(@tipo == TipoCasilla::SORPRESA)
        @mazo = args[0]
        @nombre = args[1]
      end
    end
    
    def recibe_jugador(actual, todos)
      case @tipo
      when TipoCasilla::CALLE then 
        recibe_jugador_calle(actual, todos)
      when TipoCasilla::IMPUESTO then 
        recibe_jugador_impuesto(actual, todos)
      when TipoCasilla::JUEZ then 
        recibe_jugador_juez(actual, todos)
      when TipoCasilla::SORPRESA then 
        recibe_jugador_sorpresa(actual, todos)
      else 
        informe(actual, todos)
      end
    end
    
    def informe(actual, todos)
      Diario.instance.ocurre_evento("El jugador #{todos[actual].nombre} ha caido en la casilla #{@tipo} \n")
    end
    
    def recibe_jugador_impuesto(actual, todos)
      if(jugador_correcto(actual, todos))
        informe(actual,todos)
        
        todos[actual].paga_impuesto(@impuesto)
      end
    end
    
    def recibe_jugador_juez(actual, todos)
      if jugador_correcto(actual, todos)
        todos[actual].encarcelar(@carcel)
      end
    end    
    
    def recibe_jugador_calle(actual, todos)
      if(jugador_correcto(actual, todos))
        informe(actual, todos)
        
        if (!@titulo_propiedad.tiene_propietario)
          todos[actual].puede_comprar_casilla
        else
          @titulo_propiedad.tramitar_alquiler(todos[actual])
        end
      end
    end
    
    def recibe_jugador_sorpresa(actual, todos)
      if jugador_correcto(actual, todos)
        informe(actual, todos)
        
        sorpresa = @mazo.siguiente
        sorpresa.aplicar_a_jugador(actual, todos)
      end
    end
    
    def jugador_correcto(actual, todos)
      actual>=0 && actual < todos.size
    end
    
    def to_string
      cadena = "Casilla: 
        Nombre = #{@nombre}
        Tipo =  #{@tipo}"
                        
      if (@tipo== TipoCasilla::JUEZ)
        representacion += "\n\t- Posicion carcel = #{@carcel}\n"
      end 
      if (@tipo== TipoCasilla::IMPUESTO)
         representacion+= "\n\t- Impuesto = #{@importe}"
      end
      
      return cadena
    end
    
    attr_reader :titulo_propiedad,
                :nombre,
                :tipo
    
    private :init, :informe, :recibe_jugador_calle, :recibe_jugador_impuesto, 
        :recibe_jugador_juez, :recibe_jugador_sorpresa
  end
end

