#encoding:UTF-8
require_relative 'diario'
require_relative 'operaciones_juego'
require_relative 'estados_juego'
module Civitas
  class Gestor_estados
    def estado_inicial
      return (Estados_juego::INICIO_TURNO)
    end

    def operaciones_permitidas(jugador,estado)
      op = nil

      case estado

      when Estados_juego::INICIO_TURNO
        if (jugador.encarcelado)
          op = OperacionesJuego::SALIR_CARCEL
        else
          op = OperacionesJuego::AVANZAR
        end

      when Estados_juego::DESPUES_CARCEL
        op = OperacionesJuego::PASAR_TURNO

      when Estados_juego::DESPUES_AVANZAR
        if (jugador.encarcelado)
          op = OperacionesJuego::PASAR_TURNO
        else
          if (jugador.puede_comprar_casilla)
            op = OperacionesJuego::COMPRAR
          else
            if (jugador.tiene_algo_que_gestionar)
              op = OperacionesJuego::GESTIONAR
            else
              op = OperacionesJuego::PASAR_TURNO
            end
          end
        end

      when Estados_juego::DESPUES_COMPRAR
        if (jugador.tiene_algo_que_gestionar)
          op = OperacionesJuego::GESTIONAR
        else
          op = OperacionesJuego::PASAR_TURNO
        end

      when Estados_juego::DESPUES_GESTIONAR
        op = OperacionesJuego::PASAR_TURNO
      end

      return op
    end



    def siguiente_estado(jugador,estado,operacion)
      siguiente = nil

      case estado

      when Estados_juego::INICIO_TURNO
        if (operacion==OperacionesJuego::SALIR_CARCEL)
          siguiente = Estados_juego::DESPUES_CARCEL
        else
          if (operacion==OperacionesJuego::AVANZAR)
            siguiente = Estados_juego::DESPUES_AVANZAR
          end
        end


      when Estados_juego::DESPUES_CARCEL
        if (operacion==OperacionesJuego::PASAR_TURNO)
          siguiente = Estados_juego::INICIO_TURNO
        end

      when Estados_juego::DESPUES_AVANZAR
        case operacion
          when OperacionesJuego::PASAR_TURNO
            siguiente = Estados_juego::INICIO_TURNO
          when
            OperacionesJuego::COMPRAR
              siguiente = Estados_juego::DESPUES_COMPRAR
          when OperacionesJuego::GESTIONAR
              siguiente = Estados_juego::DESPUES_GESTIONAR
        end


      when Estados_juego::DESPUES_COMPRAR
        #if (jugador.tiene_algo_que_gestionar)
        if (operacion==OperacionesJuego::GESTIONAR)
          siguiente = Estados_juego::DESPUES_GESTIONAR
        #  end
        else
          if (operacion==OperacionesJuego::PASAR_TURNO)
            siguiente = Estados_juego::INICIO_TURNO
          end
        end

      when Estados_juego::DESPUES_GESTIONAR
        if (operacion==OperacionesJuego::PASAR_TURNO)
          siguiente = Estados_juego::INICIO_TURNO
        end
      end

      Diario.instance.ocurre_evento("De: "+estado.to_s+ " con "+operacion.to_s+ " sale: "+siguiente.to_s)

      return siguiente
    end
  end
end

