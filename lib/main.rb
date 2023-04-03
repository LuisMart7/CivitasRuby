#encoding:UTF-8
require_relative 'civitas_juego'
require_relative 'vista_textual'
require_relative 'controlador'
require_relative 'dado'
module Civitas
  class Test
    attr_reader :juego,
                :vista,
                :controlador

    def self.main
      nombres = ["Antonio", "Paco", "Eugenio", "Jose Manuel"]
      
      @juego = CivitasJuego.new(nombres)
      @vista = Vista_textual.new
      
      #EXAMEN
      Dado.instance.set_debug(true)
      
      @controlador = Controlador.new(@juego, @vista)
      @controlador.juega
    end
  end
  
  Test.main
end
