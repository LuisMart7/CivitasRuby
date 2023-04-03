#encoding:UTF-8
require_relative 'operaciones_juego'
require_relative 'jugador'
require_relative 'casilla'
require_relative 'civitas_juego'
require_relative 'diario'
require_relative 'titulo_propiedad'
require_relative 'respuestas'
require_relative 'salidas_carcel'
require 'io/console'

module Civitas
  class Vista_textual
    
    @@separador = "====================="
    
    def mostrar_estado(estado)
      puts estado
    end
    
    def pausa
      print "Pulsa una tecla"
      STDIN.getch
      print "\n"
    end

    def lee_entero(max,msg1,msg2)
      ok = false
      begin
        print msg1
        cadena = gets.chomp
        begin
          if (cadena =~ /\A\d+\Z/)
            numero = cadena.to_i
            ok = true
          else
            raise IOError
          end
        rescue IOError
          puts msg2
        end
        if (ok)
          if (numero >= max)
            ok = false
          end
        end
      end while (!ok)

      return numero
    end

    def menu(titulo,lista)
      tab = "  "
      puts titulo
      index = 0
      lista.each { |l|
        puts tab+index.to_s+"-"+l.to_s
        index += 1
      }

      opcion = lee_entero(lista.length,
                          "\n"+tab+"Elige una opción: ",
                          tab+"Valor erróneo")
      return opcion
    end

    def salir_carcel
      lista_carcel = [SalidasCarcel::PAGANDO, SalidasCarcel::TIRANDO]
      opcion = menu("Elige la forma de salir de la carcel", lista_carcel)
      return lista_carcel[opcion]
    end
    
    def comprar
      lista_respuestas = [Respuestas::NO,Respuestas::SI]
      opcion = menu("Elige si desea comprar la casilla o no", lista_respuestas)
      return lista_respuestas[opcion]
    end

    def gestionar
      lista = ["VENDER", "HIPOTECAR", "CANCELAR HIPOTECA", "CONSTRUIR CASA", "CONSTRUIR HOTEL", "TERMINAR"]
        lista_prop = @juego_model.jugador_actual.get_lista_propiedades
        if(lista_prop.size()>0)
            opcion = menu("Que gestión inmobiliaria quiere realizar ",lista)
            @i_gestion =opcion
            
            if(@i_gestion != 5) #Si no es TERMINAR
              opcion1 = menu("Elija el indice de la propiedad sobre la que realizar la gestion: ",lista_prop)
              @i_propiedad = opcion1
            end
              
        else
            System.out.println("El jugador no puede gestionar nada no tiene propiedades.");
        end
    end

    def mostrar_siguiente_operacion(operacion)
      puts "Siguiente operacion: #{operacion}"
    end

    def mostrar_eventos
      while(Diario.instance.eventos_pendientes == true)
        puts Diario.instance.leer_evento
      end
    end

    def set_civitas_juego(civitas)
         @juego_model=civitas
         self.actualizar_vista
    end

    def actualizar_vista
      actual = @juego_model.jugador_actual
      puts actual.to_string
      
      casilla = @juego_model.casilla_actual
      puts casilla.to_string
    end
    
    attr_reader :i_gestion,
                :i_propiedad,
                :juego_model
  end

end
