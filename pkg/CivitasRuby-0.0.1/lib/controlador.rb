#encoding:UTF-8
require_relative 'operaciones_juego'
require_relative 'civitas_juego'
require_relative 'gestiones_inmobiliarias'
require_relative 'salidas_carcel'
require_relative 'operacion_inmobiliaria'
require_relative 'respuestas'
require_relative 'tipo_casilla'
module Civitas
  class Controlador
    def initialize(juego, vista)
      @juego = juego
      @vista = vista
    end

    def juega
      @vista.set_civitas_juego(@juego)
      
      while(!@juego.final_juego)
        @vista.actualizar_vista
        @vista.pausa
        
        operacion = @juego.siguiente_paso
        @vista.mostrar_siguiente_operacion(operacion)
        
        if(operacion != OperacionesJuego::PASAR_TURNO)
          @vista.mostrar_eventos
        end
        
        if(!@juego.final_juego)
          case operacion
          when OperacionesJuego::COMPRAR then
            if(@juego.casilla_actual.tipo == TipoCasilla::CALLE)
              resultado = @vista.comprar
              if(resultado == Respuestas::SI)
                @juego.comprar
              end
            end
            
            @juego.siguiente_paso_completado(operacion)
          when OperacionesJuego::GESTIONAR then
            @vista.gestionar
            
            gestion = GestionesInmobiliarias::LISTA_GESTIONES_INMOBILIARIAS[@vista.i_gestion]
            operacion_inmob = OperacionInmobiliaria.new(gestion, @vista.i_propiedad)

            case operacion_inmob.gestion
            when GestionesInmobiliarias::VENDER then
              @juego.vender(operacion_inmob.num_propiedad)
            when GestionesInmobiliarias::HIPOTECAR then
              @juego.hipotecar(operacion_inmob.num_propiedad)
            when GestionesInmobiliarias::CANCELAR_HIPOTECA then
              @juego.cancelar_hipoteca(operacion_inmob.num_propiedad)
            when GestionesInmobiliarias::CONSTRUIR_CASA then
              @juego.construir_casa(operacion_inmob.num_propiedad)
            when GestionesInmobiliarias::CONSTRUIR_HOTEL then
              @juego.construir_hotel(operacion_inmob.num_propiedad)
            else
              @juego.siguiente_paso_completado(operacion)
            end
          when OperacionesJuego::SALIR_CARCEL
            case @vista.salir_carcel
            when SalidasCarcel::PAGANDO then
              @juego.salir_carcel_pagando
            else
              @juego.salir_carcel_tirando
            end
            @juego.siguiente_paso_completado(operacion)
          end
        end
      end
      
      @juego.final_juego
    end
  end
end

