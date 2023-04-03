#encoding:UTF-8
require_relative 'operaciones_juego'
require_relative 'estados_juego'
require_relative 'jugador'
require_relative 'gestor_estados'
require_relative 'mazo_sorpresas'
require_relative 'tablero'
require_relative 'dado'
module Civitas
  class CivitasJuego
    attr_reader :indice_jugador_actual
    
    def initialize(nombres)
      @jugadores = []
      
      for jug in nombres
        @jugadores.push(Jugador.new_nombre(jug))
      end
      
      @gestor = Gestor_estados.new
      @estados = @gestor.estado_inicial
      
      @indice_jugador_actual = Dado.instance.quien_empieza(@jugadores.size)
      
      #EXAMEN
      @mazo= MazoSorpresas.new(true)
      
      inicializar_tablero(@mazo)
      inicializar_mazo_sorpresas(@tablero)
    end
    
    def inicializar_tablero(mazo)
      @tablero = Tablero.new(5)
      @mazo = mazo

      random = nil
      contador_sorpresas = 0
      park = false
      
      calles = ["Arsenal", "Manchester City", "Bayern de Munich", "Chelsea", "Liverpool", 
        "PSG", "Manchester United", "Juventus", "Barcelona", "Real Madrid", "Granada", "Inter de Milan"]
      
      for i in 1..19
        random = rand(1..4)
        
        if(i>=5 && i<10)
          random+=5
        elsif(i>=10 && i<15)
          random+=10
        elsif(i>=15 && i<20)
          random+=15
        end
        
        if(random == 1)
          calle = Casilla.new(TipoCasilla::CALLE, TituloPropiedad.new(calles[i],
            i*50, i*0.025, i*100, i*150, i*30))
        
        else
          if (random!=i && i!=15 && i!=10 && i!=5)
            calle = Casilla.new(TipoCasilla::CALLE, TituloPropiedad.new(calles[i],
                                        i*50,i*0.025,i*100,i*150,i*30))
            @tablero.aniade_casilla(calle)
          elsif (i == random)
            if(contador_sorpresas <= 3)
              sorpresa = Casilla.new(TipoCasilla::SORPRESA, @mazo ,"Sorpresa Futbol")
              @tablero.aniade_casilla(sorpresa)
              contador_sorpresas+=1
            elsif
              call = Casilla.new(TipoCasilla::CALLE, TituloPropiedad.new(calles[i],
                                        i*50,i*0.025,i*100,i*150,i*30))
              @tablero.aniade_casilla(call)
            end
          elsif i == 15
            impuesto = Casilla.new(TipoCasilla::IMPUESTO, 100, "Impuesto Sancion")
            @tablero.aniade_casilla(impuesto)
          elsif i == 10
            @tablero.aniade_juez
          elsif(i!=random && !park)
            parking = Casilla.new(TipoCasilla::DESCANSO, "Parking Estadio")
            @tablero.aniade_casilla(parking)

            park=true
          end
        end
      end
      
=begin
      #@tablero.añade_casilla(Casilla.new(TipoCasilla::DESCANSO, "Salida"))
      
      @tablero.aniade_casilla(Casilla.new(TipoCasilla::CALLE, TituloPropiedad.new("Arsenal", 50, 0.025, 100, 150, 30)))
      @tablero.aniade_casilla(Casilla.new(TipoCasilla::CALLE, TituloPropiedad.new("Manchester City", 60, 0.025, 100, 150, 30)))
      
      @tablero.aniade_casilla(Casilla.new(TipoCasilla::SORPRESA, "Sorpresa Champions", @mazo))
      
      @tablero.aniade_casilla(Casilla.new(TipoCasilla::CALLE, TituloPropiedad.new("Bayern de Munich", 70, 0.05, 150, 200, 60)))
      
      @tablero.aniade_juez
      
      @tablero.aniade_casilla(Casilla.new(TipoCasilla::CALLE, TituloPropiedad.new("Chelsea", 80, 0.05, 150, 200, 60)))
      @tablero.aniade_casilla(Casilla.new(TipoCasilla::CALLE, TituloPropiedad.new("Liverpool", 90, 0.075, 200, 300, 90)))
      @tablero.aniade_casilla(Casilla.new(TipoCasilla::CALLE, TituloPropiedad.new("PSG", 100, 0.075, 200, 300, 90)))
      
      @tablero.aniade_casilla(Casilla.new(TipoCasilla::IMPUESTO, "Impuesto", 600))
        
      @tablero.aniade_casilla(Casilla.new(TipoCasilla::DESCANSO, "Parking"))
      
      @tablero.aniade_casilla(Casilla.new(TipoCasilla::CALLE, TituloPropiedad.new("Manchester United", 110, 0.1, 250, 400, 120)))
      @tablero.aniade_casilla(Casilla.new(TipoCasilla::CALLE, TituloPropiedad.new("Juventus", 120, 0.1, 250, 400, 120)))
      
      @tablero.aniade_casilla(Casilla.new(TipoCasilla::SORPRESA, "Sorpresa UEFA", @mazo))
      
      @tablero.aniade_casilla(Casilla.new(TipoCasilla::CALLE, TituloPropiedad.new("Barcelona", 130, 0.125, 350, 600, 150)))
      
      #@tablero.aniade_casilla(Casilla.new(TipoCasilla::DESCANSO, "Carcel"))
      
      @tablero.aniade_casilla(Casilla.new(TipoCasilla::CALLE, TituloPropiedad.new("Real Madrid", 140, 0.125, 350, 600, 150)))
      @tablero.aniade_casilla(Casilla.new(TipoCasilla::CALLE, TituloPropiedad.new("Granada", 150, 0.15, 600, 900, 200)))
      
      @tablero.aniade_casilla(Casilla.new(TipoCasilla::SORPRESA, "Sorpresa Mundial", @mazo))
      
      @tablero.aniade_casilla(Casilla.new(TipoCasilla::CALLE, TituloPropiedad.new("Inter de Milan", 160, 0.15, 600, 900, 200)))
=end
    end
    
    def inicializar_mazo_sorpresas(tab)
      @mazo.al_mazo(Sorpresa.new(TipoSorpresa::PAGARCOBRAR, -500, "RESTAR"))
      @mazo.al_mazo(Sorpresa.new(TipoSorpresa::PAGARCOBRAR, 500, "SUMAR"))
      @mazo.al_mazo(Sorpresa.new(TipoSorpresa::IRCASILLA, tab, 1, "MOVER A CASILLA"))
      @mazo.al_mazo(Sorpresa.new(TipoSorpresa::IRCASILLA, tab, tab.num_casilla_carcel, "MOVER A CASILLA CARCEL"))
      @mazo.al_mazo(Sorpresa.new(TipoSorpresa::PORCASAHOTEL, -700, "PAGAR"))
      @mazo.al_mazo(Sorpresa.new(TipoSorpresa::PORCASAHOTEL, 700, "COBRAR"))
      @mazo.al_mazo(Sorpresa.new(TipoSorpresa::PORJUGADOR, -600, "PAGAR"))
      @mazo.al_mazo(Sorpresa.new(TipoSorpresa::PORJUGADOR, 600, "COBRAR"))
      @mazo.al_mazo(Sorpresa.new(TipoSorpresa::IRCARCEL, tab))
      @mazo.al_mazo(Sorpresa.new(TipoSorpresa::SALIRCARCEL, @mazo))
    end
    
    def contabilizar_pasos_por_salida(jugador_actual)
      if(@tablero.get_por_salida>0)
        jugador_actual.pasa_por_salida
        
        for i in 0..@tablero.get_por_salida
          jugador_actual.pasa_por_salida
        end
      end
    end
    
    def pasar_turno
      @indice_jugador_actual=(@indice_jugador_actual+1)%@jugadores.size
    end
    
    def ranking
      ranking = @jugadores
      ranking.sort
      
      return ranking
    end
    
    def avanza_jugador
      jugador_actual = @jugadores[@indice_jugador_actual]
      posicion_actual = jugador_actual.num_casilla_actual
      
      tirada = Dado.instance.tirar
      nueva_posicion = @tablero.nueva_posicion(posicion_actual, tirada)
      casilla = @tablero.get_casilla(nueva_posicion)
      
      contabilizar_pasos_por_salida(jugador_actual)
      
      jugador_actual.mover_a_casilla(nueva_posicion)
      casilla.recibe_jugador(@indice_jugador_actual, @jugadores)
      
      contabilizar_pasos_por_salida(jugador_actual)
      
      if(@tablero.num_casilla_carcel == nueva_posicion && jugador_actual.debe_ser_encarcelado)
        jugador_actual.encarcelar(@tablero.num_casilla_carcel)
      end
    end
    
    def siguiente_paso
      jugador_actual = @jugadores[@indice_jugador_actual]
      operacion = @gestor.operaciones_permitidas(jugador_actual, @estados)
      
      if (operacion == OperacionesJuego::PASAR_TURNO)
        pasar_turno
        siguiente_paso_completado(operacion)
      elsif (operacion == OperacionesJuego::AVANZAR)
        avanza_jugador
        siguiente_paso_completado(operacion)
      end
      
      return operacion
    end
    
    def comprar
      jugador_actual = @jugadores[@indice_jugador_actual]
      casilla_actual = jugador_actual.num_casilla_actual
      
      casilla = @tablero.get_casilla(casilla_actual)
      titulo = casilla.titulo_propiedad
      
      return jugador_actual.comprar(titulo)
    end
    
    def siguiente_paso_completado(op)
      @estados = @gestor.siguiente_estado(@jugadores[@indice_jugador_actual],@estados, op)
    end
    
    def construir_casa(ip)
      return @jugadores[@indice_jugador_actual].construir_casa(ip)
    end
    
    def construir_hotel(ip)
      return @jugadores[@indice_jugador_actual].construir_hotel(ip)
    end
    
    def vender(ip)
      return @jugadores[@indice_jugador_actual].vender(ip)
    end
    
    def hipotecar(ip)
      return @jugadores[@indice_jugador_actual].hipotecar(ip)
    end
    
    def cancelar_hipoteca(ip)
      return @jugadores[@indice_jugador_actual].cancelar_hipoteca(ip)
    end
    
    def salir_carcel_pagando
      return @jugadores[@indice_jugador_actual].salir_carcel_pagando
    end
    
    def salir_carcel_tirando
      return @jugadores[@indice_jugador_actual].salir_carcel_tirando
    end
    
    def final_juego
      for i in 0..@jugadores.size
        if(@jugadores[i].en_bancarrota)
          puts ranking.to_s
          return true
        end
        
        return false
      end
    end
    
    def casilla_actual
      return @tablero.get_casilla(@jugadores.at(@indice_jugador_actual).num_casilla_actual)
    end
    
    def jugador_actual      
      return @jugadores[@indice_jugador_actual]
    end
    
    #EXAMEN
    def set_amigo(n)
      if((n>0 && n<@jugadores.size) && n%4 != 0)
        @jugadores[@indice_jugador_actual].hacer_amigo(@jugadores[(@indice_jugador_actual+n)%@jugadores.size])
      else
        puts "No se ha podido establecer amistad"
      end
    end
    
    #EXAMEN
    def saludo_global
      cadena = ""
      
      for i in @jugadores
        cadena += i.saludar + "\n"
      end
      
      return cadena
    end
    
    #require_relative 'controlador'
    #require_relative 'vista'
    
    #EXAMEN
    def prueba_examen
      nombres = ["Antonio", "Paco", "Eugenio", "Jose Manuel"]
      
      juego = CivitasJuego.new(nombres)
      vista = Vista_textual.new
      
      Dado.instance.set_debug(true)
      
      controlado = Controlador.new(@juego, @vista)
      controlador.juega
      
      CivitasJuego.main
    end
    
    private :ranking, :pasar_turno, :inicializar_tablero, :inicializar_mazo_sorpresas,
      :avanza_jugador, :contabilizar_pasos_por_salida
  end
end

