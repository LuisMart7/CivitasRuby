#encoding:UTF-8
require_relative 'tipo_sorpresa'
require_relative 'mazo_sorpresas'
require_relative 'tablero'
require_relative 'jugador'
module Civitas
  class Sorpresa
    def init
      @valor = -1
      @mazo = nil
      @tablero = nil
      @texto = ""
    end
    
    def initialize(tipo, *params) 
      init
      
      @tipo=tipo
      
      if(@tipo == TipoSorpresa::IRCARCEL) #unico valor pasado el tablero
        @tablero = params[0]
      elsif(@tipo == TipoSorpresa::IRCASILLA) #los valores se tienen que pasar en ese orden 
        @tablero = params[0]
        @valor = params[1]
        @texto = params[2]
      elsif(@tipo == TipoSorpresa::SALIRCARCEL)
        @mazo = params[0]
      else
        @valor = params[0]
        @texto = params[1]
      end
    end
    
    def informe(actual, todos)
      Diario.instance.ocurre_evento("Se le aplica la sorpresa #{@tipo} al jugador "+todos[actual].nombre)
    end
    
    def aplicar_a_jugador(actual, todos)
      if(jugador_correcto(actual, todos))
        case @tipo
        when TipoSorpresa::IRCASILLA 
          then aplicar_a_jugador_ir_casilla(actual,todos)
        when TipoSorpresa::IRCARCEL
          then aplicar_a_jugador_ir_carcel(actual, todos)
        when TipoSorpresa::PAGARCOBRAR
          then aplicar_a_jugador_pagar_cobrar(actual,todos)
        when TipoSorpresa::PORCASAHOTEL
          then aplicar_a_jugador_por_casa_hotel(actual,todos)
        when TipoSorpresa::PORJUGADOR(actual, todos)
          then aplicar_a_jugador_por_jugador(actual,todos)
        else 
          aplicar_a_jugador_salir_carcel(actual,todos)
        end
      end
    end
    
    def aplicar_a_jugador_ir_carcel(actual,todos)
      if(jugador_correcto(actual,todos))
        informe(actual,todos)
        
        todos[actual].encarcelar(@tablero.num_casilla_carcel)
      end
    end
    
    def aplicar_a_jugador_ir_casilla(actual, todos)
      if(jugador_correcto(actual,todos))
        informe(actual,todos)
        
        casilla = todos[actual].num_casilla_actual
        tirada = @tablero.calcular_tirada(casilla, @valor)
        posicion = @tablero.nueva_posicion(casilla, tirada)
        
        todos[actual].mover_a_casilla(posicion)
        @tablero.get_casilla(posicion).recibe_jugador(actual, todos)
      end
    end
    
    def aplicar_a_jugador_pagar_cobrar(actual, todos)
      if(jugador_correcto(actual, todos))
        informe(actual, todos)
        
        todos[actual].modificar_saldo(@valor)
      end
    end
    
    def aplicar_a_jugador_por_casa_hotel(actual, todos)
      if(jugador_correcto(actual,todos))
        informe(actual,todos)
        
        todos[actual].modificar_saldo(@valor*(todos[actual].cantidad_casas_hoteles))
      end
    end
    
    def aplicar_a_jugador_por_jugador(actual, todos)
      if(jugador_correcto(actual,todos))
        informe(actual,todos)
        
        sorpresa_pago = Sorpresa.new(TipoSorpresa::PAGARCOBRAR, (-1)*@valor, "Pago")
        sorpresa_cobro = Sorpresa.new(TipoSorpresa::PAGARCOBRAR, (todos.size-1)*@valor, "Cobro")
        
        for i in 0..todos.size
          if(i!=actual)
            todos[i].modificar_saldo(sorpresa_pago.valor.to_f)
          else
            todos[i].modificar_saldo(sorpresa_cobro.valor.to_f)
          end
        end
      end
    end
    
    def aplicar_a_jugador_salir_carcel(actual,todos)
      if(jugador_correcto(actual,todos))
        informe(actual,todos)
        
        salvoconducto = false
        
        for i in todos.size
          if(i.tiene_salvoconducto)
            salvoconducto = true
          end
          
          if(!salvoconducto)
            #sorpresa = Sorpresa.new(TipoSorpresa::SALIRCARCEL, -1, "Salvoconducto")
            todos[actual].obtener_salvoconducto(self)
            
            salir_del_mazo
          end
        end
      end
    end
    
    
    
    def salir_del_mazo
      if(@tipo == TipoSorpresa::SALIRCARCEL)
        @mazo.inhabilitar_carta_especial(self)
      end
    end
    
    def usada
      if(@tipo == TipoSorpresa::SALIRCARCEL)
        @mazo.habilitar_carta_especial(self)
      end
    end
    
    def jugador_correcto(actual, todos)
      return actual<=todos.size && actual>=0
    end
    
    def to_string
      return @texto
    end
    
    attr_reader :tipo
    
    private :init, :aplicar_a_jugador_ir_casilla, :aplicar_a_jugador_ir_carcel,
            :aplicar_a_jugador_pagar_cobrar, :aplicar_a_jugador_por_casa_hotel,
            :aplicar_a_jugador_por_jugador, :aplicar_a_jugador_salir_carcel, :informe
  end
end
